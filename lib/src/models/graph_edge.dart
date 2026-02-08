/// Type of edge connection.
enum EdgeType {
  /// One-way directed edge (arrow from source to target).
  directed,

  /// Two-way undirected edge (no arrows).
  undirected,

  /// Spouse/partner connection (horizontal line).
  spouse,

  /// Parent-child connection (vertical line with branch).
  parentChild,

  /// Sibling connection (horizontal line between siblings).
  sibling,
}

/// Represents a connection between two nodes.
class GraphEdge {
  /// Unique identifier for this edge.
  final String id;

  /// ID of the source node.
  final String sourceId;

  /// ID of the target node.
  final String targetId;

  /// Type of edge connection.
  final EdgeType type;

  /// Optional label to display on the edge.
  final String? label;

  /// Additional metadata for custom styling or behavior.
  final Map<String, dynamic> metadata;

  GraphEdge({
    String? id,
    required this.sourceId,
    required this.targetId,
    this.type = EdgeType.directed,
    this.label,
    this.metadata = const {},
  }) : id = id ?? '${sourceId}_$targetId';

  /// Create a copy with updated fields.
  GraphEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    EdgeType? type,
    String? label,
    Map<String, dynamic>? metadata,
  }) {
    return GraphEdge(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GraphEdge(id: $id, $sourceId -> $targetId, type: $type)';
}
