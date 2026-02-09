import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_data.dart';
import '../models/family_member.dart';
import '../layouts/layout_algorithm.dart';
import '../layouts/family_tree_layout.dart';
import '../controllers/chart_controller.dart';
import '../controllers/edit_controller.dart';
import '../themes/chart_theme.dart';
import '../nodes/node_builder.dart';
import '../nodes/prebuilt/circle_avatar_node.dart';
import '../nodes/prebuilt/card_node.dart';
import '../nodes/prebuilt/compact_node.dart';
import '../edges/edge_painter.dart';
import '../features/drag_drop/draggable_node.dart';
import '../features/drag_drop/drop_target.dart' as dnd;

/// Main genealogy chart widget.
///
/// Supports two modes:
/// - Generic graph mode: Use [GenealogyChart.graph] constructor
/// - Family-specific mode: Use [GenealogyChart.family] constructor
class GenealogyChart<T> extends StatefulWidget {
  // Data
  final GraphData<T>? graphData;
  final List<FamilyMember>? familyMembers;
  final String? rootMemberId;

  // Layout
  final LayoutAlgorithm<T>? layout;
  final LayoutAlgorithm<FamilyMember>? familyLayout;

  // Node rendering
  final NodeBuilder<T>? nodeBuilder;
  final FamilyNodeBuilder? familyNodeBuilder;
  final FamilyNodeStyle familyNodeStyle;

  // Controller
  final GenealogyChartController<T>? controller;
  final GenealogyChartController<FamilyMember>? familyController;

  // Interaction callbacks - Generic
  final void Function(GraphNode<T>)? onNodeTap;
  final void Function(GraphNode<T>)? onNodeLongPress;
  final void Function(GraphNode<T>)? onNodeDoubleTap;

  // Interaction callbacks - Family
  final void Function(FamilyMember)? onMemberTap;
  final void Function(FamilyMember)? onMemberLongPress;
  final void Function(FamilyMember)? onAddChild;
  final void Function(FamilyMember)? onAddSpouse;
  final void Function(FamilyMember)? onAddParent;

  // Edit callbacks - Family
  final void Function(FamilyMember)? onMemberEdit;
  final void Function(FamilyMember)? onMemberDelete;
  final void Function(FamilyMember, FamilyMember)? onMemberUpdated;
  final void Function(dnd.DropResult)? onMemberDropped;
  final bool Function(FamilyMember dragged, FamilyMember? target)? canDropMember;

  // Edit controller
  final FamilyEditController? editController;

  // Features
  final bool enablePan;
  final bool enableZoom;
  final bool enableDoubleTapZoom;
  final bool enableDragDrop;
  final bool enableCollapse;
  final bool enableSearch;

  // View constraints
  final double minScale;
  final double maxScale;
  final EdgeInsets boundaryMargin;

  // Theme
  final GenealogyChartTheme? theme;

  // Loading/empty states
  final Widget? loadingWidget;
  final Widget? emptyWidget;

  // Mode flag
  final bool _isFamilyMode;

  /// Generic graph mode constructor.
  const GenealogyChart.graph({
    super.key,
    required GraphData<T> data,
    LayoutAlgorithm<T>? layout,
    this.nodeBuilder,
    this.controller,
    this.onNodeTap,
    this.onNodeLongPress,
    this.onNodeDoubleTap,
    this.enablePan = true,
    this.enableZoom = true,
    this.enableDoubleTapZoom = true,
    this.enableDragDrop = false,
    this.enableCollapse = true,
    this.enableSearch = false,
    this.minScale = 0.1,
    this.maxScale = 3.0,
    this.boundaryMargin = const EdgeInsets.all(1000),
    this.theme,
    this.loadingWidget,
    this.emptyWidget,
  })  : graphData = data,
        this.layout = layout,
        familyMembers = null,
        rootMemberId = null,
        familyLayout = null,
        familyNodeBuilder = null,
        familyNodeStyle = FamilyNodeStyle.circleAvatar,
        familyController = null,
        editController = null,
        onMemberTap = null,
        onMemberLongPress = null,
        onAddChild = null,
        onAddSpouse = null,
        onAddParent = null,
        onMemberEdit = null,
        onMemberDelete = null,
        onMemberUpdated = null,
        onMemberDropped = null,
        canDropMember = null,
        _isFamilyMode = false;

  /// Family-specific mode constructor.
  const GenealogyChart.family({
    super.key,
    required List<FamilyMember> members,
    this.rootMemberId,
    LayoutAlgorithm<FamilyMember>? layout,
    this.familyNodeBuilder,
    this.familyNodeStyle = FamilyNodeStyle.circleAvatar,
    this.familyController,
    this.editController,
    this.onMemberTap,
    this.onMemberLongPress,
    this.onAddChild,
    this.onAddSpouse,
    this.onAddParent,
    this.onMemberEdit,
    this.onMemberDelete,
    this.onMemberUpdated,
    this.onMemberDropped,
    this.canDropMember,
    this.enablePan = true,
    this.enableZoom = true,
    this.enableDoubleTapZoom = true,
    this.enableDragDrop = false,
    this.enableCollapse = true,
    this.enableSearch = true,
    this.minScale = 0.1,
    this.maxScale = 2.5,
    this.boundaryMargin = const EdgeInsets.all(1000),
    this.theme,
    this.loadingWidget,
    this.emptyWidget,
  })  : familyMembers = members,
        familyLayout = layout,
        graphData = null,
        layout = null,
        nodeBuilder = null,
        controller = null,
        onNodeTap = null,
        onNodeLongPress = null,
        onNodeDoubleTap = null,
        _isFamilyMode = true;

  @override
  State<GenealogyChart<T>> createState() => _GenealogyChartState<T>();
}

class _GenealogyChartState<T> extends State<GenealogyChart<T>> {
  late GenealogyChartController _effectiveController;
  Map<String, Offset> _positions = {};
  Map<String, Size> _nodeSizes = {};
  bool _isLayoutComputed = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget._isFamilyMode
        ? (widget.familyController ?? GenealogyChartController<FamilyMember>())
        : (widget.controller ?? GenealogyChartController<T>());

    _computeLayout();
  }

  @override
  void didUpdateWidget(GenealogyChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recompute layout if data changed
    if (widget._isFamilyMode) {
      if (widget.familyMembers != oldWidget.familyMembers) {
        _computeLayout();
      }
    } else {
      if (widget.graphData != oldWidget.graphData) {
        _computeLayout();
      }
    }
  }

  Future<void> _computeLayout() async {
    if (widget._isFamilyMode) {
      await _computeFamilyLayout();
    } else {
      await _computeGraphLayout();
    }
  }

  Future<void> _computeFamilyLayout() async {
    final members = widget.familyMembers;
    if (members == null || members.isEmpty) {
      setState(() {
        _positions = {};
        _isLayoutComputed = true;
      });
      return;
    }

    // Convert to graph nodes
    final nodes = members
        .map((m) => GraphNode<FamilyMember>(
              id: m.id,
              data: m,
              size: _getNodeSize(m),
            ))
        .toList();

    // Build edges from relationships
    final edges = <GraphEdge>[];
    final memberSet = <String>{};
    for (final m in members) {
      memberSet.add(m.id);
    }
    for (final member in members) {
      // Parent-child edges
      for (final parentId in member.parentIds) {
        edges.add(GraphEdge(
          sourceId: parentId,
          targetId: member.id,
          type: EdgeType.parentChild,
        ));
      }
    }

    // Spouse edges: connect adjacent members in spouse groups
    final spouseClaimed = <String>{};
    for (final member in members) {
      if (spouseClaimed.contains(member.id)) continue;
      final group = <String>[member.id];
      spouseClaimed.add(member.id);
      for (final spouseId in member.spouseIds) {
        if (!spouseClaimed.contains(spouseId) &&
            memberSet.contains(spouseId)) {
          group.add(spouseId);
          spouseClaimed.add(spouseId);
        }
      }
      for (int i = 0; i < group.length - 1; i++) {
        edges.add(GraphEdge(
          sourceId: group[i],
          targetId: group[i + 1],
          type: EdgeType.spouse,
        ));
      }
    }

    // Compute layout
    final layout = widget.familyLayout ?? FamilyTreeLayout();
    final positions = await layout.calculateLayout(
      nodes,
      edges,
      const Size(2000, 2000), // Default canvas size
    );

    // Store node sizes
    final sizes = <String, Size>{};
    for (final node in nodes) {
      sizes[node.id] = node.size;
    }

    setState(() {
      _positions = positions;
      _nodeSizes = sizes;
      _isLayoutComputed = true;
    });
  }

  Future<void> _computeGraphLayout() async {
    final graphData = widget.graphData;
    if (graphData == null || graphData.nodes.isEmpty) {
      setState(() {
        _positions = {};
        _isLayoutComputed = true;
      });
      return;
    }

    final layout = widget.layout ?? TreeLayout<T>();
    final positions = await layout.calculateLayout(
      graphData.nodes,
      graphData.edges,
      const Size(2000, 2000),
    );

    final sizes = <String, Size>{};
    for (final node in graphData.nodes) {
      sizes[node.id] = node.size;
    }

    setState(() {
      _positions = positions;
      _nodeSizes = sizes;
      _isLayoutComputed = true;
    });
  }

  Size _getNodeSize(FamilyMember member) {
    switch (widget.familyNodeStyle) {
      case FamilyNodeStyle.circleAvatar:
        return const Size(100, 130);
      case FamilyNodeStyle.card:
        return const Size(160, 140);
      case FamilyNodeStyle.compact:
        return const Size(60, 60);
      case FamilyNodeStyle.detailed:
        return const Size(180, 160);
      case FamilyNodeStyle.memorial:
        return const Size(120, 150);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartTheme = widget.theme ?? GenealogyChartTheme.light;

    return GenealogyChartThemeProvider(
      theme: chartTheme,
      child: Container(
        color: chartTheme.backgroundColor,
        child: _buildContent(chartTheme),
      ),
    );
  }

  Widget _buildContent(GenealogyChartTheme chartTheme) {
    if (!_isLayoutComputed) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_positions.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.family_restroom, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No family members yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTap: widget.enableDoubleTapZoom
              ? () {
                  final currentScale = _effectiveController.scale;
                  final targetScale = currentScale < 1.5 ? 2.0 : 1.0;
                  _effectiveController.zoomTo(targetScale);
                }
              : null,
          child: InteractiveViewer(
            transformationController:
                _effectiveController.transformationController,
            constrained: false,
            boundaryMargin: widget.boundaryMargin,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            panEnabled: widget.enablePan && !_isDragging,
            scaleEnabled: widget.enableZoom,
            child: SizedBox(
              width: _getContentWidth(),
              height: _getContentHeight(),
              child: Stack(
                children: [
                  // Grid background (optional)
                  if (chartTheme.showGrid) _buildGrid(chartTheme),

                  // Edges layer
                  _buildEdges(chartTheme),

                  // Nodes layer
                  ..._buildNodes(chartTheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getContentWidth() {
    if (_positions.isEmpty) return 1000;
    double maxX = 0;
    for (final entry in _positions.entries) {
      final pos = entry.value;
      final size = _nodeSizes[entry.key] ?? const Size(100, 100);
      if (pos.dx + size.width > maxX) {
        maxX = pos.dx + size.width;
      }
    }
    return maxX + 100;
  }

  double _getContentHeight() {
    if (_positions.isEmpty) return 1000;
    double maxY = 0;
    for (final entry in _positions.entries) {
      final pos = entry.value;
      final size = _nodeSizes[entry.key] ?? const Size(100, 100);
      if (pos.dy + size.height > maxY) {
        maxY = pos.dy + size.height;
      }
    }
    return maxY + 100;
  }

  Widget _buildGrid(GenealogyChartTheme theme) {
    return CustomPaint(
      size: Size(_getContentWidth(), _getContentHeight()),
      painter: _GridPainter(
        color: theme.gridColor,
        spacing: theme.gridSpacing,
      ),
    );
  }

  Widget _buildEdges(GenealogyChartTheme theme) {
    // Build edge paths
    final edges = <GraphEdge>[];

    if (widget._isFamilyMode && widget.familyMembers != null) {
      final members = widget.familyMembers!;
      final memberSet = <String>{};
      for (final m in members) {
        memberSet.add(m.id);
      }

      // Parent-child edges
      for (final member in members) {
        for (final parentId in member.parentIds) {
          edges.add(GraphEdge(
            sourceId: parentId,
            targetId: member.id,
            type: EdgeType.parentChild,
          ));
        }
      }

      // Spouse edges: build groups of adjacent spouses and connect
      // consecutive members so lines don't pass through intermediate nodes.
      final spouseClaimed = <String>{};
      for (final member in members) {
        if (spouseClaimed.contains(member.id)) continue;
        final group = <String>[member.id];
        spouseClaimed.add(member.id);
        for (final spouseId in member.spouseIds) {
          if (!spouseClaimed.contains(spouseId) &&
              memberSet.contains(spouseId)) {
            group.add(spouseId);
            spouseClaimed.add(spouseId);
          }
        }
        // Connect consecutive members in the group
        for (int i = 0; i < group.length - 1; i++) {
          edges.add(GraphEdge(
            sourceId: group[i],
            targetId: group[i + 1],
            type: EdgeType.spouse,
          ));
        }
      }
    } else if (widget.graphData != null) {
      edges.addAll(widget.graphData!.edges);
    }

    final layout = widget._isFamilyMode
        ? (widget.familyLayout ?? FamilyTreeLayout())
        : (widget.layout ?? TreeLayout<T>());

    final edgePaths = layout.calculateEdgePaths(_positions, edges, _nodeSizes);

    return CustomPaint(
      size: Size(_getContentWidth(), _getContentHeight()),
      painter: OrthogonalEdgePainter(
        paths: edgePaths,
        theme: theme.edgeTheme,
      ),
    );
  }

  List<Widget> _buildNodes(GenealogyChartTheme theme) {
    if (widget._isFamilyMode) {
      return _buildFamilyNodes(theme);
    } else {
      return _buildGraphNodes(theme);
    }
  }

  List<Widget> _buildFamilyNodes(GenealogyChartTheme theme) {
    final members = widget.familyMembers;
    if (members == null) return [];

    return members.map((member) {
      final pos = _positions[member.id];
      if (pos == null) return const SizedBox.shrink();

      final nodeState = NodeState(
        isSelected: _effectiveController.isSelected(member.id),
        isHighlighted: _effectiveController.highlightedNode == member.id,
        isHovered: _effectiveController.hoveredNode == member.id,
        isCollapsed: _effectiveController.isCollapsed(member.id),
        isSearchResult: _effectiveController.isSearchResult(member.id),
        scale: _effectiveController.scale,
      );

      Widget nodeWidget;

      if (widget.familyNodeBuilder != null) {
        nodeWidget = widget.familyNodeBuilder!(context, member, nodeState);
      } else {
        nodeWidget = _buildPrebuiltFamilyNode(member, nodeState, theme);
      }

      // Wrap with drag-drop if enabled
      if (widget.enableDragDrop) {
        nodeWidget = _wrapWithDragDrop(nodeWidget, member, theme);
      }

      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: MouseRegion(
          onEnter: (_) => _effectiveController.setHoveredNode(member.id),
          onExit: (_) => _effectiveController.setHoveredNode(null),
          child: nodeWidget,
        ),
      );
    }).toList();
  }

  Widget _wrapWithDragDrop(Widget child, FamilyMember member, GenealogyChartTheme theme) {
    return dnd.NodeDropTarget(
      member: member,
      allowedRelations: const {
        dnd.DropRelation.asChild,
        dnd.DropRelation.asSibling,
        dnd.DropRelation.asSpouse,
      },
      canAccept: widget.canDropMember,
      onAccept: (result) {
        widget.onMemberDropped?.call(result);

        // If edit controller is provided, handle the drop
        if (widget.editController != null && result.targetMember != null) {
          switch (result.relation) {
            case dnd.DropRelation.asChild:
              widget.editController!.reparentMember(
                result.droppedMember.id,
                result.targetMember!.id,
              );
              break;
            case dnd.DropRelation.asSibling:
              widget.editController!.makeSiblings(
                result.droppedMember.id,
                result.targetMember!.id,
              );
              break;
            case dnd.DropRelation.asSpouse:
              widget.editController!.addSpouse(
                result.droppedMember,
                result.targetMember!.id,
              );
              break;
            case dnd.DropRelation.asParent:
            case dnd.DropRelation.reposition:
              // Handle positioning separately
              break;
          }
          // Recompute layout so positions update immediately after drop
          _computeLayout();
        }
      },
      style: dnd.DropTargetStyle(
        acceptedColor: theme.selectionColor,
        rejectedColor: Colors.red,
      ),
      child: DraggableNode(
        member: member,
        enabled: true,
        onDragStarted: () {
          setState(() => _isDragging = true);
          _effectiveController.selectNode(member.id);
        },
        onDragEnd: (_) {
          setState(() => _isDragging = false);
        },
        onDraggableCanceled: (_, __) {
          setState(() => _isDragging = false);
        },
        child: child,
      ),
    );
  }

  Widget _buildPrebuiltFamilyNode(
    FamilyMember member,
    NodeState state,
    GenealogyChartTheme theme,
  ) {
    switch (widget.familyNodeStyle) {
      case FamilyNodeStyle.circleAvatar:
        return CircleAvatarNode(
          member: member,
          state: state,
          onTap: () => _handleMemberTap(member),
          onLongPress: () => _handleMemberLongPress(member),
        );
      case FamilyNodeStyle.card:
        return CardNode(
          member: member,
          state: state,
          onTap: () => _handleMemberTap(member),
          onLongPress: () => _handleMemberLongPress(member),
        );
      case FamilyNodeStyle.compact:
        return CompactNode(
          member: member,
          state: state,
          onTap: () => _handleMemberTap(member),
        );
      case FamilyNodeStyle.detailed:
        return CardNode(
          member: member,
          state: state,
          showLifespan: true,
          onTap: () => _handleMemberTap(member),
          onLongPress: () => _handleMemberLongPress(member),
        );
      case FamilyNodeStyle.memorial:
        return CardNode(
          member: member,
          state: state,
          showLifespan: true,
          onTap: () => _handleMemberTap(member),
        );
    }
  }

  List<Widget> _buildGraphNodes(GenealogyChartTheme theme) {
    final data = widget.graphData;
    if (data == null) return [];

    return data.nodes.map((node) {
      final pos = _positions[node.id];
      if (pos == null) return const SizedBox.shrink();

      final nodeState = NodeState(
        isSelected: _effectiveController.isSelected(node.id),
        isHighlighted: _effectiveController.highlightedNode == node.id,
        isHovered: _effectiveController.hoveredNode == node.id,
        isCollapsed: _effectiveController.isCollapsed(node.id),
        isSearchResult: _effectiveController.isSearchResult(node.id),
        scale: _effectiveController.scale,
      );

      Widget nodeWidget;

      if (widget.nodeBuilder != null) {
        nodeWidget = widget.nodeBuilder!(context, node, nodeState);
      } else {
        // Default node
        nodeWidget = Container(
          width: node.size.width,
          height: node.size.height,
          decoration: BoxDecoration(
            color: theme.nodeTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: nodeState.isSelected
                  ? theme.selectionColor
                  : theme.nodeTheme.borderColor,
              width: nodeState.isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            node.id,
            style: theme.nameTextStyle,
          ),
        );
      }

      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: GestureDetector(
          onTap: () => widget.onNodeTap?.call(node),
          onLongPress: () => widget.onNodeLongPress?.call(node),
          onDoubleTap: () => widget.onNodeDoubleTap?.call(node),
          child: MouseRegion(
            onEnter: (_) => _effectiveController.setHoveredNode(node.id),
            onExit: (_) => _effectiveController.setHoveredNode(null),
            child: nodeWidget,
          ),
        ),
      );
    }).toList();
  }

  void _handleMemberTap(FamilyMember member) {
    _effectiveController.selectNode(member.id);
    widget.onMemberTap?.call(member);
  }

  void _handleMemberLongPress(FamilyMember member) {
    widget.onMemberLongPress?.call(member);
  }

  @override
  void dispose() {
    // Only dispose controller if we created it
    if (widget._isFamilyMode && widget.familyController == null) {
      _effectiveController.dispose();
    } else if (!widget._isFamilyMode && widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }
}

/// Grid background painter.
class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return color != oldDelegate.color || spacing != oldDelegate.spacing;
  }
}
