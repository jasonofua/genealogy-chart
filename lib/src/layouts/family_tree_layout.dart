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

    // === Build lookup maps ===
    final nodeById = <String, GraphNode<FamilyMember>>{};
    final memberById = <String, FamilyMember>{};
    for (final node in nodes) {
      nodeById[node.id] = node;
      memberById[node.id] = node.data;
    }

    // Build parent→children map (from member.parentIds)
    final childrenOf = <String, List<String>>{};
    for (final node in nodes) {
      for (final parentId in node.data.parentIds) {
        if (nodeById.containsKey(parentId)) {
          childrenOf.putIfAbsent(parentId, () => []);
          if (!childrenOf[parentId]!.contains(node.id)) {
            childrenOf[parentId]!.add(node.id);
          }
        }
      }
    }

    // === Build spouse groups ===
    // A spouse group is a primary member + co-located spouses.
    final spouseGroupOf = <String, String>{}; // memberId → primaryId
    final spouseGroups = <String, List<String>>{}; // primaryId → [members]
    final claimed = <String>{};

    for (final node in nodes) {
      if (claimed.contains(node.id)) continue;
      final group = <String>[node.id];
      claimed.add(node.id);
      for (final spouseId in node.data.spouseIds) {
        if (!claimed.contains(spouseId) && nodeById.containsKey(spouseId)) {
          group.add(spouseId);
          claimed.add(spouseId);
        }
      }
      spouseGroups[node.id] = group;
      for (final id in group) {
        spouseGroupOf[id] = node.id;
      }
    }

    // === Collect child-groups for each spouse group ===
    // Children of ANY member in the group are the group's children.
    // Each child-group is assigned to exactly one parent-group.
    final groupChildren = <String, List<String>>{}; // primaryId → child primaryIds
    final childAssigned = <String>{};

    for (final primaryId in spouseGroups.keys) {
      final groupMemberIds = spouseGroups[primaryId]!;
      final childGroupIds = <String>[];

      for (final memberId in groupMemberIds) {
        for (final childId in (childrenOf[memberId] ?? [])) {
          final childGroupId = spouseGroupOf[childId];
          if (childGroupId == null) continue;
          if (childGroupId == primaryId) continue; // skip self
          if (childAssigned.contains(childGroupId)) continue;
          if (childGroupIds.contains(childGroupId)) continue;
          childGroupIds.add(childGroupId);
        }
      }

      if (childGroupIds.isNotEmpty) {
        groupChildren[primaryId] = childGroupIds;
        childAssigned.addAll(childGroupIds);
      }
    }

    // === Find root groups (not claimed as a child of any group) ===
    final rootGroups = <String>[];
    for (final primaryId in spouseGroups.keys) {
      if (!childAssigned.contains(primaryId)) {
        rootGroups.add(primaryId);
      }
    }

    // === Generation → Y mapping ===
    final genSet = <int>{};
    for (final node in nodes) {
      genSet.add(node.data.generation);
    }
    final sortedGens = genSet.toList()..sort();
    if (maxDepth != null && sortedGens.length > maxDepth!) {
      sortedGens.removeRange(maxDepth!, sortedGens.length);
    }

    // === Calculate the width of just the spouse group (no children) ===
    double getGroupWidth(String primaryId) {
      final group = spouseGroups[primaryId]!;
      double w = 0;
      for (int i = 0; i < group.length; i++) {
        w += nodeById[group[i]]!.size.width;
        if (i < group.length - 1) w += spouseSpacing;
      }
      return w;
    }

    // === Bottom-up: calculate subtree width for each group ===
    final subtreeWidths = <String, double>{};
    final computing = <String>{}; // cycle guard

    double calcSubtreeWidth(String primaryId) {
      if (subtreeWidths.containsKey(primaryId)) {
        return subtreeWidths[primaryId]!;
      }
      if (computing.contains(primaryId)) {
        // Cycle detected — treat as leaf
        final w = getGroupWidth(primaryId);
        subtreeWidths[primaryId] = w;
        return w;
      }
      computing.add(primaryId);

      final groupWidth = getGroupWidth(primaryId);
      final children = groupChildren[primaryId] ?? [];

      if (children.isEmpty) {
        subtreeWidths[primaryId] = groupWidth;
        return groupWidth;
      }

      double childrenTotalWidth = 0;
      for (int i = 0; i < children.length; i++) {
        childrenTotalWidth += calcSubtreeWidth(children[i]);
        if (i < children.length - 1) childrenTotalWidth += siblingSpacing;
      }

      final width =
          childrenTotalWidth > groupWidth ? childrenTotalWidth : groupWidth;
      subtreeWidths[primaryId] = width;
      return width;
    }

    for (final rootId in rootGroups) {
      calcSubtreeWidth(rootId);
    }

    // === Top-down: assign positions ===
    final positions = <String, Offset>{};

    void positionGroup(String primaryId, double leftX) {
      final group = spouseGroups[primaryId]!;
      final groupWidth = getGroupWidth(primaryId);
      final subtreeWidth = subtreeWidths[primaryId] ?? groupWidth;

      // Y from the generation of the first member in the group
      final gen = memberById[group.first]!.generation;
      final genIndex = sortedGens.indexOf(gen);
      if (genIndex < 0) return; // beyond maxDepth
      final y = genIndex * generationHeight;

      // Center the spouse group within its allocated subtree width
      final groupStartX = leftX + (subtreeWidth - groupWidth) / 2;
      double x = groupStartX;
      for (final memberId in group) {
        positions[memberId] = Offset(x, y);
        x += nodeById[memberId]!.size.width + spouseSpacing;
      }

      // Position child groups left-to-right within this subtree's allocation
      final children = groupChildren[primaryId] ?? [];
      double childX = leftX;
      for (final childGroupId in children) {
        positionGroup(childGroupId, childX);
        childX += (subtreeWidths[childGroupId] ?? 0) + siblingSpacing;
      }
    }

    double rootX = 0;
    for (final rootId in rootGroups) {
      positionGroup(rootId, rootX);
      rootX += (subtreeWidths[rootId] ?? 0) + branchSpacing;
    }

    // Center tree on canvas
    if (centerOnRoot) {
      _centerOnCanvas(positions, canvasSize, nodes);
    }

    // Apply padding
    _applyPadding(positions);

    return positions;
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
        // Horizontal line between spouses — always draw from left node's
        // right edge to right node's left edge, regardless of source/target
        // ordering in the edge data.
        final bool sourceIsLeft = sourcePos.dx <= targetPos.dx;
        final leftPos = sourceIsLeft ? sourcePos : targetPos;
        final rightPos = sourceIsLeft ? targetPos : sourcePos;
        final leftSize = sourceIsLeft ? sourceSize : targetSize;
        final leftRight = leftPos.dx + leftSize.width;
        final rightLeft = rightPos.dx;
        final y = leftPos.dy + leftSize.height / 2;

        points = [
          Offset(leftRight, y),
          Offset(rightLeft, y),
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
