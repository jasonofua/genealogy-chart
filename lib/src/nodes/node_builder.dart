import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/family_member.dart';
import '../controllers/chart_controller.dart';

/// Type definition for custom node builders.
///
/// Use this to build completely custom node widgets.
typedef NodeBuilder<T> = Widget Function(
  BuildContext context,
  GraphNode<T> node,
  NodeState state,
);

/// Type definition for family-specific node builders.
typedef FamilyNodeBuilder = Widget Function(
  BuildContext context,
  FamilyMember member,
  NodeState state,
);

/// Pre-built family node styles.
enum FamilyNodeStyle {
  /// Circular avatar with status indicator.
  circleAvatar,

  /// Card layout with details.
  card,

  /// Minimal compact view.
  compact,

  /// Full details view.
  detailed,

  /// Memorial style for deceased.
  memorial,
}
