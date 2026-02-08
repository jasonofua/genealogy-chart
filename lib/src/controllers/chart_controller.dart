import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/graph_node.dart';

/// Events emitted by the chart controller.

/// Event when a node is selected.
class NodeSelectEvent<T> {
  final GraphNode<T> node;
  final bool isSelected;

  const NodeSelectEvent({
    required this.node,
    required this.isSelected,
  });
}

/// Event when a node is dropped (drag and drop).
class NodeDropEvent<T> {
  final GraphNode<T> draggedNode;
  final GraphNode<T>? targetNode;
  final DropRelation relation;
  final Offset dropPosition;

  const NodeDropEvent({
    required this.draggedNode,
    this.targetNode,
    required this.relation,
    required this.dropPosition,
  });
}

/// Relation for drop operations.
enum DropRelation {
  /// Make target the new parent.
  reparent,

  /// Make sibling of target.
  sibling,

  /// Make child of target.
  child,

  /// Reorder among siblings.
  reorder,

  /// No specific relation (drop on canvas).
  none,
}

/// Event when a node is collapsed/expanded.
class CollapseEvent<T> {
  final GraphNode<T> node;
  final bool isCollapsed;

  const CollapseEvent({
    required this.node,
    required this.isCollapsed,
  });
}

/// Image format for export.
enum ImageFormat {
  png,
  jpeg,
}

/// Main controller for chart state and interactions.
///
/// This is a framework-agnostic controller that uses ChangeNotifier
/// and Streams for state management.
class GenealogyChartController<T> extends ChangeNotifier {
  // === View State ===

  /// Transformation controller for pan/zoom.
  final TransformationController transformationController;

  double _scale = 1.0;

  /// Current zoom scale.
  double get scale => _scale;

  Offset _offset = Offset.zero;

  /// Current pan offset.
  Offset get offset => _offset;

  // === Node State ===

  final Set<String> _selectedNodes = {};
  final Set<String> _collapsedNodes = {};
  String? _highlightedNode;
  String? _hoveredNode;

  /// Currently selected node IDs.
  Set<String> get selectedNodes => Set.unmodifiable(_selectedNodes);

  /// Currently collapsed node IDs.
  Set<String> get collapsedNodes => Set.unmodifiable(_collapsedNodes);

  /// Currently highlighted node ID (e.g., from navigation).
  String? get highlightedNode => _highlightedNode;

  /// Currently hovered node ID.
  String? get hoveredNode => _hoveredNode;

  // === Search State ===

  String _searchQuery = '';
  List<String> _searchResults = [];
  int _currentSearchIndex = 0;

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Search result node IDs.
  List<String> get searchResults => List.unmodifiable(_searchResults);

  /// Current index in search results.
  int get currentSearchIndex => _currentSearchIndex;

  // === Event Streams ===

  final _nodeSelectController = StreamController<NodeSelectEvent<T>>.broadcast();
  final _nodeDropController = StreamController<NodeDropEvent<T>>.broadcast();
  final _collapseController = StreamController<CollapseEvent<T>>.broadcast();

  /// Stream of node selection events.
  Stream<NodeSelectEvent<T>> get onNodeSelect => _nodeSelectController.stream;

  /// Stream of node drop events.
  Stream<NodeDropEvent<T>> get onNodeDrop => _nodeDropController.stream;

  /// Stream of collapse/expand events.
  Stream<CollapseEvent<T>> get onCollapse => _collapseController.stream;

  // === Timer for highlight ===
  Timer? _highlightTimer;

  GenealogyChartController({
    TransformationController? transformationController,
  }) : transformationController =
            transformationController ?? TransformationController() {
    this.transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final matrix = transformationController.value;
    _scale = matrix.getMaxScaleOnAxis();
    _offset = Offset(matrix.entry(0, 3), matrix.entry(1, 3));
    notifyListeners();
  }

  // === View Controls ===

  /// Pan to center a specific node.
  void panToNode(
    String nodeId,
    Map<String, Offset> positions,
    Map<String, Size> nodeSizes, {
    bool animate = true,
    Size? viewportSize,
  }) {
    final pos = positions[nodeId];
    if (pos == null || viewportSize == null) return;

    final size = nodeSizes[nodeId] ?? const Size(100, 100);
    final nodeCenter = Offset(
      pos.dx + size.width / 2,
      pos.dy + size.height / 2,
    );

    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    final targetOffset = viewportCenter - nodeCenter * _scale;

    if (animate) {
      // Animate to position
      final currentMatrix = transformationController.value.clone();
      currentMatrix.setEntry(0, 3, targetOffset.dx);
      currentMatrix.setEntry(1, 3, targetOffset.dy);
      transformationController.value = currentMatrix;
    } else {
      final matrix = transformationController.value.clone();
      matrix.setEntry(0, 3, targetOffset.dx);
      matrix.setEntry(1, 3, targetOffset.dy);
      transformationController.value = matrix;
    }
  }

  /// Zoom to fit all nodes in the viewport.
  void zoomToFit(
    Map<String, Offset> positions,
    Map<String, Size> nodeSizes,
    Size viewportSize, {
    EdgeInsets padding = const EdgeInsets.all(50),
  }) {
    if (positions.isEmpty) return;

    // Calculate bounds
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

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    final availableWidth = viewportSize.width - padding.horizontal;
    final availableHeight = viewportSize.height - padding.vertical;

    final scaleX = availableWidth / contentWidth;
    final scaleY = availableHeight / contentHeight;
    final newScale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.1, 2.0);

    // Calculate offset to center
    final scaledContentWidth = contentWidth * newScale;
    final scaledContentHeight = contentHeight * newScale;

    final offsetX = (viewportSize.width - scaledContentWidth) / 2 - minX * newScale;
    final offsetY = (viewportSize.height - scaledContentHeight) / 2 - minY * newScale;

    final matrix = Matrix4.identity()
      ..scale(newScale)
      ..setEntry(0, 3, offsetX)
      ..setEntry(1, 3, offsetY);

    transformationController.value = matrix;
  }

  /// Zoom to a specific scale.
  void zoomTo(double newScale, {Offset? focalPoint}) {
    final clampedScale = newScale.clamp(0.1, 3.0);
    final matrix = transformationController.value.clone();

    // Scale from current
    final currentScale = _scale;
    final scaleFactor = clampedScale / currentScale;

    if (focalPoint != null) {
      // Scale around focal point
      matrix.translate(focalPoint.dx, focalPoint.dy);
      matrix.scale(scaleFactor);
      matrix.translate(-focalPoint.dx, -focalPoint.dy);
    } else {
      matrix.scale(scaleFactor);
    }

    transformationController.value = matrix;
  }

  /// Reset view to initial state (scale 1, no offset).
  void resetView() {
    transformationController.value = Matrix4.identity();
  }

  // === Selection ===

  /// Select a node.
  void selectNode(String nodeId, {bool addToSelection = false}) {
    if (!addToSelection) {
      _selectedNodes.clear();
    }
    _selectedNodes.add(nodeId);
    notifyListeners();
  }

  /// Deselect a node.
  void deselectNode(String nodeId) {
    _selectedNodes.remove(nodeId);
    notifyListeners();
  }

  /// Clear all selections.
  void clearSelection() {
    _selectedNodes.clear();
    notifyListeners();
  }

  /// Check if a node is selected.
  bool isSelected(String nodeId) => _selectedNodes.contains(nodeId);

  /// Highlight a node temporarily.
  void highlightNode(String nodeId, {Duration duration = const Duration(seconds: 3)}) {
    _highlightedNode = nodeId;
    _highlightTimer?.cancel();
    _highlightTimer = Timer(duration, () {
      _highlightedNode = null;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Clear highlight.
  void clearHighlight() {
    _highlightTimer?.cancel();
    _highlightedNode = null;
    notifyListeners();
  }

  /// Set hovered node.
  void setHoveredNode(String? nodeId) {
    if (_hoveredNode != nodeId) {
      _hoveredNode = nodeId;
      notifyListeners();
    }
  }

  // === Collapse/Expand ===

  /// Collapse a node's descendants.
  void collapse(String nodeId) {
    _collapsedNodes.add(nodeId);
    notifyListeners();
  }

  /// Expand a node's descendants.
  void expand(String nodeId) {
    _collapsedNodes.remove(nodeId);
    notifyListeners();
  }

  /// Toggle collapse state.
  void toggleCollapse(String nodeId) {
    if (_collapsedNodes.contains(nodeId)) {
      expand(nodeId);
    } else {
      collapse(nodeId);
    }
  }

  /// Collapse all nodes.
  void collapseAll(List<String> nodeIds) {
    _collapsedNodes.addAll(nodeIds);
    notifyListeners();
  }

  /// Expand all nodes.
  void expandAll() {
    _collapsedNodes.clear();
    notifyListeners();
  }

  /// Check if a node is collapsed.
  bool isCollapsed(String nodeId) => _collapsedNodes.contains(nodeId);

  // === Search ===

  /// Search for nodes matching a query.
  void search(String query, List<String> matchingNodeIds) {
    _searchQuery = query;
    _searchResults = matchingNodeIds;
    _currentSearchIndex = 0;
    notifyListeners();
  }

  /// Clear search.
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _currentSearchIndex = 0;
    notifyListeners();
  }

  /// Navigate to next search result.
  void nextSearchResult() {
    if (_searchResults.isEmpty) return;
    _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    notifyListeners();
  }

  /// Navigate to previous search result.
  void previousSearchResult() {
    if (_searchResults.isEmpty) return;
    _currentSearchIndex =
        (_currentSearchIndex - 1 + _searchResults.length) % _searchResults.length;
    notifyListeners();
  }

  /// Get current search result node ID.
  String? get currentSearchResult {
    if (_searchResults.isEmpty) return null;
    return _searchResults[_currentSearchIndex];
  }

  /// Check if a node is a search result.
  bool isSearchResult(String nodeId) => _searchResults.contains(nodeId);

  // === Event Emission ===

  /// Emit a node selection event.
  void emitNodeSelect(GraphNode<T> node, bool isSelected) {
    _nodeSelectController.add(NodeSelectEvent(
      node: node,
      isSelected: isSelected,
    ));
  }

  /// Emit a node drop event.
  void emitNodeDrop(
    GraphNode<T> draggedNode,
    GraphNode<T>? targetNode,
    DropRelation relation,
    Offset dropPosition,
  ) {
    _nodeDropController.add(NodeDropEvent(
      draggedNode: draggedNode,
      targetNode: targetNode,
      relation: relation,
      dropPosition: dropPosition,
    ));
  }

  /// Emit a collapse event.
  void emitCollapse(GraphNode<T> node, bool isCollapsed) {
    _collapseController.add(CollapseEvent(
      node: node,
      isCollapsed: isCollapsed,
    ));
  }

  // === Export ===

  /// Export chart as image.
  ///
  /// Requires a [repaintBoundaryKey] attached to a [RepaintBoundary]
  /// widget wrapping the chart content.
  ///
  /// Returns the image bytes, or null if export fails.
  Future<Uint8List?> exportImage({
    required GlobalKey repaintBoundaryKey,
    ImageFormat format = ImageFormat.png,
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(
        format: format == ImageFormat.png
            ? ui.ImageByteFormat.png
            : ui.ImageByteFormat.rawRgba,
      );
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _nodeSelectController.close();
    _nodeDropController.close();
    _collapseController.close();
    transformationController.removeListener(_onTransformChanged);
    super.dispose();
  }
}

/// State of a node for rendering.
class NodeState {
  final bool isSelected;
  final bool isHovered;
  final bool isDragging;
  final bool isHighlighted;
  final bool isCollapsed;
  final bool isSearchResult;
  final double scale;

  const NodeState({
    this.isSelected = false,
    this.isHovered = false,
    this.isDragging = false,
    this.isHighlighted = false,
    this.isCollapsed = false,
    this.isSearchResult = false,
    this.scale = 1.0,
  });

  NodeState copyWith({
    bool? isSelected,
    bool? isHovered,
    bool? isDragging,
    bool? isHighlighted,
    bool? isCollapsed,
    bool? isSearchResult,
    double? scale,
  }) {
    return NodeState(
      isSelected: isSelected ?? this.isSelected,
      isHovered: isHovered ?? this.isHovered,
      isDragging: isDragging ?? this.isDragging,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      scale: scale ?? this.scale,
    );
  }
}
