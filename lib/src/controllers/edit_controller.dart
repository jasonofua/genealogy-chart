import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/family_member.dart';
import '../models/member_status.dart';
import '../features/drag_drop/drop_target.dart';

/// Types of edit actions for undo/redo.
enum EditActionType {
  addMember,
  removeMember,
  updateMember,
  moveMember,
  reparentMember,
  addSpouse,
  removeSpouse,
}

/// Represents an edit action that can be undone/redone.
class EditAction {
  /// Type of action.
  final EditActionType type;

  /// Description for display.
  final String description;

  /// State before the action.
  final Map<String, dynamic> beforeState;

  /// State after the action.
  final Map<String, dynamic> afterState;

  /// Timestamp of the action.
  final DateTime timestamp;

  EditAction({
    required this.type,
    required this.description,
    required this.beforeState,
    required this.afterState,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Event when a member is added.
class MemberAddedEvent {
  final FamilyMember member;
  final String? parentId;

  const MemberAddedEvent({required this.member, this.parentId});
}

/// Event when a member is removed.
class MemberRemovedEvent {
  final FamilyMember member;

  const MemberRemovedEvent({required this.member});
}

/// Event when a member is updated.
class MemberUpdatedEvent {
  final FamilyMember oldMember;
  final FamilyMember newMember;

  const MemberUpdatedEvent({required this.oldMember, required this.newMember});
}

/// Event when a member is moved/reparented.
class MemberMovedEvent {
  final FamilyMember member;
  final String? oldParentId;
  final String? newParentId;
  final DropRelation relation;

  const MemberMovedEvent({
    required this.member,
    this.oldParentId,
    this.newParentId,
    required this.relation,
  });
}

/// Controller for editing family tree data.
///
/// Manages add/update/remove operations with undo/redo support.
class FamilyEditController extends ChangeNotifier {
  /// Current list of family members.
  List<FamilyMember> _members;

  /// Undo stack.
  final List<EditAction> _undoStack = [];

  /// Redo stack.
  final List<EditAction> _redoStack = [];

  /// Maximum undo history size.
  final int maxHistorySize;

  /// Event streams.
  final _memberAddedController = StreamController<MemberAddedEvent>.broadcast();
  final _memberRemovedController = StreamController<MemberRemovedEvent>.broadcast();
  final _memberUpdatedController = StreamController<MemberUpdatedEvent>.broadcast();
  final _memberMovedController = StreamController<MemberMovedEvent>.broadcast();

  /// Stream of member added events.
  Stream<MemberAddedEvent> get onMemberAdded => _memberAddedController.stream;

  /// Stream of member removed events.
  Stream<MemberRemovedEvent> get onMemberRemoved => _memberRemovedController.stream;

  /// Stream of member updated events.
  Stream<MemberUpdatedEvent> get onMemberUpdated => _memberUpdatedController.stream;

  /// Stream of member moved events.
  Stream<MemberMovedEvent> get onMemberMoved => _memberMovedController.stream;

  FamilyEditController({
    List<FamilyMember>? initialMembers,
    this.maxHistorySize = 50,
  }) : _members = List.from(initialMembers ?? []);

  /// Get current members (read-only).
  List<FamilyMember> get members => List.unmodifiable(_members);

  /// Whether undo is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether redo is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Get a member by ID.
  FamilyMember? getMember(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Set all members (replaces current list).
  void setMembers(List<FamilyMember> members) {
    _members = List.from(members);
    notifyListeners();
  }

  // === Add Operations ===

  /// Add a new member to the family.
  void addMember(
    FamilyMember member, {
    String? parentId,
    bool recordHistory = true,
  }) {
    // Update member with parent if provided
    final newMember = parentId != null
        ? member.copyWith(parentIds: [...member.parentIds, parentId])
        : member;

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.addMember,
        description: 'Add ${member.name}',
        beforeState: {'members': _cloneMembers()},
        afterState: {'member': newMember.toJson(), 'parentId': parentId},
      ));
    }

    _members.add(newMember);

    // Update parent's children list if needed
    if (parentId != null) {
      final parentIndex = _members.indexWhere((m) => m.id == parentId);
      if (parentIndex != -1) {
        final parent = _members[parentIndex];
        _members[parentIndex] = parent.copyWith(
          childrenIds: [...parent.childrenIds, newMember.id],
        );
      }
    }

    _memberAddedController.add(MemberAddedEvent(
      member: newMember,
      parentId: parentId,
    ));

    notifyListeners();
  }

  /// Add a child to a parent.
  void addChild(FamilyMember child, String parentId) {
    final childWithParent = child.copyWith(
      parentIds: [parentId],
      generation: (getMember(parentId)?.generation ?? 0) + 1,
    );
    addMember(childWithParent, parentId: parentId);
  }

  /// Add a spouse to a member.
  void addSpouse(FamilyMember spouse, String memberId, {bool recordHistory = true}) {
    final member = getMember(memberId);
    if (member == null) return;

    // Create spouse with same generation and linked spouse IDs
    final spouseWithLink = spouse.copyWith(
      generation: member.generation,
      spouseIds: [memberId],
    );

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.addSpouse,
        description: 'Add spouse ${spouse.name} to ${member.name}',
        beforeState: {'members': _cloneMembers()},
        afterState: {'spouse': spouseWithLink.toJson(), 'memberId': memberId},
      ));
    }

    // Add spouse to list
    _members.add(spouseWithLink);

    // Update member's spouse list
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      _members[memberIndex] = member.copyWith(
        spouseIds: [...member.spouseIds, spouseWithLink.id],
      );
    }

    _memberAddedController.add(MemberAddedEvent(member: spouseWithLink));
    notifyListeners();
  }

  // === Update Operations ===

  /// Update an existing member.
  void updateMember(FamilyMember updatedMember, {bool recordHistory = true}) {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index == -1) return;

    final oldMember = _members[index];

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.updateMember,
        description: 'Update ${oldMember.name}',
        beforeState: {'member': oldMember.toJson()},
        afterState: {'member': updatedMember.toJson()},
      ));
    }

    _members[index] = updatedMember;

    _memberUpdatedController.add(MemberUpdatedEvent(
      oldMember: oldMember,
      newMember: updatedMember,
    ));

    notifyListeners();
  }

  /// Update a member's name.
  void updateMemberName(String memberId, String newName) {
    final member = getMember(memberId);
    if (member == null) return;
    updateMember(member.copyWith(name: newName));
  }

  /// Update a member's status.
  void updateMemberStatus(String memberId, MemberStatus newStatus) {
    final member = getMember(memberId);
    if (member == null) return;
    updateMember(member.copyWith(status: newStatus));
  }

  // === Validation ===

  /// Check if making [memberId] a child of [parentId] would create a cycle.
  ///
  /// Walks up the ancestor chain from [parentId] to see if [memberId]
  /// appears, which would indicate a circular relationship.
  bool wouldCreateCycle(String memberId, String parentId) {
    final visited = <String>{};
    final queue = [parentId];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (current == memberId) return true;
      if (visited.contains(current)) continue;
      visited.add(current);

      final currentMember = getMember(current);
      if (currentMember != null) {
        queue.addAll(currentMember.parentIds);
      }
    }
    return false;
  }

  // === Move/Reparent Operations ===

  /// Move a member to a new parent.
  ///
  /// Returns false if the operation would create a circular relationship.
  bool reparentMember(
    String memberId,
    String? newParentId, {
    bool recordHistory = true,
  }) {
    final member = getMember(memberId);
    if (member == null) return false;

    // Prevent circular relationships
    if (newParentId != null && wouldCreateCycle(memberId, newParentId)) {
      return false;
    }

    final oldParentId = member.parentIds.isNotEmpty ? member.parentIds.first : null;

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.reparentMember,
        description: 'Move ${member.name}',
        beforeState: {
          'memberId': memberId,
          'oldParentId': oldParentId,
          'members': _cloneMembers(),
        },
        afterState: {
          'memberId': memberId,
          'newParentId': newParentId,
        },
      ));
    }

    // Remove from old parent's children
    if (oldParentId != null) {
      final oldParentIndex = _members.indexWhere((m) => m.id == oldParentId);
      if (oldParentIndex != -1) {
        final oldParent = _members[oldParentIndex];
        _members[oldParentIndex] = oldParent.copyWith(
          childrenIds: oldParent.childrenIds.where((id) => id != memberId).toList(),
        );
      }
    }

    // Update member's parent
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      final newGeneration = newParentId != null
          ? (getMember(newParentId)?.generation ?? 0) + 1
          : member.generation;

      _members[memberIndex] = member.copyWith(
        parentIds: newParentId != null ? [newParentId] : [],
        generation: newGeneration,
      );
    }

    // Add to new parent's children
    if (newParentId != null) {
      final newParentIndex = _members.indexWhere((m) => m.id == newParentId);
      if (newParentIndex != -1) {
        final newParent = _members[newParentIndex];
        _members[newParentIndex] = newParent.copyWith(
          childrenIds: [...newParent.childrenIds, memberId],
        );
      }
    }

    _memberMovedController.add(MemberMovedEvent(
      member: getMember(memberId)!,
      oldParentId: oldParentId,
      newParentId: newParentId,
      relation: newParentId != null ? DropRelation.asChild : DropRelation.reposition,
    ));

    notifyListeners();
    return true;
  }

  /// Make two members siblings.
  void makeSiblings(String memberId, String siblingId) {
    final sibling = getMember(siblingId);
    if (sibling == null || sibling.parentIds.isEmpty) return;

    reparentMember(memberId, sibling.parentIds.first);
  }

  // === Remove Operations ===

  /// Remove a member from the family.
  ///
  /// When removing a member who has children, the children are reassigned
  /// to the remaining spouse (if any). This maintains the family tree structure.
  void removeMember(String memberId, {bool recordHistory = true}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index == -1) return;

    final member = _members[index];

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.removeMember,
        description: 'Remove ${member.name}',
        beforeState: {'members': _cloneMembers()},
        afterState: {'memberId': memberId},
      ));
    }

    // Find the spouse(s) of the member being deleted
    // Check both directions: member's spouseIds AND members who have this member as their spouse
    final spouseIds = <String>{...member.spouseIds};
    for (final m in _members) {
      if (m.id != memberId && m.spouseIds.contains(memberId)) {
        spouseIds.add(m.id);
      }
    }

    // Find the first valid spouse to reassign children to
    FamilyMember? remainingSpouse;
    for (final spouseId in spouseIds) {
      final spouse = getMember(spouseId);
      if (spouse != null) {
        remainingSpouse = spouse;
        break;
      }
    }

    // Find all children that have the deleted member as a parent
    final childrenToReassign = _members.where((m) =>
        m.parentIds.contains(memberId)).toList();

    // Remove member
    _members.removeAt(index);

    // Reassign children to remaining spouse OR remove parent reference
    for (final child in childrenToReassign) {
      final childIndex = _members.indexWhere((m) => m.id == child.id);
      if (childIndex != -1) {
        final updatedParentIds = child.parentIds.where((id) => id != memberId).toList();

        if (remainingSpouse != null && !updatedParentIds.contains(remainingSpouse.id)) {
          updatedParentIds.add(remainingSpouse.id);
        }

        _members[childIndex] = child.copyWith(parentIds: updatedParentIds);
      }
    }

    // Update remaining spouse's childrenIds to include reassigned children
    if (remainingSpouse != null) {
      final spouseIndex = _members.indexWhere((m) => m.id == remainingSpouse!.id);
      if (spouseIndex != -1) {
        final spouse = _members[spouseIndex];
        final updatedChildrenIds = [...spouse.childrenIds];
        for (final child in childrenToReassign) {
          if (!updatedChildrenIds.contains(child.id)) {
            updatedChildrenIds.add(child.id);
          }
        }
        _members[spouseIndex] = spouse.copyWith(
          childrenIds: updatedChildrenIds,
          spouseIds: spouse.spouseIds.where((id) => id != memberId).toList(),
        );
      }
    }

    // Remove from parents' children lists
    for (final parentId in member.parentIds) {
      final parentIndex = _members.indexWhere((m) => m.id == parentId);
      if (parentIndex != -1) {
        final parent = _members[parentIndex];
        _members[parentIndex] = parent.copyWith(
          childrenIds: parent.childrenIds.where((id) => id != memberId).toList(),
        );
      }
    }

    // Remove from other spouses' spouse lists (those not yet updated)
    for (final spouseId in member.spouseIds) {
      if (remainingSpouse != null && spouseId == remainingSpouse.id) continue;
      final spouseIndex = _members.indexWhere((m) => m.id == spouseId);
      if (spouseIndex != -1) {
        final spouse = _members[spouseIndex];
        _members[spouseIndex] = spouse.copyWith(
          spouseIds: spouse.spouseIds.where((id) => id != memberId).toList(),
        );
      }
    }

    _memberRemovedController.add(MemberRemovedEvent(member: member));
    notifyListeners();
  }

  /// Remove spouse relationship between two members.
  void removeSpouse(String memberId, String spouseId, {bool recordHistory = true}) {
    final member = getMember(memberId);
    final spouse = getMember(spouseId);
    if (member == null || spouse == null) return;

    if (recordHistory) {
      _recordAction(EditAction(
        type: EditActionType.removeSpouse,
        description: 'Remove spouse relationship',
        beforeState: {'members': _cloneMembers()},
        afterState: {'memberId': memberId, 'spouseId': spouseId},
      ));
    }

    // Update member's spouse list
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      _members[memberIndex] = member.copyWith(
        spouseIds: member.spouseIds.where((id) => id != spouseId).toList(),
      );
    }

    // Update spouse's spouse list
    final spouseIndex = _members.indexWhere((m) => m.id == spouseId);
    if (spouseIndex != -1) {
      _members[spouseIndex] = spouse.copyWith(
        spouseIds: spouse.spouseIds.where((id) => id != memberId).toList(),
      );
    }

    notifyListeners();
  }

  // === Undo/Redo ===

  /// Undo the last action.
  void undo() {
    if (!canUndo) return;

    final action = _undoStack.removeLast();
    _redoStack.add(action);

    // Restore before state
    _restoreState(action.beforeState);
    notifyListeners();
  }

  /// Redo the last undone action.
  void redo() {
    if (!canRedo) return;

    final action = _redoStack.removeLast();
    _undoStack.add(action);

    // Apply after state
    _applyAction(action);
    notifyListeners();
  }

  /// Clear all history.
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }

  // === Private Helpers ===

  void _recordAction(EditAction action) {
    _undoStack.add(action);
    _redoStack.clear();

    // Limit history size
    while (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  List<Map<String, dynamic>> _cloneMembers() {
    return _members.map((m) => m.toJson()).toList();
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.containsKey('members')) {
      final membersList = state['members'] as List<dynamic>;
      _members = membersList
          .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
          .toList();
    }
  }

  void _applyAction(EditAction action) {
    switch (action.type) {
      case EditActionType.addMember:
        final memberJson = action.afterState['member'] as Map<String, dynamic>;
        final parentId = action.afterState['parentId'] as String?;
        addMember(
          FamilyMember.fromJson(memberJson),
          parentId: parentId,
          recordHistory: false,
        );
        break;

      case EditActionType.removeMember:
        final memberId = action.afterState['memberId'] as String;
        removeMember(memberId, recordHistory: false);
        break;

      case EditActionType.updateMember:
        final memberJson = action.afterState['member'] as Map<String, dynamic>;
        updateMember(FamilyMember.fromJson(memberJson), recordHistory: false);
        break;

      case EditActionType.reparentMember:
        final memberId = action.afterState['memberId'] as String;
        final newParentId = action.afterState['newParentId'] as String?;
        reparentMember(memberId, newParentId, recordHistory: false);
        break;

      case EditActionType.addSpouse:
        final spouseJson = action.afterState['spouse'] as Map<String, dynamic>;
        final memberId = action.afterState['memberId'] as String;
        addSpouse(
          FamilyMember.fromJson(spouseJson),
          memberId,
          recordHistory: false,
        );
        break;

      case EditActionType.removeSpouse:
        final memberId = action.afterState['memberId'] as String;
        final spouseId = action.afterState['spouseId'] as String;
        removeSpouse(memberId, spouseId, recordHistory: false);
        break;

      case EditActionType.moveMember:
        // Handled by reparentMember
        break;
    }
  }

  @override
  void dispose() {
    _memberAddedController.close();
    _memberRemovedController.close();
    _memberUpdatedController.close();
    _memberMovedController.close();
    super.dispose();
  }
}
