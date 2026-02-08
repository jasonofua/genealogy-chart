import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genealogy_chart/genealogy_chart.dart';

void main() {
  // ============================
  // FamilyMember Model Tests
  // ============================
  group('FamilyMember', () {
    test('creates with required fields', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
      );

      expect(member.id, 'test-1');
      expect(member.name, 'John Doe');
      expect(member.status, MemberStatus.offline);
      expect(member.generation, 0);
      expect(member.parentIds, isEmpty);
      expect(member.spouseIds, isEmpty);
      expect(member.childrenIds, isEmpty);
    });

    test('calculates age correctly for living member', () {
      final member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        birthDate: DateTime(1990, 1, 1),
      );

      expect(member.age, isNotNull);
      expect(member.age! >= 34, isTrue);
    });

    test('calculates age at death for deceased member', () {
      final member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        birthDate: DateTime(1920, 1, 1),
        deathDate: DateTime(1985, 6, 15),
        status: MemberStatus.deceased,
      );

      expect(member.age, 65);
      expect(member.isDeceased, isTrue);
    });

    test('returns null age when no birth date', () {
      const member = FamilyMember(id: 'test-1', name: 'John Doe');
      expect(member.age, isNull);
    });

    test('detects multiple spouses', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        spouseIds: ['spouse-1', 'spouse-2'],
      );

      expect(member.hasMultipleSpouses, isTrue);
    });

    test('single spouse is not multiple', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        spouseIds: ['spouse-1'],
      );

      expect(member.hasMultipleSpouses, isFalse);
    });

    test('detects deceased status', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        status: MemberStatus.deceased,
      );

      expect(member.isDeceased, isTrue);
    });

    test('detects current user', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        status: MemberStatus.currentUser,
      );

      expect(member.isCurrentUser, isTrue);
      expect(member.isDeceased, isFalse);
    });

    test('lifespan returns correct string', () {
      final member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        birthDate: DateTime(1920, 1, 1),
        deathDate: DateTime(1985, 6, 15),
      );

      expect(member.lifespan, '1920 - 1985');
    });

    test('lifespan for living member shows Present', () {
      final member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        birthDate: DateTime(1990, 1, 1),
      );

      expect(member.lifespan, '1990 - Present');
    });

    test('displayName returns first name if available', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        firstName: 'Johnny',
      );

      expect(member.displayName, 'Johnny');
    });

    test('displayName falls back to first part of name', () {
      const member = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
      );

      expect(member.displayName, 'John');
    });

    test('serializes to JSON and back', () {
      final original = FamilyMember(
        id: 'test-1',
        name: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        status: MemberStatus.online,
        relationship: FamilyRelationship.father,
        generation: 1,
        parentIds: ['parent-1'],
        spouseIds: ['spouse-1'],
        childrenIds: ['child-1'],
        birthDate: DateTime(1980, 5, 15),
        bio: 'Test bio',
        location: 'New York',
        isFatherSide: true,
      );

      final json = original.toJson();
      final restored = FamilyMember.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.status, original.status);
      expect(restored.relationship, original.relationship);
      expect(restored.generation, original.generation);
      expect(restored.parentIds, original.parentIds);
      expect(restored.spouseIds, original.spouseIds);
      expect(restored.childrenIds, original.childrenIds);
      expect(restored.bio, original.bio);
      expect(restored.location, original.location);
    });

    test('fromJson handles missing fields gracefully', () {
      final member = FamilyMember.fromJson({'id': 'test'});

      expect(member.id, 'test');
      expect(member.name, 'Unknown');
      expect(member.status, MemberStatus.offline);
      expect(member.parentIds, isEmpty);
    });

    test('fromJson handles empty map', () {
      final member = FamilyMember.fromJson({});

      expect(member.id, '');
      expect(member.name, 'Unknown');
    });

    test('copyWith creates modified copy', () {
      const original = FamilyMember(id: 'test', name: 'John');
      final copy = original.copyWith(name: 'Jane', generation: 2);

      expect(copy.id, 'test');
      expect(copy.name, 'Jane');
      expect(copy.generation, 2);
    });

    test('equality based on id', () {
      const a = FamilyMember(id: 'test', name: 'John');
      const b = FamilyMember(id: 'test', name: 'Jane');
      const c = FamilyMember(id: 'other', name: 'John');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hasLinkedFamily detects linked families', () {
      const member = FamilyMember(
        id: 'test',
        name: 'John',
        birthFamilyId: 'family-1',
      );

      expect(member.hasLinkedFamily, isTrue);
    });
  });

  // ============================
  // GraphNode Tests
  // ============================
  group('GraphNode', () {
    test('creates with data', () {
      final node = GraphNode<String>(
        id: 'node-1',
        data: 'Test Data',
      );

      expect(node.id, 'node-1');
      expect(node.data, 'Test Data');
      expect(node.isCollapsed, isFalse);
      expect(node.position, Offset.zero);
      expect(node.size, const Size(100, 100));
    });

    test('copyWith creates modified copy', () {
      final original = GraphNode<String>(
        id: 'node-1',
        data: 'Test Data',
      );

      final modified = original.copyWith(
        isCollapsed: true,
        position: const Offset(10, 20),
      );

      expect(modified.id, original.id);
      expect(modified.data, original.data);
      expect(modified.isCollapsed, isTrue);
      expect(modified.position, const Offset(10, 20));
    });

    test('equality based on id', () {
      final a = GraphNode<String>(id: 'node-1', data: 'A');
      final b = GraphNode<String>(id: 'node-1', data: 'B');
      final c = GraphNode<String>(id: 'node-2', data: 'A');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ============================
  // GraphEdge Tests
  // ============================
  group('GraphEdge', () {
    test('creates with source and target', () {
      final edge = GraphEdge(
        sourceId: 'node-1',
        targetId: 'node-2',
      );

      expect(edge.sourceId, 'node-1');
      expect(edge.targetId, 'node-2');
      expect(edge.type, EdgeType.directed);
    });

    test('generates ID from source and target', () {
      final edge = GraphEdge(sourceId: 'a', targetId: 'b');
      expect(edge.id, 'a_b');
    });

    test('uses custom ID when provided', () {
      final edge = GraphEdge(
        id: 'custom',
        sourceId: 'a',
        targetId: 'b',
      );
      expect(edge.id, 'custom');
    });

    test('copyWith creates modified copy', () {
      final original = GraphEdge(sourceId: 'a', targetId: 'b');
      final copy = original.copyWith(type: EdgeType.spouse);

      expect(copy.sourceId, 'a');
      expect(copy.targetId, 'b');
      expect(copy.type, EdgeType.spouse);
    });
  });

  // ============================
  // GraphData Tests
  // ============================
  group('GraphData', () {
    test('empty constructor creates empty graph', () {
      const data = GraphData<String>.empty();
      expect(data.nodes, isEmpty);
      expect(data.edges, isEmpty);
    });

    test('getNode returns correct node', () {
      final data = GraphData<String>(
        nodes: [
          GraphNode(id: 'a', data: 'A'),
          GraphNode(id: 'b', data: 'B'),
        ],
        edges: [],
      );

      expect(data.getNode('a')?.data, 'A');
      expect(data.getNode('b')?.data, 'B');
      expect(data.getNode('c'), isNull);
    });

    test('getChildren returns child nodes', () {
      final data = GraphData<String>(
        nodes: [
          GraphNode(id: 'parent', data: 'P'),
          GraphNode(id: 'child1', data: 'C1'),
          GraphNode(id: 'child2', data: 'C2'),
        ],
        edges: [
          GraphEdge(sourceId: 'parent', targetId: 'child1', type: EdgeType.parentChild),
          GraphEdge(sourceId: 'parent', targetId: 'child2', type: EdgeType.parentChild),
        ],
      );

      final children = data.getChildren('parent');
      expect(children.length, 2);
      expect(children.map((n) => n.id), containsAll(['child1', 'child2']));
    });

    test('getParents returns parent nodes', () {
      final data = GraphData<String>(
        nodes: [
          GraphNode(id: 'parent', data: 'P'),
          GraphNode(id: 'child', data: 'C'),
        ],
        edges: [
          GraphEdge(sourceId: 'parent', targetId: 'child', type: EdgeType.parentChild),
        ],
      );

      final parents = data.getParents('child');
      expect(parents.length, 1);
      expect(parents.first.id, 'parent');
    });

    test('getRoots returns nodes without parents', () {
      final data = GraphData<String>(
        nodes: [
          GraphNode(id: 'root', data: 'R'),
          GraphNode(id: 'child', data: 'C'),
        ],
        edges: [
          GraphEdge(sourceId: 'root', targetId: 'child', type: EdgeType.parentChild),
        ],
      );

      final roots = data.getRoots();
      expect(roots.length, 1);
      expect(roots.first.id, 'root');
    });

    test('addNode adds to graph', () {
      const data = GraphData<String>.empty();
      final updated = data.addNode(GraphNode(id: 'new', data: 'New'));

      expect(updated.nodes.length, 1);
      expect(data.nodes.length, 0); // original unchanged
    });

    test('removeNode removes node and edges', () {
      final data = GraphData<String>(
        nodes: [
          GraphNode(id: 'a', data: 'A'),
          GraphNode(id: 'b', data: 'B'),
        ],
        edges: [
          GraphEdge(sourceId: 'a', targetId: 'b'),
        ],
      );

      final updated = data.removeNode('a');
      expect(updated.nodes.length, 1);
      expect(updated.edges.length, 0);
    });

    test('fromParentChild builds correct graph', () {
      final data = GraphData<String>.fromParentChild(
        {'child1': 'root', 'child2': 'root', 'root': null},
        (id) => id,
      );

      expect(data.nodes.length, 3);
      expect(data.edges.length, 2);
      expect(data.getRoots().length, 1);
    });
  });

  // ============================
  // MemberStatus Tests
  // ============================
  group('MemberStatus', () {
    test('has correct colors', () {
      expect(MemberStatus.currentUser.color, const Color(0xFF9747FF));
      expect(MemberStatus.online.color, const Color(0xFF00BF4D));
      expect(MemberStatus.offline.color, const Color(0xFFB0B0B0));
      expect(MemberStatus.deceased.color, const Color(0xFFFF3E6C));
    });

    test('isAlive returns correct values', () {
      expect(MemberStatus.online.isAlive, isTrue);
      expect(MemberStatus.currentUser.isAlive, isTrue);
      expect(MemberStatus.offline.isAlive, isTrue);
      expect(MemberStatus.deceased.isAlive, isFalse);
    });

    test('has correct labels', () {
      expect(MemberStatus.currentUser.label, 'You');
      expect(MemberStatus.online.label, 'Online');
      expect(MemberStatus.offline.label, 'Offline');
      expect(MemberStatus.deceased.label, 'Deceased');
    });
  });

  // ============================
  // FamilyRelationship Tests
  // ============================
  group('FamilyRelationship', () {
    test('has correct generation offsets', () {
      expect(FamilyRelationship.greatGrandfather.generationOffset, -2);
      expect(FamilyRelationship.grandfather.generationOffset, -1);
      expect(FamilyRelationship.father.generationOffset, -1);
      expect(FamilyRelationship.self.generationOffset, 0);
      expect(FamilyRelationship.spouse.generationOffset, 0);
      expect(FamilyRelationship.son.generationOffset, 1);
      expect(FamilyRelationship.grandson.generationOffset, 2);
    });

    test('isSpouse detects spouse relationships', () {
      expect(FamilyRelationship.spouse.isSpouse, isTrue);
      expect(FamilyRelationship.exSpouse.isSpouse, isTrue);
      expect(FamilyRelationship.father.isSpouse, isFalse);
    });

    test('isParent detects parent relationships', () {
      expect(FamilyRelationship.father.isParent, isTrue);
      expect(FamilyRelationship.mother.isParent, isTrue);
      expect(FamilyRelationship.stepfather.isParent, isTrue);
      expect(FamilyRelationship.son.isParent, isFalse);
    });

    test('isChild detects child relationships', () {
      expect(FamilyRelationship.son.isChild, isTrue);
      expect(FamilyRelationship.daughter.isChild, isTrue);
      expect(FamilyRelationship.adoptedSon.isChild, isTrue);
      expect(FamilyRelationship.father.isChild, isFalse);
    });

    test('isSibling detects sibling relationships', () {
      expect(FamilyRelationship.brother.isSibling, isTrue);
      expect(FamilyRelationship.sister.isSibling, isTrue);
      expect(FamilyRelationship.halfBrother.isSibling, isTrue);
      expect(FamilyRelationship.father.isSibling, isFalse);
    });

    test('has correct labels', () {
      expect(FamilyRelationship.father.label, 'Father');
      expect(FamilyRelationship.motherInLaw.label, 'Mother-in-Law');
      expect(FamilyRelationship.halfBrother.label, 'Half Brother');
    });
  });

  // ============================
  // FamilyEditController Tests
  // ============================
  group('FamilyEditController', () {
    late FamilyEditController controller;

    setUp(() {
      controller = FamilyEditController(
        initialMembers: [
          const FamilyMember(
            id: 'root',
            name: 'Root',
            generation: 0,
            childrenIds: ['child1'],
          ),
          const FamilyMember(
            id: 'child1',
            name: 'Child 1',
            generation: 1,
            parentIds: ['root'],
          ),
        ],
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with members', () {
      expect(controller.members.length, 2);
      expect(controller.getMember('root')?.name, 'Root');
    });

    test('addMember adds to list', () {
      controller.addMember(
        const FamilyMember(id: 'new', name: 'New Member', generation: 0),
      );

      expect(controller.members.length, 3);
      expect(controller.getMember('new')?.name, 'New Member');
    });

    test('addChild sets parent relationship', () {
      const child = FamilyMember(id: 'child2', name: 'Child 2');
      controller.addChild(child, 'root');

      final added = controller.getMember('child2');
      expect(added, isNotNull);
      expect(added!.parentIds, contains('root'));
      expect(added.generation, 1);
    });

    test('addSpouse links both members', () {
      const spouse = FamilyMember(id: 'spouse', name: 'Spouse');
      controller.addSpouse(spouse, 'root');

      final addedSpouse = controller.getMember('spouse');
      final root = controller.getMember('root');

      expect(addedSpouse, isNotNull);
      expect(addedSpouse!.spouseIds, contains('root'));
      expect(root!.spouseIds, contains('spouse'));
    });

    test('updateMember modifies existing member', () {
      final member = controller.getMember('child1')!;
      controller.updateMember(member.copyWith(name: 'Updated Child'));

      expect(controller.getMember('child1')?.name, 'Updated Child');
    });

    test('updateMemberName updates name', () {
      controller.updateMemberName('child1', 'New Name');
      expect(controller.getMember('child1')?.name, 'New Name');
    });

    test('removeMember removes from list', () {
      controller.removeMember('child1');

      expect(controller.getMember('child1'), isNull);
      expect(controller.members.length, 1);
    });

    test('removeMember reassigns children to spouse', () {
      // Add spouse and grandchild
      controller.addSpouse(
        const FamilyMember(id: 'spouse', name: 'Spouse'),
        'root',
      );
      controller.addChild(
        const FamilyMember(id: 'grandchild', name: 'Grandchild'),
        'child1',
      );

      // Remove child1 - grandchild should be reassigned
      controller.removeMember('child1');

      expect(controller.getMember('child1'), isNull);
      expect(controller.getMember('grandchild'), isNotNull);
    });

    test('undo reverses last action', () {
      controller.addMember(
        const FamilyMember(id: 'temp', name: 'Temp', generation: 0),
      );
      expect(controller.members.length, 3);

      controller.undo();
      expect(controller.members.length, 2);
      expect(controller.getMember('temp'), isNull);
    });

    test('redo reapplies undone action', () {
      controller.addMember(
        const FamilyMember(id: 'temp', name: 'Temp', generation: 0),
      );
      controller.undo();
      controller.redo();

      expect(controller.members.length, 3);
    });

    test('canUndo and canRedo track state', () {
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);

      controller.addMember(
        const FamilyMember(id: 'temp', name: 'Temp', generation: 0),
      );
      expect(controller.canUndo, isTrue);

      controller.undo();
      expect(controller.canRedo, isTrue);
    });

    test('wouldCreateCycle detects direct cycle', () {
      // root -> child1, trying to make root a child of child1
      expect(controller.wouldCreateCycle('root', 'child1'), isTrue);
    });

    test('wouldCreateCycle allows valid reparent', () {
      controller.addMember(
        const FamilyMember(id: 'other', name: 'Other', generation: 0),
      );

      // Moving child1 under 'other' is fine
      expect(controller.wouldCreateCycle('child1', 'other'), isFalse);
    });

    test('reparentMember prevents circular relationship', () {
      final result = controller.reparentMember('root', 'child1');
      expect(result, isFalse);
    });

    test('reparentMember allows valid move', () {
      controller.addMember(
        const FamilyMember(id: 'other', name: 'Other', generation: 0),
      );

      final result = controller.reparentMember('child1', 'other');
      expect(result, isTrue);
    });

    test('setMembers replaces all members', () {
      controller.setMembers([
        const FamilyMember(id: 'new1', name: 'New 1'),
        const FamilyMember(id: 'new2', name: 'New 2'),
      ]);

      expect(controller.members.length, 2);
      expect(controller.getMember('root'), isNull);
      expect(controller.getMember('new1'), isNotNull);
    });

    test('clearHistory removes undo/redo history', () {
      controller.addMember(
        const FamilyMember(id: 'temp', name: 'Temp', generation: 0),
      );
      expect(controller.canUndo, isTrue);

      controller.clearHistory();
      expect(controller.canUndo, isFalse);
    });
  });

  // ============================
  // GenealogyChartController Tests
  // ============================
  group('GenealogyChartController', () {
    late GenealogyChartController<FamilyMember> controller;

    setUp(() {
      controller = GenealogyChartController<FamilyMember>();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with default state', () {
      expect(controller.scale, 1.0);
      expect(controller.offset, Offset.zero);
      expect(controller.selectedNodes, isEmpty);
      expect(controller.collapsedNodes, isEmpty);
      expect(controller.highlightedNode, isNull);
      expect(controller.hoveredNode, isNull);
    });

    test('selectNode adds to selection', () {
      controller.selectNode('node-1');
      expect(controller.isSelected('node-1'), isTrue);
      expect(controller.selectedNodes.length, 1);
    });

    test('selectNode clears previous selection by default', () {
      controller.selectNode('node-1');
      controller.selectNode('node-2');

      expect(controller.isSelected('node-1'), isFalse);
      expect(controller.isSelected('node-2'), isTrue);
    });

    test('selectNode with addToSelection preserves existing', () {
      controller.selectNode('node-1');
      controller.selectNode('node-2', addToSelection: true);

      expect(controller.isSelected('node-1'), isTrue);
      expect(controller.isSelected('node-2'), isTrue);
    });

    test('deselectNode removes from selection', () {
      controller.selectNode('node-1');
      controller.deselectNode('node-1');

      expect(controller.isSelected('node-1'), isFalse);
    });

    test('clearSelection removes all', () {
      controller.selectNode('node-1');
      controller.selectNode('node-2', addToSelection: true);
      controller.clearSelection();

      expect(controller.selectedNodes, isEmpty);
    });

    test('collapse and expand work correctly', () {
      controller.collapse('node-1');
      expect(controller.isCollapsed('node-1'), isTrue);

      controller.expand('node-1');
      expect(controller.isCollapsed('node-1'), isFalse);
    });

    test('toggleCollapse toggles state', () {
      controller.toggleCollapse('node-1');
      expect(controller.isCollapsed('node-1'), isTrue);

      controller.toggleCollapse('node-1');
      expect(controller.isCollapsed('node-1'), isFalse);
    });

    test('expandAll clears all collapsed', () {
      controller.collapse('node-1');
      controller.collapse('node-2');
      controller.expandAll();

      expect(controller.collapsedNodes, isEmpty);
    });

    test('search stores results', () {
      controller.search('test', ['node-1', 'node-2', 'node-3']);

      expect(controller.searchQuery, 'test');
      expect(controller.searchResults.length, 3);
      expect(controller.currentSearchIndex, 0);
      expect(controller.currentSearchResult, 'node-1');
    });

    test('nextSearchResult cycles forward', () {
      controller.search('test', ['a', 'b', 'c']);

      controller.nextSearchResult();
      expect(controller.currentSearchResult, 'b');

      controller.nextSearchResult();
      expect(controller.currentSearchResult, 'c');

      controller.nextSearchResult();
      expect(controller.currentSearchResult, 'a'); // wraps around
    });

    test('previousSearchResult cycles backward', () {
      controller.search('test', ['a', 'b', 'c']);

      controller.previousSearchResult();
      expect(controller.currentSearchResult, 'c'); // wraps backward

      controller.previousSearchResult();
      expect(controller.currentSearchResult, 'b');
    });

    test('clearSearch resets state', () {
      controller.search('test', ['a', 'b']);
      controller.clearSearch();

      expect(controller.searchQuery, '');
      expect(controller.searchResults, isEmpty);
      expect(controller.currentSearchResult, isNull);
    });

    test('isSearchResult checks correctly', () {
      controller.search('test', ['a', 'b']);

      expect(controller.isSearchResult('a'), isTrue);
      expect(controller.isSearchResult('c'), isFalse);
    });

    test('highlightNode sets and auto-clears', () async {
      controller.highlightNode('node-1', duration: const Duration(milliseconds: 50));
      expect(controller.highlightedNode, 'node-1');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.highlightedNode, isNull);
    });

    test('clearHighlight clears immediately', () {
      controller.highlightNode('node-1');
      controller.clearHighlight();

      expect(controller.highlightedNode, isNull);
    });

    test('setHoveredNode updates state', () {
      controller.setHoveredNode('node-1');
      expect(controller.hoveredNode, 'node-1');

      controller.setHoveredNode(null);
      expect(controller.hoveredNode, isNull);
    });

    test('resetView resets transformation', () {
      controller.zoomTo(2.0);
      controller.resetView();

      expect(controller.transformationController.value, Matrix4.identity());
    });
  });

  // ============================
  // NodeState Tests
  // ============================
  group('NodeState', () {
    test('default state has all false', () {
      const state = NodeState();

      expect(state.isSelected, isFalse);
      expect(state.isHovered, isFalse);
      expect(state.isDragging, isFalse);
      expect(state.isHighlighted, isFalse);
      expect(state.isCollapsed, isFalse);
      expect(state.isSearchResult, isFalse);
      expect(state.scale, 1.0);
    });

    test('copyWith creates modified copy', () {
      const state = NodeState();
      final modified = state.copyWith(isSelected: true, scale: 2.0);

      expect(modified.isSelected, isTrue);
      expect(modified.scale, 2.0);
      expect(modified.isHovered, isFalse); // unchanged
    });
  });

  // ============================
  // Layout Algorithm Tests
  // ============================
  group('TreeLayout', () {
    test('returns empty map for empty nodes', () async {
      final layout = TreeLayout<String>();
      final positions = await layout.calculateLayout([], [], const Size(1000, 1000));

      expect(positions, isEmpty);
    });

    test('positions single node', () async {
      final layout = TreeLayout<String>();
      final positions = await layout.calculateLayout(
        [GraphNode(id: 'root', data: 'Root')],
        [],
        const Size(1000, 1000),
      );

      expect(positions.containsKey('root'), isTrue);
    });

    test('positions parent above children', () async {
      final layout = TreeLayout<String>(
        configuration: const LayoutConfiguration(
          orientation: TreeOrientation.topToBottom,
        ),
      );

      final positions = await layout.calculateLayout(
        [
          GraphNode(id: 'parent', data: 'P'),
          GraphNode(id: 'child', data: 'C'),
        ],
        [GraphEdge(sourceId: 'parent', targetId: 'child')],
        const Size(1000, 1000),
      );

      expect(positions['parent']!.dy, lessThan(positions['child']!.dy));
    });

    test('respects maxDepth', () async {
      final layout = TreeLayout<String>(maxDepth: 2);

      final positions = await layout.calculateLayout(
        [
          GraphNode(id: 'a', data: 'A'),
          GraphNode(id: 'b', data: 'B'),
          GraphNode(id: 'c', data: 'C'),
          GraphNode(id: 'd', data: 'D'),
        ],
        [
          GraphEdge(sourceId: 'a', targetId: 'b'),
          GraphEdge(sourceId: 'b', targetId: 'c'),
          GraphEdge(sourceId: 'c', targetId: 'd'),
        ],
        const Size(1000, 1000),
      );

      // Only 2 levels should be positioned
      expect(positions.containsKey('a'), isTrue);
      expect(positions.containsKey('b'), isTrue);
      expect(positions.containsKey('c'), isFalse);
      expect(positions.containsKey('d'), isFalse);
    });
  });

  group('FamilyTreeLayout', () {
    test('returns empty map for empty nodes', () async {
      final layout = FamilyTreeLayout();
      final positions = await layout.calculateLayout([], [], const Size(1000, 1000));

      expect(positions, isEmpty);
    });

    test('groups spouses together', () async {
      final layout = FamilyTreeLayout();

      final positions = await layout.calculateLayout(
        [
          GraphNode(
            id: 'husband',
            data: const FamilyMember(
              id: 'husband',
              name: 'Husband',
              generation: 0,
              spouseIds: ['wife'],
            ),
          ),
          GraphNode(
            id: 'wife',
            data: const FamilyMember(
              id: 'wife',
              name: 'Wife',
              generation: 0,
              spouseIds: ['husband'],
            ),
          ),
        ],
        [
          GraphEdge(sourceId: 'husband', targetId: 'wife', type: EdgeType.spouse),
        ],
        const Size(1000, 1000),
      );

      // Spouses should be at the same Y level
      expect(positions['husband']!.dy, equals(positions['wife']!.dy));
    });

    test('calculates edge paths for parent-child', () {
      final layout = FamilyTreeLayout();

      final paths = layout.calculateEdgePaths(
        {
          'parent': const Offset(100, 0),
          'child': const Offset(100, 200),
        },
        [GraphEdge(sourceId: 'parent', targetId: 'child', type: EdgeType.parentChild)],
        {'parent': const Size(80, 80), 'child': const Size(80, 80)},
      );

      expect(paths.length, 1);
      expect(paths.first.points.length, 4); // orthogonal: 4 points
    });

    test('calculates edge paths for spouses', () {
      final layout = FamilyTreeLayout();

      final paths = layout.calculateEdgePaths(
        {
          'h': const Offset(0, 0),
          'w': const Offset(120, 0),
        },
        [GraphEdge(sourceId: 'h', targetId: 'w', type: EdgeType.spouse)],
        {'h': const Size(80, 80), 'w': const Size(80, 80)},
      );

      expect(paths.length, 1);
      expect(paths.first.points.length, 2); // horizontal line
    });
  });

  // ============================
  // Theme Tests
  // ============================
  group('GenealogyChartTheme', () {
    test('light theme has white background', () {
      expect(GenealogyChartTheme.light.backgroundColor, Colors.white);
    });

    test('dark theme has dark background', () {
      expect(GenealogyChartTheme.dark.backgroundColor, const Color(0xFF1A1A1A));
    });

    test('copyWith creates modified theme', () {
      final theme = GenealogyChartTheme.light.copyWith(
        backgroundColor: Colors.blue,
        showGrid: true,
      );

      expect(theme.backgroundColor, Colors.blue);
      expect(theme.showGrid, isTrue);
      expect(theme.nodeTheme.backgroundColor, Colors.white); // unchanged
    });
  });

  group('NodeTheme', () {
    test('getStatusColor returns mapped color', () {
      const theme = NodeTheme();
      expect(theme.getStatusColor(MemberStatus.online), const Color(0xFF00BF4D));
    });

    test('dark theme has dark background', () {
      expect(NodeTheme.dark.backgroundColor, const Color(0xFF2D2D2D));
    });
  });

  // ============================
  // LinkedFamilyInfo Tests
  // ============================
  group('LinkedFamilyInfo', () {
    test('creates correctly', () {
      const info = LinkedFamilyInfo(
        familyId: 'fam-1',
        familyName: 'Smith Family',
        memberId: 'member-1',
        relationshipType: 'birth',
      );

      expect(info.isBirthFamily, isTrue);
      expect(info.isMarriageFamily, isFalse);
    });

    test('serializes to JSON and back', () {
      const original = LinkedFamilyInfo(
        familyId: 'fam-1',
        familyName: 'Smith Family',
        memberId: 'member-1',
        relationshipType: 'marriage',
      );

      final json = original.toJson();
      final restored = LinkedFamilyInfo.fromJson(json);

      expect(restored.familyId, original.familyId);
      expect(restored.familyName, original.familyName);
      expect(restored.isMarriageFamily, isTrue);
    });
  });
}
