import 'package:flutter/material.dart';

/// A generic node in the graph/tree structure.
///
/// This is the base class for all nodes in both generic graph mode
/// and family-specific mode. It wraps your custom data type [T].
class GraphNode<T> {
  /// Unique identifier for this node.
  final String id;

  /// The custom data associated with this node.
  final T data;

  /// Computed position by the layout algorithm.
  Offset position;

  /// Size of the node widget (computed during layout).
  Size size;

  /// Whether this node's descendants are collapsed.
  bool isCollapsed;

  /// Additional metadata for custom use cases.
  final Map<String, dynamic> metadata;

  /// Parent node IDs (for tree structures).
  final List<String> parentIds;

  /// Child node IDs.
  final List<String> childIds;

  GraphNode({
    required this.id,
    required this.data,
    this.position = Offset.zero,
    this.size = const Size(100, 100),
    this.isCollapsed = false,
    this.metadata = const {},
    this.parentIds = const [],
    this.childIds = const [],
  });

  /// Create a copy with updated fields.
  GraphNode<T> copyWith({
    String? id,
    T? data,
    Offset? position,
    Size? size,
    bool? isCollapsed,
    Map<String, dynamic>? metadata,
    List<String>? parentIds,
    List<String>? childIds,
  }) {
    return GraphNode<T>(
      id: id ?? this.id,
      data: data ?? this.data,
      position: position ?? this.position,
      size: size ?? this.size,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      metadata: metadata ?? this.metadata,
      parentIds: parentIds ?? this.parentIds,
      childIds: childIds ?? this.childIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode<T> &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GraphNode<$T>(id: $id, position: $position)';
}
