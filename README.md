# Genealogy Chart

A powerful Flutter package for rendering interactive family trees and genealogy charts with pan, zoom, drag-drop, and beautiful pre-built node widgets.

## Features

- **Two rendering modes**: Generic graph mode for any tree/graph data, and family-specific mode optimized for genealogy
- **Pre-built node styles**: Circle avatar, card, compact, detailed, and memorial styles
- **Interactive**: Pan, zoom, double-tap zoom, node selection, and collapse/expand
- **Drag and drop**: Reparent, reorder, and link family members by dragging
- **Search**: Built-in search widget to find and navigate to members
- **Undo/redo**: Full undo/redo stack for edit operations
- **Theming**: Light and dark themes with full customization
- **Edge renderers**: Orthogonal, curved, and straight line connectors with dashed/dotted styles
- **Export**: Export chart as PNG image
- **Multiple spouses**: Supports polygamy and remarriage
- **Cross-family navigation**: Link members across different family trees
- **Memorial support**: Deceased member status with memorial styling

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  genealogy_chart:
    path: ../genealogy_chart  # or publish to pub.dev
```

## Usage

### Family Tree Mode

```dart
import 'package:genealogy_chart/genealogy_chart.dart';

GenealogyChart.family(
  members: [
    FamilyMember(
      id: 'father',
      name: 'John Smith',
      status: MemberStatus.online,
      generation: 0,
      spouseIds: ['mother'],
    ),
    FamilyMember(
      id: 'mother',
      name: 'Jane Smith',
      status: MemberStatus.online,
      generation: 0,
      spouseIds: ['father'],
    ),
    FamilyMember(
      id: 'child',
      name: 'Tom Smith',
      status: MemberStatus.currentUser,
      generation: 1,
      parentIds: ['father'],
    ),
  ],
  familyNodeStyle: FamilyNodeStyle.circleAvatar,
  onMemberTap: (member) => print('Tapped: ${member.name}'),
)
```

### Generic Graph Mode

```dart
GenealogyChart.graph(
  data: GraphData(
    nodes: [
      GraphNode(id: 'a', data: 'Node A'),
      GraphNode(id: 'b', data: 'Node B'),
    ],
    edges: [
      GraphEdge(sourceId: 'a', targetId: 'b'),
    ],
  ),
  layout: TreeLayout(),
  nodeBuilder: (context, node, state) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: state.isSelected ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(),
    ),
    child: Text(node.data),
  ),
)
```

### With Editing

```dart
final editController = FamilyEditController(
  initialMembers: members,
);

GenealogyChart.family(
  members: editController.members,
  editController: editController,
  enableDragDrop: true,
  onMemberDropped: (result) {
    print('Dropped ${result.droppedMember.name} on ${result.targetMember?.name}');
  },
)

// Add members
editController.addChild(newChild, parentId);
editController.addSpouse(newSpouse, memberId);

// Undo/redo
editController.undo();
editController.redo();
```

### Dark Theme

```dart
GenealogyChart.family(
  members: members,
  theme: GenealogyChartTheme.dark,
)
```

### Search

```dart
ChartSearchBar(
  controller: chartController,
  members: members,
  onResultSelected: (member) => print('Found: ${member.name}'),
)
```

## Node Styles

| Style | Description |
|-------|-------------|
| `circleAvatar` | Circular avatar with status indicator and name label |
| `card` | Card layout with avatar, name, and relationship badge |
| `compact` | Minimal circle with initials (for dense trees) |
| `detailed` | Card with lifespan dates |
| `memorial` | Card with lifespan (for deceased members) |

## Architecture

```
lib/src/
  models/         # Data models (FamilyMember, GraphNode, GraphEdge, etc.)
  controllers/    # State management (ChartController, EditController)
  layouts/        # Layout algorithms (TreeLayout, FamilyTreeLayout)
  widgets/        # Main widget, search bar, edit dialog
  nodes/          # Node rendering (prebuilt styles + custom builders)
  edges/          # Edge painters (orthogonal, curved, straight)
  themes/         # Theme system (light/dark + customization)
  features/       # Feature modules (drag-drop)
```

## Additional Information

- **Zero external dependencies** - built entirely on Flutter
- Supports Flutter 3.0+
- See the `/example` folder for complete working demos
