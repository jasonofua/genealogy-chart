import 'graph_node.dart';
import 'graph_edge.dart';

/// Container for graph data (nodes and edges).
///
/// This is the primary data structure for generic graph mode.
class GraphData<T> {
  /// All nodes in the graph.
  final List<GraphNode<T>> nodes;

  /// All edges connecting nodes.
  final List<GraphEdge> edges;

  const GraphData({
    required this.nodes,
    required this.edges,
  });

  /// Create an empty graph.
  const GraphData.empty()
      : nodes = const [],
        edges = const [];

  /// Create from an adjacency list representation.
  ///
  /// [adjacency] maps node IDs to lists of connected node IDs.
  /// [nodeFactory] creates the node data from an ID.
  factory GraphData.fromAdjacencyList(
    Map<String, List<String>> adjacency,
    T Function(String id) nodeFactory,
  ) {
    final nodes = <GraphNode<T>>[];
    final edges = <GraphEdge>[];
    final seenIds = <String>{};

    for (final entry in adjacency.entries) {
      final sourceId = entry.key;

      // Create source node if not seen
      if (!seenIds.contains(sourceId)) {
        nodes.add(GraphNode<T>(
          id: sourceId,
          data: nodeFactory(sourceId),
        ));
        seenIds.add(sourceId);
      }

      // Create edges and target nodes
      for (final targetId in entry.value) {
        if (!seenIds.contains(targetId)) {
          nodes.add(GraphNode<T>(
            id: targetId,
            data: nodeFactory(targetId),
          ));
          seenIds.add(targetId);
        }

        edges.add(GraphEdge(
          sourceId: sourceId,
          targetId: targetId,
        ));
      }
    }

    return GraphData(nodes: nodes, edges: edges);
  }

  /// Create from a parent-child map (tree structure).
  ///
  /// [parentChild] maps child IDs to their parent IDs (null for roots).
  /// [nodeFactory] creates the node data from an ID.
  factory GraphData.fromParentChild(
    Map<String, String?> parentChild,
    T Function(String id) nodeFactory,
  ) {
    final nodes = <GraphNode<T>>[];
    final edges = <GraphEdge>[];
    final seenIds = <String>{};

    for (final entry in parentChild.entries) {
      final childId = entry.key;
      final parentId = entry.value;

      // Create child node if not seen
      if (!seenIds.contains(childId)) {
        nodes.add(GraphNode<T>(
          id: childId,
          data: nodeFactory(childId),
          parentIds: parentId != null ? [parentId] : [],
        ));
        seenIds.add(childId);
      }

      // Create parent node and edge if parent exists
      if (parentId != null) {
        if (!seenIds.contains(parentId)) {
          nodes.add(GraphNode<T>(
            id: parentId,
            data: nodeFactory(parentId),
          ));
          seenIds.add(parentId);
        }

        edges.add(GraphEdge(
          sourceId: parentId,
          targetId: childId,
          type: EdgeType.parentChild,
        ));
      }
    }

    return GraphData(nodes: nodes, edges: edges);
  }

  /// Get a node by ID.
  GraphNode<T>? getNode(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all edges connected to a node.
  List<GraphEdge> getEdgesForNode(String nodeId) {
    return edges
        .where((e) => e.sourceId == nodeId || e.targetId == nodeId)
        .toList();
  }

  /// Get child nodes of a given node.
  List<GraphNode<T>> getChildren(String nodeId) {
    final childIds = edges
        .where((e) => e.sourceId == nodeId && e.type == EdgeType.parentChild)
        .map((e) => e.targetId)
        .toSet();

    return nodes.where((n) => childIds.contains(n.id)).toList();
  }

  /// Get parent nodes of a given node.
  List<GraphNode<T>> getParents(String nodeId) {
    final parentIds = edges
        .where((e) => e.targetId == nodeId && e.type == EdgeType.parentChild)
        .map((e) => e.sourceId)
        .toSet();

    return nodes.where((n) => parentIds.contains(n.id)).toList();
  }

  /// Get root nodes (nodes with no parents).
  List<GraphNode<T>> getRoots() {
    final childIds = edges
        .where((e) => e.type == EdgeType.parentChild)
        .map((e) => e.targetId)
        .toSet();

    return nodes.where((n) => !childIds.contains(n.id)).toList();
  }

  /// Create a copy with updated nodes and/or edges.
  GraphData<T> copyWith({
    List<GraphNode<T>>? nodes,
    List<GraphEdge>? edges,
  }) {
    return GraphData(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
    );
  }

  /// Add a node to the graph.
  GraphData<T> addNode(GraphNode<T> node) {
    return copyWith(nodes: [...nodes, node]);
  }

  /// Remove a node and its connected edges.
  GraphData<T> removeNode(String nodeId) {
    return copyWith(
      nodes: nodes.where((n) => n.id != nodeId).toList(),
      edges: edges
          .where((e) => e.sourceId != nodeId && e.targetId != nodeId)
          .toList(),
    );
  }

  /// Add an edge to the graph.
  GraphData<T> addEdge(GraphEdge edge) {
    return copyWith(edges: [...edges, edge]);
  }

  /// Remove an edge from the graph.
  GraphData<T> removeEdge(String edgeId) {
    return copyWith(edges: edges.where((e) => e.id != edgeId).toList());
  }

  @override
  String toString() =>
      'GraphData(nodes: ${nodes.length}, edges: ${edges.length})';
}
