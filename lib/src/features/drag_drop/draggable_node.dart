import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../themes/chart_theme.dart';

/// Wrapper that makes a node draggable.
class DraggableNode extends StatefulWidget {
  /// The child widget to make draggable.
  final Widget child;

  /// The family member this node represents.
  final FamilyMember member;

  /// Whether dragging is enabled.
  final bool enabled;

  /// Custom feedback widget shown while dragging.
  final Widget? feedback;

  /// Widget shown in place of child while dragging.
  final Widget? childWhenDragging;

  /// Called when drag starts.
  final VoidCallback? onDragStarted;

  /// Called during drag with current position.
  final void Function(DragUpdateDetails)? onDragUpdate;

  /// Called when drag ends.
  final void Function(DraggableDetails)? onDragEnd;

  /// Called when drag is cancelled.
  final void Function(Velocity, Offset)? onDraggableCanceled;

  /// Axis to constrain dragging (null for free movement).
  final Axis? axis;

  /// Affinity for hit testing.
  final Axis? affinity;

  const DraggableNode({
    super.key,
    required this.child,
    required this.member,
    this.enabled = true,
    this.feedback,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDraggableCanceled,
    this.axis,
    this.affinity,
  });

  @override
  State<DraggableNode> createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<DraggableNode> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return Draggable<FamilyMember>(
      data: widget.member,
      axis: widget.axis,
      affinity: widget.affinity,
      onDragStarted: widget.onDragStarted,
      onDragUpdate: widget.onDragUpdate,
      onDragEnd: widget.onDragEnd,
      onDraggableCanceled: widget.onDraggableCanceled,
      feedback: widget.feedback ?? _buildDefaultFeedback(theme),
      childWhenDragging: widget.childWhenDragging ?? _buildChildWhenDragging(theme),
      child: widget.child,
    );
  }

  Widget _buildDefaultFeedback(GenealogyChartTheme theme) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.1,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.selectionColor.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Opacity(
            opacity: 0.9,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildChildWhenDragging(GenealogyChartTheme theme) {
    return Opacity(
      opacity: 0.3,
      child: widget.child,
    );
  }
}

/// Data transfer object for drag operations.
class DragData {
  /// The member being dragged.
  final FamilyMember member;

  /// Original position before drag.
  final Offset originalPosition;

  /// Type of drag operation.
  final DragOperationType operationType;

  const DragData({
    required this.member,
    required this.originalPosition,
    this.operationType = DragOperationType.move,
  });
}

/// Type of drag operation.
enum DragOperationType {
  /// Moving the node to a new position.
  move,

  /// Creating a copy of the node.
  copy,

  /// Creating a link/reference.
  link,
}
