import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';

/// Orientation of the tree layout.
enum TreeOrientation {
  /// Root at top, descendants below.
  topToBottom,

  /// Root at bottom, ancestors above.
  bottomToTop,

  /// Root at left, descendants to right.
  leftToRight,

  /// Root at right, descendants to left.
  rightToLeft,
}

/// Configuration for layout algorithms.
class LayoutConfiguration {
  /// Orientation of the tree.
  final TreeOrientation orientation;

  /// Horizontal spacing between sibling nodes.
  final double nodeSpacing;

  /// Vertical spacing between generations/levels.
  final double levelSpacing;

  /// Padding around the entire tree.
  final EdgeInsets padding;

  /// Whether to animate layout changes.
  final bool animated;

  /// Duration of layout animations.
  final Duration animationDuration;

  /// Animation curve for layout transitions.
  final Curve animationCurve;

  const LayoutConfiguration({
    this.orientation = TreeOrientation.topToBottom,
    this.nodeSpacing = 60,
    this.levelSpacing = 100,
    this.padding = const EdgeInsets.all(50),
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  LayoutConfiguration copyWith({
    TreeOrientation? orientation,
    double? nodeSpacing,
    double? levelSpacing,
    EdgeInsets? padding,
    bool? animated,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return LayoutConfiguration(
      orientation: orientation ?? this.orientation,
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      levelSpacing: levelSpacing ?? this.levelSpacing,
      padding: padding ?? this.padding,
      animated: animated ?? this.animated,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}

/// Represents a calculated edge path for rendering.
class EdgePath {
  /// The edge this path represents.
  final GraphEdge edge;

  /// Path points from source to target.
  final List<Offset> points;

  /// Optional control points for curves.
  final List<Offset>? controlPoints;

  /// Whether to draw an arrow at the end.
  final bool showArrow;

  const EdgePath({
    required this.edge,
    required this.points,
    this.controlPoints,
    this.showArrow = false,
  });
}

/// Base class for all layout algorithms.
///
/// Implement this class to create custom layout algorithms.
abstract class LayoutAlgorithm<T> {
  /// Get the configuration for this layout.
  LayoutConfiguration get configuration;

  /// Calculate positions for all nodes.
  ///
  /// [nodes] - List of nodes to position.
  /// [edges] - Connections between nodes.
  /// [canvasSize] - Available canvas size.
  ///
  /// Returns a map of node ID to position (top-left corner of node).
  Future<Map<String, Offset>> calculateLayout(
    List<GraphNode<T>> nodes,
    List<GraphEdge> edges,
    Size canvasSize,
  );

  /// Incrementally update layout when nodes change.
  ///
  /// Override this for more efficient updates on small changes.
  Future<Map<String, Offset>> updateLayout(
    Map<String, Offset> currentPositions,
    List<GraphNode<T>> nodes,
    List<GraphEdge> edges,
  ) async {
    // Default: recalculate entire layout
    return calculateLayout(
      nodes,
      edges,
      Size.infinite,
    );
  }

  /// Calculate edge paths for rendering.
  ///
  /// [positions] - Calculated node positions.
  /// [edges] - Edges to calculate paths for.
  /// [nodeSizes] - Size of each node widget.
  List<EdgePath> calculateEdgePaths(
    Map<String, Offset> positions,
    List<GraphEdge> edges,
    Map<String, Size> nodeSizes,
  ) {
    final paths = <EdgePath>[];

    for (final edge in edges) {
      final sourcePos = positions[edge.sourceId];
      final targetPos = positions[edge.targetId];

      if (sourcePos == null || targetPos == null) continue;

      final sourceSize = nodeSizes[edge.sourceId] ?? const Size(100, 100);
      final targetSize = nodeSizes[edge.targetId] ?? const Size(100, 100);

      // Calculate center points
      final sourceCenter = Offset(
        sourcePos.dx + sourceSize.width / 2,
        sourcePos.dy + sourceSize.height / 2,
      );
      final targetCenter = Offset(
        targetPos.dx + targetSize.width / 2,
        targetPos.dy + targetSize.height / 2,
      );

      // Calculate connection points based on orientation
      final points = _calculateConnectionPoints(
        sourceCenter,
        targetCenter,
        sourceSize,
        targetSize,
        edge.type,
      );

      paths.add(EdgePath(
        edge: edge,
        points: points,
        showArrow: edge.type == EdgeType.directed,
      ));
    }

    return paths;
  }

  /// Calculate connection points between nodes.
  List<Offset> _calculateConnectionPoints(
    Offset sourceCenter,
    Offset targetCenter,
    Size sourceSize,
    Size targetSize,
    EdgeType type,
  ) {
    switch (configuration.orientation) {
      case TreeOrientation.topToBottom:
        return [
          Offset(sourceCenter.dx, sourceCenter.dy + sourceSize.height / 2),
          Offset(targetCenter.dx, targetCenter.dy - targetSize.height / 2),
        ];
      case TreeOrientation.bottomToTop:
        return [
          Offset(sourceCenter.dx, sourceCenter.dy - sourceSize.height / 2),
          Offset(targetCenter.dx, targetCenter.dy + targetSize.height / 2),
        ];
      case TreeOrientation.leftToRight:
        return [
          Offset(sourceCenter.dx + sourceSize.width / 2, sourceCenter.dy),
          Offset(targetCenter.dx - targetSize.width / 2, targetCenter.dy),
        ];
      case TreeOrientation.rightToLeft:
        return [
          Offset(sourceCenter.dx - sourceSize.width / 2, sourceCenter.dy),
          Offset(targetCenter.dx + targetSize.width / 2, targetCenter.dy),
        ];
    }
  }

  /// Get the total bounds of all positioned nodes.
  Rect getBounds(Map<String, Offset> positions, Map<String, Size> nodeSizes) {
    if (positions.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final entry in positions.entries) {
      final pos = entry.value;
      final size = nodeSizes[entry.key] ?? const Size(100, 100);

      minX = minX < pos.dx ? minX : pos.dx;
      minY = minY < pos.dy ? minY : pos.dy;
      maxX = maxX > pos.dx + size.width ? maxX : pos.dx + size.width;
      maxY = maxY > pos.dy + size.height ? maxY : pos.dy + size.height;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// A simple tree layout algorithm (Buchheim-style).
class TreeLayout<T> extends LayoutAlgorithm<T> {
  @override
  final LayoutConfiguration configuration;

  /// Maximum depth of levels to render.
  ///
  /// Prevents performance issues with deeply nested trees.
  /// Set to null for unlimited depth. Defaults to 20.
  final int? maxDepth;

  TreeLayout({
    this.configuration = const LayoutConfiguration(),
    this.maxDepth = 20,
  });

  @override
  Future<Map<String, Offset>> calculateLayout(
    List<GraphNode<T>> nodes,
    List<GraphEdge> edges,
    Size canvasSize,
  ) async {
    if (nodes.isEmpty) return {};

    final positions = <String, Offset>{};

    // Build adjacency map
    final children = <String, List<String>>{};
    final parents = <String, String>{};

    for (final edge in edges) {
      children.putIfAbsent(edge.sourceId, () => []).add(edge.targetId);
      parents[edge.targetId] = edge.sourceId;
    }

    // Find roots (nodes without parents)
    final roots = nodes.where((n) => !parents.containsKey(n.id)).toList();
    if (roots.isEmpty && nodes.isNotEmpty) {
      // Fallback: use first node as root
      roots.add(nodes.first);
    }

    // Calculate levels
    final levels = <int, List<GraphNode<T>>>{};
    final nodeLevel = <String, int>{};

    void assignLevel(GraphNode<T> node, int level) {
      // Enforce depth limit
      if (maxDepth != null && level >= maxDepth!) return;

      nodeLevel[node.id] = level;
      levels.putIfAbsent(level, () => []).add(node);

      final childIds = children[node.id] ?? [];
      for (final childId in childIds) {
        final child = nodes.firstWhere(
          (n) => n.id == childId,
          orElse: () => node,
        );
        if (child.id != node.id && !nodeLevel.containsKey(child.id)) {
          assignLevel(child, level + 1);
        }
      }
    }

    for (final root in roots) {
      assignLevel(root, 0);
    }

    // Position nodes
    final isVertical = configuration.orientation == TreeOrientation.topToBottom ||
        configuration.orientation == TreeOrientation.bottomToTop;

    for (final entry in levels.entries) {
      final level = entry.key;
      final levelNodes = entry.value;
      final levelOffset = level * configuration.levelSpacing;

      for (int i = 0; i < levelNodes.length; i++) {
        final node = levelNodes[i];
        final nodeOffset = i * (node.size.width + configuration.nodeSpacing);

        if (isVertical) {
          final y = configuration.orientation == TreeOrientation.topToBottom
              ? levelOffset
              : canvasSize.height - levelOffset - node.size.height;
          positions[node.id] = Offset(nodeOffset, y);
        } else {
          final x = configuration.orientation == TreeOrientation.leftToRight
              ? levelOffset
              : canvasSize.width - levelOffset - node.size.width;
          positions[node.id] = Offset(x, nodeOffset);
        }
      }
    }

    // Center children under parents
    _centerChildrenUnderParents(positions, nodes, children);

    // Apply padding
    _applyPadding(positions);

    return positions;
  }

  void _centerChildrenUnderParents(
    Map<String, Offset> positions,
    List<GraphNode<T>> nodes,
    Map<String, List<String>> children,
  ) {
    // Simple centering: center parent over children
    final processed = <String>{};

    void centerParent(String parentId) {
      if (processed.contains(parentId)) return;
      processed.add(parentId);

      final childIds = children[parentId] ?? [];
      if (childIds.isEmpty) return;

      // First center all children recursively
      for (final childId in childIds) {
        centerParent(childId);
      }

      // Calculate center of children
      double minX = double.infinity;
      double maxX = double.negativeInfinity;

      for (final childId in childIds) {
        final childPos = positions[childId];
        if (childPos != null) {
          final childNode = nodes.firstWhere((n) => n.id == childId);
          minX = minX < childPos.dx ? minX : childPos.dx;
          maxX = maxX > childPos.dx + childNode.size.width
              ? maxX
              : childPos.dx + childNode.size.width;
        }
      }

      if (minX != double.infinity) {
        final parentPos = positions[parentId];
        final parentNode = nodes.firstWhere((n) => n.id == parentId);
        if (parentPos != null) {
          final centerX = (minX + maxX) / 2 - parentNode.size.width / 2;
          positions[parentId] = Offset(centerX, parentPos.dy);
        }
      }
    }

    // Center all root nodes over their children
    for (final nodeId in children.keys) {
      centerParent(nodeId);
    }
  }

  void _applyPadding(Map<String, Offset> positions) {
    for (final entry in positions.entries) {
      positions[entry.key] = Offset(
        entry.value.dx + configuration.padding.left,
        entry.value.dy + configuration.padding.top,
      );
    }
  }
}
