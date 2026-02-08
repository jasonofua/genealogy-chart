import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/family_member.dart';
import 'layout_algorithm.dart';

/// Layout algorithm optimized for family trees with generations.
///
/// This layout handles:
/// - Generation-based vertical positioning
/// - Multiple spouse support
/// - Centering children under parents
/// - Sibling ordering
class FamilyTreeLayout extends LayoutAlgorithm<FamilyMember> {
  @override
  final LayoutConfiguration configuration;

  /// Vertical spacing between generations.
  final double generationHeight;

  /// Horizontal spacing between siblings.
  final double siblingSpacing;

  /// Horizontal spacing between spouses.
  final double spouseSpacing;

  /// Spacing between family branches.
  final double branchSpacing;

  /// Whether to center the tree on the root/self.
  final bool centerOnRoot;

  /// Whether to compact generations with few members.
  final bool compactGenerations;

  /// Maximum depth of generations to render.
  ///
  /// Prevents performance issues with deeply nested trees.
  /// Set to null for unlimited depth. Defaults to 20.
  final int? maxDepth;

  FamilyTreeLayout({
    LayoutConfiguration? configuration,
    this.generationHeight = 150,
    this.siblingSpacing = 80,
    this.spouseSpacing = 40,
    this.branchSpacing = 120,
    this.centerOnRoot = true,
    this.compactGenerations = false,
    this.maxDepth = 20,
  }) : configuration = configuration ?? const LayoutConfiguration();

  @override
  Future<Map<String, Offset>> calculateLayout(
    List<GraphNode<FamilyMember>> nodes,
    List<GraphEdge> edges,
    Size canvasSize,
  ) async {
    if (nodes.isEmpty) return {};

    final positions = <String, Offset>{};

    // Build relationship maps
    final memberById = <String, FamilyMember>{};
    final nodeById = <String, GraphNode<FamilyMember>>{};
    for (final node in nodes) {
      memberById[node.id] = node.data;
      nodeById[node.id] = node;
    }

    // Group by generation, filtering by maxDepth
    final generations = <int, List<GraphNode<FamilyMember>>>{};
    for (final node in nodes) {
      final gen = node.data.generation;
      generations.putIfAbsent(gen, () => []).add(node);
    }

    // Sort generations
    final sortedGens = generations.keys.toList()..sort();

    // Apply depth limit if configured
    if (maxDepth != null && sortedGens.length > maxDepth!) {
      final truncatedGens = sortedGens.take(maxDepth!).toList();
      sortedGens
        ..clear()
        ..addAll(truncatedGens);
    }

    // Calculate positions for each generation
    for (final gen in sortedGens) {
      final genNodes = generations[gen]!;
      final y = _getGenerationY(gen, sortedGens);

      // Group spouses together
      final positioned = <String>{};
      var x = 0.0;

      for (final node in genNodes) {
        if (positioned.contains(node.id)) continue;

        final member = node.data;
        final spouseNodes = _getSpouseNodes(member, genNodes, positioned);

        if (spouseNodes.isNotEmpty) {
          // Position member and spouses together
          positions[node.id] = Offset(x, y);
          positioned.add(node.id);
          x += node.size.width + spouseSpacing;

          for (final spouse in spouseNodes) {
            positions[spouse.id] = Offset(x, y);
            positioned.add(spouse.id);
            x += spouse.size.width + spouseSpacing;
          }

          x += branchSpacing - spouseSpacing;
        } else {
          // Single node
          positions[node.id] = Offset(x, y);
          positioned.add(node.id);
          x += node.size.width + siblingSpacing;
        }
      }
    }

    // Center children under parents
    _adjustChildrenPositions(positions, nodes, memberById);

    // Center tree on canvas
    if (centerOnRoot) {
      _centerOnCanvas(positions, canvasSize, nodes);
    }

    // Apply padding
    _applyPadding(positions);

    return positions;
  }

  double _getGenerationY(int generation, List<int> sortedGens) {
    final genIndex = sortedGens.indexOf(generation);
    return genIndex * generationHeight;
  }

  List<GraphNode<FamilyMember>> _getSpouseNodes(
    FamilyMember member,
    List<GraphNode<FamilyMember>> genNodes,
    Set<String> positioned,
  ) {
    final spouses = <GraphNode<FamilyMember>>[];

    for (final spouseId in member.spouseIds) {
      if (positioned.contains(spouseId)) continue;

      final spouseNode = genNodes.firstWhere(
        (n) => n.id == spouseId,
        orElse: () => genNodes.first,
      );
      if (spouseNode.id == spouseId) {
        spouses.add(spouseNode);
      }
    }

    return spouses;
  }

  void _adjustChildrenPositions(
    Map<String, Offset> positions,
    List<GraphNode<FamilyMember>> nodes,
    Map<String, FamilyMember> memberById,
  ) {
    // Build parent-children map
    final childrenByParent = <String, List<String>>{};
    for (final node in nodes) {
      final member = node.data;
      for (final parentId in member.parentIds) {
        childrenByParent.putIfAbsent(parentId, () => []).add(node.id);
      }
    }

    // Process from bottom generations up
    final processedParents = <String>{};

    void centerParentOverChildren(String parentId) {
      if (processedParents.contains(parentId)) return;
      processedParents.add(parentId);

      final childIds = childrenByParent[parentId];
      if (childIds == null || childIds.isEmpty) return;

      // Get parent position
      final parentPos = positions[parentId];
      if (parentPos == null) return;

      // Calculate children's center X
      double minX = double.infinity;
      double maxX = double.negativeInfinity;

      for (final childId in childIds) {
        final childPos = positions[childId];
        if (childPos == null) continue;

        final childNode = nodes.firstWhere(
          (n) => n.id == childId,
          orElse: () => nodes.first,
        );
        if (childNode.id == childId) {
          minX = minX < childPos.dx ? minX : childPos.dx;
          maxX = maxX > childPos.dx + childNode.size.width
              ? maxX
              : childPos.dx + childNode.size.width;
        }
      }

      if (minX == double.infinity) return;

      // Get parent's spouse(s) to center the couple over children
      final parent = memberById[parentId];
      if (parent == null) return;

      final allSpouseIds = [parentId, ...parent.spouseIds];
      double parentMinX = double.infinity;
      double parentMaxX = double.negativeInfinity;

      for (final id in allSpouseIds) {
        final pos = positions[id];
        if (pos == null) continue;

        final node = nodes.firstWhere(
          (n) => n.id == id,
          orElse: () => nodes.first,
        );
        if (node.id == id) {
          parentMinX = parentMinX < pos.dx ? parentMinX : pos.dx;
          parentMaxX = parentMaxX > pos.dx + node.size.width
              ? parentMaxX
              : pos.dx + node.size.width;
        }
      }

      if (parentMinX == double.infinity) return;

      // Calculate offset to center
      final childrenCenter = (minX + maxX) / 2;
      final parentsCenter = (parentMinX + parentMaxX) / 2;
      final offset = childrenCenter - parentsCenter;

      // Move all parent spouses
      for (final id in allSpouseIds) {
        final pos = positions[id];
        if (pos != null) {
          positions[id] = Offset(pos.dx + offset, pos.dy);
        }
      }
    }

    // Center all parents over their children
    for (final parentId in childrenByParent.keys) {
      centerParentOverChildren(parentId);
    }
  }

  void _centerOnCanvas(
    Map<String, Offset> positions,
    Size canvasSize,
    List<GraphNode<FamilyMember>> nodes,
  ) {
    if (positions.isEmpty || !canvasSize.isFinite) return;

    // Find bounds
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final entry in positions.entries) {
      final pos = entry.value;
      final node = nodes.firstWhere(
        (n) => n.id == entry.key,
        orElse: () => nodes.first,
      );
      if (node.id == entry.key) {
        minX = minX < pos.dx ? minX : pos.dx;
        minY = minY < pos.dy ? minY : pos.dy;
        maxX = maxX > pos.dx + node.size.width ? maxX : pos.dx + node.size.width;
        maxY = maxY > pos.dy + node.size.height ? maxY : pos.dy + node.size.height;
      }
    }

    final treeWidth = maxX - minX;
    final treeHeight = maxY - minY;

    // Calculate offset to center
    final offsetX = (canvasSize.width - treeWidth) / 2 - minX;
    final offsetY = (canvasSize.height - treeHeight) / 2 - minY;

    // Apply offset
    for (final id in positions.keys.toList()) {
      final pos = positions[id]!;
      positions[id] = Offset(pos.dx + offsetX, pos.dy + offsetY);
    }
  }

  void _applyPadding(Map<String, Offset> positions) {
    // Normalize positions so minimum is at padding
    double minX = double.infinity;
    double minY = double.infinity;

    for (final pos in positions.values) {
      minX = minX < pos.dx ? minX : pos.dx;
      minY = minY < pos.dy ? minY : pos.dy;
    }

    final offsetX = configuration.padding.left - minX;
    final offsetY = configuration.padding.top - minY;

    for (final id in positions.keys.toList()) {
      final pos = positions[id]!;
      positions[id] = Offset(pos.dx + offsetX, pos.dy + offsetY);
    }
  }

  @override
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

      final sourceSize = nodeSizes[edge.sourceId] ?? const Size(80, 80);
      final targetSize = nodeSizes[edge.targetId] ?? const Size(80, 80);

      List<Offset> points;

      if (edge.type == EdgeType.spouse) {
        // Horizontal line between spouses
        final sourceRight = sourcePos.dx + sourceSize.width;
        final targetLeft = targetPos.dx;
        final y = sourcePos.dy + sourceSize.height / 2;

        points = [
          Offset(sourceRight, y),
          Offset(targetLeft, y),
        ];
      } else if (edge.type == EdgeType.parentChild) {
        // Orthogonal line from parent to child
        final sourceBottom = sourcePos.dy + sourceSize.height;
        final sourceCenter = sourcePos.dx + sourceSize.width / 2;
        final targetTop = targetPos.dy;
        final targetCenter = targetPos.dx + targetSize.width / 2;

        final midY = (sourceBottom + targetTop) / 2;

        points = [
          Offset(sourceCenter, sourceBottom),
          Offset(sourceCenter, midY),
          Offset(targetCenter, midY),
          Offset(targetCenter, targetTop),
        ];
      } else {
        // Default: straight line
        points = [
          Offset(
            sourcePos.dx + sourceSize.width / 2,
            sourcePos.dy + sourceSize.height / 2,
          ),
          Offset(
            targetPos.dx + targetSize.width / 2,
            targetPos.dy + targetSize.height / 2,
          ),
        ];
      }

      paths.add(EdgePath(
        edge: edge,
        points: points,
        showArrow: edge.type == EdgeType.directed,
      ));
    }

    return paths;
  }
}
