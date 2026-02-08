import 'package:flutter/material.dart';
import '../../models/family_member.dart';

/// Relation type for drop operations.
enum DropRelation {
  /// Make the dragged node a child of this node.
  asChild,

  /// Make the dragged node a sibling of this node.
  asSibling,

  /// Make the dragged node a parent of this node.
  asParent,

  /// Make the dragged node a spouse of this node.
  asSpouse,

  /// Just reposition without changing relationships.
  reposition,
}

/// Result of a drop operation.
class DropResult {
  /// The member that was dropped.
  final FamilyMember droppedMember;

  /// The target member (if dropped on a node).
  final FamilyMember? targetMember;

  /// The relation to establish.
  final DropRelation relation;

  /// The drop position on the canvas.
  final Offset position;

  /// Whether the drop was accepted.
  final bool accepted;

  const DropResult({
    required this.droppedMember,
    this.targetMember,
    required this.relation,
    required this.position,
    this.accepted = true,
  });
}

/// A target zone that accepts dropped nodes.
class NodeDropTarget extends StatefulWidget {
  /// The child widget to wrap.
  final Widget child;

  /// The member this target represents (if any).
  final FamilyMember? member;

  /// Allowed drop relations for this target.
  final Set<DropRelation> allowedRelations;

  /// Called to determine if a drop should be accepted.
  final bool Function(FamilyMember dragged, FamilyMember? target)? canAccept;

  /// Called when a valid drop occurs.
  final void Function(DropResult)? onAccept;

  /// Called when drag enters this target.
  final void Function(FamilyMember)? onEnter;

  /// Called when drag leaves this target.
  final void Function(FamilyMember)? onLeave;

  /// Whether this target is enabled.
  final bool enabled;

  /// Visual indicator style when drag hovers.
  final DropTargetStyle style;

  const NodeDropTarget({
    super.key,
    required this.child,
    this.member,
    this.allowedRelations = const {DropRelation.asChild, DropRelation.asSibling},
    this.canAccept,
    this.onAccept,
    this.onEnter,
    this.onLeave,
    this.enabled = true,
    this.style = const DropTargetStyle(),
  });

  @override
  State<NodeDropTarget> createState() => _NodeDropTargetState();
}

class _NodeDropTargetState extends State<NodeDropTarget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    // Theme is available via widget.style or can be accessed if needed
    // final theme = GenealogyChartThemeProvider.maybeOf(context);

    return DragTarget<FamilyMember>(
      onWillAcceptWithDetails: (details) {
        final member = details.data;

        // Don't accept dropping on self
        if (widget.member != null && member.id == widget.member!.id) {
          return false;
        }

        // Check custom acceptance
        if (widget.canAccept != null) {
          return widget.canAccept!(member, widget.member);
        }

        return true;
      },
      onAcceptWithDetails: (details) {
        final member = details.data;

        setState(() {
          _isHovering = false;
        });

        // Determine the relation based on context
        final relation = _determineRelation(member);

        widget.onAccept?.call(DropResult(
          droppedMember: member,
          targetMember: widget.member,
          relation: relation,
          position: details.offset,
        ));
      },
      onMove: (details) {
        if (!_isHovering) {
          setState(() {
            _isHovering = true;
          });
          widget.onEnter?.call(details.data);
        }
      },
      onLeave: (data) {
        setState(() {
          _isHovering = false;
        });
        if (data != null) {
          widget.onLeave?.call(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isCandidate = candidateData.isNotEmpty;
        final isRejected = rejectedData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.style.borderRadius),
            border: _isHovering || isCandidate
                ? Border.all(
                    color: isRejected
                        ? widget.style.rejectedColor
                        : widget.style.acceptedColor,
                    width: widget.style.borderWidth,
                  )
                : null,
            color: _isHovering || isCandidate
                ? (isRejected
                    ? widget.style.rejectedColor.withOpacity(0.1)
                    : widget.style.acceptedColor.withOpacity(0.1))
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }

  DropRelation _determineRelation(FamilyMember dragged) {
    // If only one relation is allowed, use it
    if (widget.allowedRelations.length == 1) {
      return widget.allowedRelations.first;
    }

    // Default logic based on generations
    if (widget.member != null) {
      final targetGen = widget.member!.generation;
      final draggedGen = dragged.generation;

      if (draggedGen > targetGen) {
        return DropRelation.asChild;
      } else if (draggedGen < targetGen) {
        return DropRelation.asParent;
      } else {
        return DropRelation.asSibling;
      }
    }

    return DropRelation.reposition;
  }
}

/// Visual style for drop targets.
class DropTargetStyle {
  /// Color when drop is accepted.
  final Color acceptedColor;

  /// Color when drop is rejected.
  final Color rejectedColor;

  /// Border width when hovering.
  final double borderWidth;

  /// Border radius.
  final double borderRadius;

  const DropTargetStyle({
    this.acceptedColor = const Color(0xFF4CAF50),
    this.rejectedColor = const Color(0xFFF44336),
    this.borderWidth = 2,
    this.borderRadius = 8,
  });
}

/// A zone on the canvas that accepts drops for creating new nodes.
class CanvasDropZone extends StatefulWidget {
  /// The child widget (usually the canvas content).
  final Widget child;

  /// Called when a member is dropped on empty canvas space.
  final void Function(FamilyMember member, Offset position)? onDropOnCanvas;

  /// Whether dropping on canvas is enabled.
  final bool enabled;

  const CanvasDropZone({
    super.key,
    required this.child,
    this.onDropOnCanvas,
    this.enabled = true,
  });

  @override
  State<CanvasDropZone> createState() => _CanvasDropZoneState();
}

class _CanvasDropZoneState extends State<CanvasDropZone> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return DragTarget<FamilyMember>(
      onAcceptWithDetails: (details) {
        widget.onDropOnCanvas?.call(details.data, details.offset);
      },
      builder: (context, candidateData, rejectedData) {
        return widget.child;
      },
    );
  }
}
