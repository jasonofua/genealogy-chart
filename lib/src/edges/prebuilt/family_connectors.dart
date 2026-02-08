import 'package:flutter/material.dart';

/// Painter for sibling branch connectors.
///
/// Draws horizontal lines connecting siblings with vertical drop lines.
class SiblingBranchPainter extends CustomPainter {
  final ChildPosition position;
  final Color horizontalColor;
  final Color verticalColor;
  final double strokeWidth;

  SiblingBranchPainter({
    required this.position,
    required this.horizontalColor,
    required this.verticalColor,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizontalPaint = Paint()
      ..color = horizontalColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final verticalPaint = Paint()
      ..color = verticalColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    const topY = 0.0;
    final bottomY = size.height;

    // Draw horizontal segment based on position
    switch (position) {
      case ChildPosition.first:
        canvas.drawLine(
          Offset(centerX, topY),
          Offset(size.width, topY),
          horizontalPaint,
        );
        break;
      case ChildPosition.middle:
        canvas.drawLine(
          Offset(0, topY),
          Offset(size.width, topY),
          horizontalPaint,
        );
        break;
      case ChildPosition.last:
        canvas.drawLine(
          Offset(0, topY),
          Offset(centerX, topY),
          horizontalPaint,
        );
        break;
      case ChildPosition.only:
        // No horizontal segment for single child
        break;
    }

    // Draw vertical drop line
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX, bottomY),
      verticalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SiblingBranchPainter oldDelegate) {
    return position != oldDelegate.position ||
        horizontalColor != oldDelegate.horizontalColor ||
        verticalColor != oldDelegate.verticalColor;
  }
}

/// Position of a child among siblings.
enum ChildPosition {
  first,
  middle,
  last,
  only,
}

/// Painter for spouse connection lines.
class SpouseConnectorPainter extends CustomPainter {
  final double nodeSize;
  final bool showLeft;
  final bool showRight;
  final double lineWidth;
  final Color color;

  SpouseConnectorPainter({
    required this.nodeSize,
    required this.showLeft,
    required this.showRight,
    required this.lineWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = nodeSize / 2;

    if (showLeft) {
      canvas.drawLine(
        Offset(0, centerY),
        Offset(lineWidth, centerY),
        paint,
      );
    }

    if (showRight) {
      canvas.drawLine(
        Offset(size.width - lineWidth, centerY),
        Offset(size.width, centerY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpouseConnectorPainter oldDelegate) {
    return nodeSize != oldDelegate.nodeSize ||
        showLeft != oldDelegate.showLeft ||
        showRight != oldDelegate.showRight ||
        color != oldDelegate.color;
  }
}

/// Painter for couple (two spouses) connection.
class CoupleLinePainter extends CustomPainter {
  final double nodeSize;
  final double spacing;
  final bool showAbove;
  final bool showBelow;
  final Color color;

  CoupleLinePainter({
    required this.nodeSize,
    required this.spacing,
    this.showAbove = false,
    this.showBelow = false,
    this.color = const Color(0xFF9747FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = nodeSize / 2;
    final centerX = size.width / 2;

    // Horizontal bridge between couple
    canvas.drawLine(
      Offset(centerX - (spacing / 2 + nodeSize / 2), centerY),
      Offset(centerX + (spacing / 2 + nodeSize / 2), centerY),
      paint,
    );

    if (showAbove) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, centerY), paint);
    }

    if (showBelow) {
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX, size.height + 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CoupleLinePainter oldDelegate) {
    return nodeSize != oldDelegate.nodeSize ||
        spacing != oldDelegate.spacing ||
        showAbove != oldDelegate.showAbove ||
        showBelow != oldDelegate.showBelow ||
        color != oldDelegate.color;
  }
}

/// Painter for multiple spouses connection (supports polygamy).
class MultipleSpousesLinePainter extends CustomPainter {
  final double nodeSize;
  final double spacing;
  final int memberCount;
  final bool showAbove;
  final bool showBelow;
  final Color color;

  MultipleSpousesLinePainter({
    required this.nodeSize,
    required this.spacing,
    required this.memberCount,
    this.showAbove = false,
    this.showBelow = false,
    this.color = const Color(0xFF9747FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = nodeSize / 2;
    final centerX = size.width / 2;

    // Calculate total width of all nodes and spacing
    final totalWidth = (nodeSize * memberCount) + (spacing * (memberCount - 1));
    final startX = (size.width - totalWidth) / 2;

    // Draw horizontal line connecting all members
    final firstNodeCenterX = startX + nodeSize / 2;
    final lastNodeCenterX = startX + totalWidth - nodeSize / 2;

    canvas.drawLine(
      Offset(firstNodeCenterX, centerY),
      Offset(lastNodeCenterX, centerY),
      paint,
    );

    if (showAbove) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, centerY), paint);
    }

    if (showBelow) {
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX, size.height + 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MultipleSpousesLinePainter oldDelegate) {
    return nodeSize != oldDelegate.nodeSize ||
        spacing != oldDelegate.spacing ||
        memberCount != oldDelegate.memberCount ||
        showAbove != oldDelegate.showAbove ||
        showBelow != oldDelegate.showBelow ||
        color != oldDelegate.color;
  }
}

/// Simple vertical tree connector.
class TreeConnector extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const TreeConnector({
    super.key,
    required this.height,
    required this.color,
    this.width = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}
