import 'package:flutter/material.dart';
import '../models/member_status.dart';

/// Complete theme configuration for GenealogyChart.
class GenealogyChartTheme {
  // Canvas styling
  /// Background color of the chart canvas.
  final Color backgroundColor;

  /// Grid line color (when grid is shown).
  final Color gridColor;

  /// Whether to show a grid background.
  final bool showGrid;

  /// Spacing between grid lines.
  final double gridSpacing;

  // Node styling
  /// Theme for node widgets.
  final NodeTheme nodeTheme;

  // Edge styling
  /// Theme for edge connectors.
  final EdgeTheme edgeTheme;

  // Selection styling
  /// Color for selected node highlight.
  final Color selectionColor;

  /// Width of selection ring.
  final double selectionWidth;

  /// Color for highlighted nodes (e.g., search results).
  final Color highlightColor;

  // Search styling
  /// Color for search result highlights.
  final Color searchResultColor;

  // Text styling
  /// Text style for member names.
  final TextStyle nameTextStyle;

  /// Text style for detail text (relationship, dates).
  final TextStyle detailTextStyle;

  const GenealogyChartTheme({
    this.backgroundColor = Colors.white,
    this.gridColor = const Color(0xFFEEEEEE),
    this.showGrid = false,
    this.gridSpacing = 50,
    this.nodeTheme = const NodeTheme(),
    this.edgeTheme = const EdgeTheme(),
    this.selectionColor = const Color(0xFF9747FF),
    this.selectionWidth = 3,
    this.highlightColor = const Color(0xFF9747FF),
    this.searchResultColor = const Color(0xFFFFEB3B),
    this.nameTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    this.detailTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
  });

  /// Pre-built light theme.
  static const light = GenealogyChartTheme();

  /// Pre-built dark theme.
  static const dark = GenealogyChartTheme(
    backgroundColor: Color(0xFF1A1A1A),
    gridColor: Color(0xFF333333),
    nodeTheme: NodeTheme.dark,
    edgeTheme: EdgeTheme.dark,
    nameTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    detailTextStyle: TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
  );

  /// Create a copy with updated values.
  GenealogyChartTheme copyWith({
    Color? backgroundColor,
    Color? gridColor,
    bool? showGrid,
    double? gridSpacing,
    NodeTheme? nodeTheme,
    EdgeTheme? edgeTheme,
    Color? selectionColor,
    double? selectionWidth,
    Color? highlightColor,
    Color? searchResultColor,
    TextStyle? nameTextStyle,
    TextStyle? detailTextStyle,
  }) {
    return GenealogyChartTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      showGrid: showGrid ?? this.showGrid,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      nodeTheme: nodeTheme ?? this.nodeTheme,
      edgeTheme: edgeTheme ?? this.edgeTheme,
      selectionColor: selectionColor ?? this.selectionColor,
      selectionWidth: selectionWidth ?? this.selectionWidth,
      highlightColor: highlightColor ?? this.highlightColor,
      searchResultColor: searchResultColor ?? this.searchResultColor,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      detailTextStyle: detailTextStyle ?? this.detailTextStyle,
    );
  }
}

/// Theme for node widgets.
class NodeTheme {
  /// Background color of node.
  final Color backgroundColor;

  /// Border color of node.
  final Color borderColor;

  /// Border width.
  final double borderWidth;

  /// Border radius (use high value for circle).
  final double borderRadius;

  /// Box shadow for node.
  final BoxShadow? shadow;

  /// Hover effect background color.
  final Color? hoverColor;

  /// Status indicator colors.
  final Map<MemberStatus, Color> statusColors;

  /// Badge background color.
  final Color badgeColor;

  /// Badge text color.
  final Color badgeTextColor;

  const NodeTheme({
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderWidth = 2,
    this.borderRadius = 50,
    this.shadow,
    this.hoverColor,
    this.statusColors = const {
      MemberStatus.currentUser: Color(0xFF9747FF),
      MemberStatus.online: Color(0xFF00BF4D),
      MemberStatus.offline: Color(0xFFB0B0B0),
      MemberStatus.deceased: Color(0xFFFF3E6C),
    },
    this.badgeColor = const Color(0xFF9747FF),
    this.badgeTextColor = Colors.white,
  });

  /// Dark mode node theme.
  static const dark = NodeTheme(
    backgroundColor: Color(0xFF2D2D2D),
    borderColor: Color(0xFF444444),
    hoverColor: Color(0xFF3D3D3D),
  );

  /// Get status color with fallback.
  Color getStatusColor(MemberStatus status) {
    return statusColors[status] ?? status.color;
  }

  NodeTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    BoxShadow? shadow,
    Color? hoverColor,
    Map<MemberStatus, Color>? statusColors,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return NodeTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      hoverColor: hoverColor ?? this.hoverColor,
      statusColors: statusColors ?? this.statusColors,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
    );
  }
}

/// Theme for edge connectors.
class EdgeTheme {
  /// Default line color.
  final Color lineColor;

  /// Line stroke width.
  final double lineWidth;

  /// Line style.
  final EdgeLineStyle lineStyle;

  /// Arrow style at edge ends.
  final ArrowStyle? arrowStyle;

  /// Color for spouse connection lines.
  final Color spouseLineColor;

  /// Color for parent-child connection lines.
  final Color parentChildLineColor;

  /// Color for sibling connection lines.
  final Color siblingLineColor;

  /// Color for highlighted/primary branch.
  final Color primaryBranchColor;

  /// Color for secondary branches.
  final Color secondaryBranchColor;

  const EdgeTheme({
    this.lineColor = const Color(0xFF9747FF),
    this.lineWidth = 2,
    this.lineStyle = EdgeLineStyle.solid,
    this.arrowStyle,
    this.spouseLineColor = const Color(0xFF9747FF),
    this.parentChildLineColor = const Color(0xFF9747FF),
    this.siblingLineColor = const Color(0xFF9747FF),
    this.primaryBranchColor = const Color(0xFF9747FF),
    this.secondaryBranchColor = const Color(0xFFB0B0B0),
  });

  /// Dark mode edge theme.
  static const dark = EdgeTheme(
    lineColor: Color(0xFF7B61FF),
    spouseLineColor: Color(0xFF7B61FF),
    parentChildLineColor: Color(0xFF7B61FF),
    siblingLineColor: Color(0xFF7B61FF),
    primaryBranchColor: Color(0xFF7B61FF),
    secondaryBranchColor: Color(0xFF666666),
  );

  EdgeTheme copyWith({
    Color? lineColor,
    double? lineWidth,
    EdgeLineStyle? lineStyle,
    ArrowStyle? arrowStyle,
    Color? spouseLineColor,
    Color? parentChildLineColor,
    Color? siblingLineColor,
    Color? primaryBranchColor,
    Color? secondaryBranchColor,
  }) {
    return EdgeTheme(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineStyle: lineStyle ?? this.lineStyle,
      arrowStyle: arrowStyle ?? this.arrowStyle,
      spouseLineColor: spouseLineColor ?? this.spouseLineColor,
      parentChildLineColor: parentChildLineColor ?? this.parentChildLineColor,
      siblingLineColor: siblingLineColor ?? this.siblingLineColor,
      primaryBranchColor: primaryBranchColor ?? this.primaryBranchColor,
      secondaryBranchColor: secondaryBranchColor ?? this.secondaryBranchColor,
    );
  }
}

/// Line style for edges.
enum EdgeLineStyle {
  solid,
  dashed,
  dotted,
}

/// Arrow style for edge endpoints.
class ArrowStyle {
  /// Type of arrow.
  final ArrowType type;

  /// Arrow size.
  final double size;

  /// Arrow color (overrides line color if set).
  final Color? color;

  const ArrowStyle({
    this.type = ArrowType.filled,
    this.size = 10,
    this.color,
  });
}

/// Arrow types for edges.
enum ArrowType {
  none,
  filled,
  open,
  diamond,
}

/// Theme provider widget for GenealogyChart.
class GenealogyChartThemeProvider extends InheritedWidget {
  /// The theme to provide.
  final GenealogyChartTheme theme;

  const GenealogyChartThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  /// Get the theme from context.
  static GenealogyChartTheme of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<GenealogyChartThemeProvider>();
    return provider?.theme ?? GenealogyChartTheme.light;
  }

  /// Get theme without listening to changes.
  static GenealogyChartTheme? maybeOf(BuildContext context) {
    final provider = context
        .getInheritedWidgetOfExactType<GenealogyChartThemeProvider>();
    return provider?.theme;
  }

  @override
  bool updateShouldNotify(GenealogyChartThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
