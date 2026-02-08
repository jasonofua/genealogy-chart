import 'package:flutter/material.dart';
import '../layouts/layout_algorithm.dart';
import '../themes/chart_theme.dart';

/// Base painter for rendering edges/connectors.
abstract class EdgePainter extends CustomPainter {
  final List<EdgePath> paths;
  final EdgeTheme theme;

  EdgePainter({
    required this.paths,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(covariant EdgePainter oldDelegate) {
    return paths != oldDelegate.paths || theme != oldDelegate.theme;
  }

  /// Get paint for a path.
  Paint getPaint(EdgePath path) {
    final paint = Paint()
      ..color = theme.lineColor
      ..strokeWidth = theme.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (theme.lineStyle == EdgeLineStyle.dashed) {
      // Note: For dashed lines, you'd use a path effect or draw segments
      // This is a simple implementation
    }

    return paint;
  }

  /// Draw an arrow at a point.
  void drawArrow(Canvas canvas, Offset point, Offset direction, Paint paint) {
    if (theme.arrowStyle == null || theme.arrowStyle!.type == ArrowType.none) {
      return;
    }

    final arrowSize = theme.arrowStyle!.size;
    final arrowColor = theme.arrowStyle!.color ?? paint.color;
    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = theme.arrowStyle!.type == ArrowType.filled
          ? PaintingStyle.fill
          : PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth;

    // Normalize direction
    final length = direction.distance;
    if (length == 0) return;
    final normalized = Offset(direction.dx / length, direction.dy / length);

    // Calculate arrow points
    final perpendicular = Offset(-normalized.dy, normalized.dx);
    final tip = point;
    final back = point - normalized * arrowSize;
    final left = back + perpendicular * (arrowSize / 2);
    final right = back - perpendicular * (arrowSize / 2);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }
}

/// Default edge painter using straight/orthogonal lines.
class DefaultEdgePainter extends EdgePainter {
  DefaultEdgePainter({
    required super.paths,
    required super.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edgePath in paths) {
      final paint = getPaint(edgePath);
      final points = edgePath.points;

      if (points.length < 2) continue;

      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      // Apply dashed style if needed
      if (theme.lineStyle == EdgeLineStyle.dashed) {
        _drawDashedPath(canvas, path, paint);
      } else if (theme.lineStyle == EdgeLineStyle.dotted) {
        _drawDottedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }

      // Draw arrow if needed
      if (edgePath.showArrow && points.length >= 2) {
        final lastPoint = points.last;
        final secondLast = points[points.length - 2];
        final direction = lastPoint - secondLast;
        drawArrow(canvas, lastPoint, direction, paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 4.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extractedPath = metric.extractPath(
          distance,
          (distance + dashLength).clamp(0, metric.length),
        );
        canvas.drawPath(extractedPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint) {
    const dotSpacing = 6.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, paint.strokeWidth / 2, paint);
        }
        distance += dotSpacing;
      }
    }
  }
}

/// Painter for orthogonal (right-angle) connectors.
class OrthogonalEdgePainter extends EdgePainter {
  final double cornerRadius;

  OrthogonalEdgePainter({
    required super.paths,
    required super.theme,
    this.cornerRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edgePath in paths) {
      final paint = getPaint(edgePath);
      final points = edgePath.points;

      if (points.length < 2) continue;

      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];

        if (i < points.length - 1 && cornerRadius > 0) {
          final next = points[i + 1];

          // Calculate corner
          final d1 = curr - prev;
          final d2 = next - curr;

          if (d1.dx != 0 && d2.dy != 0 || d1.dy != 0 && d2.dx != 0) {
            // This is a corner
            final radius = cornerRadius.clamp(0, d1.distance / 2).clamp(0, d2.distance / 2);

            final corner1 = curr - Offset(
              d1.dx != 0 ? d1.dx.sign * radius : 0,
              d1.dy != 0 ? d1.dy.sign * radius : 0,
            );
            final corner2 = curr + Offset(
              d2.dx != 0 ? d2.dx.sign * radius : 0,
              d2.dy != 0 ? d2.dy.sign * radius : 0,
            );

            path.lineTo(corner1.dx, corner1.dy);
            path.quadraticBezierTo(curr.dx, curr.dy, corner2.dx, corner2.dy);
            continue;
          }
        }

        path.lineTo(curr.dx, curr.dy);
      }

      canvas.drawPath(path, paint);

      if (edgePath.showArrow && points.length >= 2) {
        final lastPoint = points.last;
        final secondLast = points[points.length - 2];
        final direction = lastPoint - secondLast;
        drawArrow(canvas, lastPoint, direction, paint);
      }
    }
  }
}

/// Painter for curved (bezier) connectors.
class CurvedEdgePainter extends EdgePainter {
  final double curvature;

  CurvedEdgePainter({
    required super.paths,
    required super.theme,
    this.curvature = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edgePath in paths) {
      final paint = getPaint(edgePath);
      final points = edgePath.points;

      if (points.length < 2) continue;

      final start = points.first;
      final end = points.last;

      final path = Path()..moveTo(start.dx, start.dy);

      // Calculate control points for cubic bezier
      final dx = end.dx - start.dx;

      final cp1 = Offset(start.dx + dx * curvature, start.dy);
      final cp2 = Offset(end.dx - dx * curvature, end.dy);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);

      if (edgePath.showArrow) {
        // Direction at end of bezier
        final direction = Offset(
          3 * (1 - 1) * (1 - 1) * (cp1.dx - start.dx) +
              6 * (1 - 1) * 1 * (cp2.dx - cp1.dx) +
              3 * 1 * 1 * (end.dx - cp2.dx),
          3 * (1 - 1) * (1 - 1) * (cp1.dy - start.dy) +
              6 * (1 - 1) * 1 * (cp2.dy - cp1.dy) +
              3 * 1 * 1 * (end.dy - cp2.dy),
        );
        drawArrow(canvas, end, direction, paint);
      }
    }
  }
}
