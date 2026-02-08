import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../themes/chart_theme.dart';

/// Visual feedback overlay during drag operations.
class DragFeedbackOverlay extends StatelessWidget {
  /// The member being dragged.
  final FamilyMember member;

  /// Current drag position.
  final Offset position;

  /// Size of the feedback.
  final Size size;

  /// Whether the current position is a valid drop target.
  final bool isValidTarget;

  /// The relation that would be created if dropped here.
  final String? relationHint;

  const DragFeedbackOverlay({
    super.key,
    required this.member,
    required this.position,
    this.size = const Size(100, 100),
    this.isValidTarget = true,
    this.relationHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return Positioned(
      left: position.dx - size.width / 2,
      top: position.dy - size.height / 2,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview node
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: isValidTarget
                    ? theme.selectionColor.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isValidTarget ? theme.selectionColor : Colors.red,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Center(
                child: Icon(
                  isValidTarget ? Icons.add_circle_outline : Icons.cancel_outlined,
                  color: isValidTarget ? theme.selectionColor : Colors.red,
                  size: 32,
                ),
              ),
            ),
            // Relation hint
            if (relationHint != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  relationHint!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Connection line preview during drag.
class DragConnectionPreview extends StatelessWidget {
  /// Start point of the connection.
  final Offset start;

  /// End point of the connection.
  final Offset end;

  /// Color of the preview line.
  final Color? color;

  /// Whether this is a valid connection.
  final bool isValid;

  const DragConnectionPreview({
    super.key,
    required this.start,
    required this.end,
    this.color,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return CustomPaint(
      painter: _ConnectionPreviewPainter(
        start: start,
        end: end,
        color: color ?? (isValid ? theme.selectionColor : Colors.red),
        isValid: isValid,
      ),
    );
  }
}

class _ConnectionPreviewPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final bool isValid;

  _ConnectionPreviewPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.isValid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed line
    const dashLength = 8.0;
    const gapLength = 4.0;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

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

    // Draw arrow at end
    _drawArrow(canvas, end, start, paint);
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final direction = tip - from;
    final length = direction.distance;
    if (length == 0) return;

    final normalized = Offset(direction.dx / length, direction.dy / length);
    final perpendicular = Offset(-normalized.dy, normalized.dx);

    const arrowSize = 10.0;
    final back = tip - normalized * arrowSize;
    final left = back + perpendicular * (arrowSize / 2);
    final right = back - perpendicular * (arrowSize / 2);

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionPreviewPainter oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        color != oldDelegate.color;
  }
}

/// Drop zone indicator shown when dragging.
class DropZoneIndicator extends StatelessWidget {
  /// Label for the drop zone.
  final String label;

  /// Icon to display.
  final IconData icon;

  /// Whether this zone is currently hovered.
  final bool isHovered;

  /// Size of the indicator.
  final Size size;

  const DropZoneIndicator({
    super.key,
    required this.label,
    required this.icon,
    this.isHovered = false,
    this.size = const Size(80, 60),
  });

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: isHovered
            ? theme.selectionColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHovered ? theme.selectionColor : Colors.grey,
          width: isHovered ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isHovered ? theme.selectionColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isHovered ? theme.selectionColor : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
