/// A powerful Flutter package for rendering family trees and genealogy charts.
///
/// This package provides two modes:
/// - **Generic graph mode**: For general-purpose tree/graph visualization
/// - **Family-specific mode**: Optimized for genealogy with generations, spouses, and relationships
///
/// ## Quick Start
///
/// ### Family Tree Mode
/// ```dart
/// GenealogyChart.family(
///   members: familyMembers,
///   familyNodeStyle: FamilyNodeStyle.circleAvatar,
///   onMemberTap: (member) => print('Tapped: ${member.name}'),
/// )
/// ```
///
/// ### Generic Graph Mode
/// ```dart
/// GenealogyChart.graph(
///   data: GraphData(nodes: nodes, edges: edges),
///   layout: TreeLayout(),
///   nodeBuilder: (context, node, state) => MyCustomNode(node),
/// )
/// ```
library;

// Core models
export 'src/models/graph_node.dart';
export 'src/models/graph_edge.dart';
export 'src/models/graph_data.dart';
export 'src/models/family_member.dart';
export 'src/models/family_relationship.dart';
export 'src/models/member_status.dart';

// Layout algorithms
export 'src/layouts/layout_algorithm.dart';
export 'src/layouts/family_tree_layout.dart';

// Controllers
export 'src/controllers/chart_controller.dart';
export 'src/controllers/edit_controller.dart';

// Themes
export 'src/themes/chart_theme.dart';

// Main widget
export 'src/widgets/genealogy_chart.dart';

// Node builders and prebuilt nodes
export 'src/nodes/node_builder.dart';
export 'src/nodes/prebuilt/circle_avatar_node.dart';
export 'src/nodes/prebuilt/card_node.dart';
export 'src/nodes/prebuilt/compact_node.dart';

// Edge painters
export 'src/edges/edge_painter.dart';
export 'src/edges/prebuilt/family_connectors.dart';

// Edit widgets
export 'src/widgets/member_edit_dialog.dart';

// Search widget
export 'src/widgets/search_bar.dart';

// Drag and drop
export 'src/features/drag_drop/draggable_node.dart';
export 'src/features/drag_drop/drop_target.dart' hide DropRelation;
export 'src/features/drag_drop/drag_feedback.dart';
