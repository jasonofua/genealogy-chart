import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../models/member_status.dart';
import '../themes/chart_theme.dart';

/// Dialog for editing family member details.
class MemberEditDialog extends StatefulWidget {
  /// The member being edited (null for adding new).
  final FamilyMember? member;

  /// Called when the member is saved.
  final void Function(FamilyMember)? onSave;

  /// Called when delete is pressed.
  final void Function(FamilyMember)? onDelete;

  /// Whether to show the delete button.
  final bool showDelete;

  /// Title for the dialog.
  final String? title;

  /// Primary color for the dialog.
  final Color primaryColor;

  const MemberEditDialog({
    super.key,
    this.member,
    this.onSave,
    this.onDelete,
    this.showDelete = true,
    this.title,
    this.primaryColor = const Color(0xFF9747FF),
  });

  /// Show the dialog as a modal.
  static Future<FamilyMember?> show(
    BuildContext context, {
    FamilyMember? member,
    void Function(FamilyMember)? onSave,
    void Function(FamilyMember)? onDelete,
    bool showDelete = true,
    Color primaryColor = const Color(0xFF9747FF),
  }) {
    return showDialog<FamilyMember>(
      context: context,
      builder: (context) => MemberEditDialog(
        member: member,
        onSave: onSave,
        onDelete: onDelete,
        showDelete: showDelete,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  State<MemberEditDialog> createState() => _MemberEditDialogState();
}

class _MemberEditDialogState extends State<MemberEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late bool _isAlive;
  DateTime? _birthDate;
  DateTime? _deathDate;

  bool get _isNew => widget.member == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _bioController = TextEditingController(text: widget.member?.bio ?? '');
    _locationController = TextEditingController(text: widget.member?.location ?? '');
    _isAlive = widget.member?.status != MemberStatus.deceased;
    _birthDate = widget.member?.birthDate;
    _deathDate = widget.member?.deathDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isNew ? Icons.person_add : Icons.edit,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? (_isNew ? 'Add Member' : 'Edit Member'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isNew)
                          Text(
                            "Update ${widget.member!.name}'s details",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name Field
              _buildLabel('Name *'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Full name',
                  hintStyle: const TextStyle(fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                autofocus: _isNew,
              ),
              const SizedBox(height: 12),

              // Location Field
              _buildLabel('Location (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'City, Country',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Birth Date
              _buildLabel('Birth Date (optional)'),
              const SizedBox(height: 6),
              _DatePickerField(
                value: _birthDate,
                onChanged: (date) => setState(() => _birthDate = date),
              ),
              const SizedBox(height: 12),

              // Death Date (only show if deceased)
              if (!_isAlive) ...[
                _buildLabel('Death Date (optional)'),
                const SizedBox(height: 6),
                _DatePickerField(
                  value: _deathDate,
                  onChanged: (date) => setState(() => _deathDate = date),
                ),
                const SizedBox(height: 12),
              ],

              // Bio Field
              _buildLabel('Bio (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'A few words about this person...',
                  hintStyle: const TextStyle(fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Alive/Deceased Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isAlive
                      ? Colors.green.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isAlive
                        ? Colors.green.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAlive ? Icons.favorite : Icons.nights_stay,
                      size: 18,
                      color: _isAlive ? Colors.green : Colors.grey[600],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _isAlive ? 'Living' : 'Deceased',
                            style: TextStyle(
                              color: _isAlive ? Colors.green[700] : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAlive,
                      onChanged: (value) => setState(() => _isAlive = value),
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete button
                  if (!_isNew && widget.showDelete)
                    TextButton(
                      onPressed: _confirmDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Delete', style: TextStyle(fontSize: 13)),
                    ),
                  if (!_isNew && widget.showDelete) const Spacer(),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isNew ? 'Add' : 'Save Changes',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    final member = (widget.member ?? FamilyMember(id: '', name: '')).copyWith(
      name: name,
      status: _isAlive ? MemberStatus.offline : MemberStatus.deceased,
      birthDate: _birthDate,
      deathDate: _deathDate,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    );

    widget.onSave?.call(member);
    Navigator.of(context).pop(member);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        memberName: widget.member!.name,
        onConfirm: () {
          Navigator.of(context).pop(); // Close confirm dialog
          widget.onDelete?.call(widget.member!);
          Navigator.of(context).pop(); // Close edit dialog
        },
      ),
    );
  }
}

/// Compact delete confirmation dialog.
class DeleteConfirmationDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.memberName,
    required this.onConfirm,
  });

  /// Show the delete confirmation dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String memberName,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        memberName: memberName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      titlePadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remove Member',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
              children: [
                const TextSpan(text: 'Remove '),
                TextSpan(
                  text: memberName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' from the family tree?'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This cannot be undone.',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Remove',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Date picker field widget.
class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime?) onChanged;

  const _DatePickerField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? _formatDate(value!) : 'Select date',
                style: TextStyle(
                  fontSize: 14,
                  color: value != null ? Colors.black87 : Colors.grey[500],
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.clear, size: 18, color: Colors.grey[500]),
              ),
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(1800),
      lastDate: now,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Inline edit widget that appears below a node.
class InlineMemberEditor extends StatefulWidget {
  /// The member being edited.
  final FamilyMember member;

  /// Called when editing is complete.
  final void Function(FamilyMember)? onSave;

  /// Called when editing is cancelled.
  final VoidCallback? onCancel;

  /// Width of the editor.
  final double width;

  /// Primary color for styling.
  final Color primaryColor;

  const InlineMemberEditor({
    super.key,
    required this.member,
    this.onSave,
    this.onCancel,
    this.width = 200,
    this.primaryColor = const Color(0xFF9747FF),
  });

  @override
  State<InlineMemberEditor> createState() => _InlineMemberEditorState();
}

class _InlineMemberEditorState extends State<InlineMemberEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.member.name);
    _focusNode = FocusNode();

    // Auto-focus and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.nodeTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.primaryColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Enter name',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      widget.onSave?.call(widget.member.copyWith(name: name));
    }
  }
}

/// Quick action menu shown near a node.
class NodeQuickActions extends StatelessWidget {
  /// The member to show actions for.
  final FamilyMember member;

  /// Called when add child is pressed.
  final VoidCallback? onAddChild;

  /// Called when add spouse is pressed.
  final VoidCallback? onAddSpouse;

  /// Called when edit is pressed.
  final VoidCallback? onEdit;

  /// Called when delete is pressed.
  final VoidCallback? onDelete;

  const NodeQuickActions({
    super.key,
    required this.member,
    this.onAddChild,
    this.onAddSpouse,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.nodeTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onAddChild != null)
              _ActionButton(
                icon: Icons.person_add,
                tooltip: 'Add Child',
                onPressed: onAddChild!,
                color: Colors.green,
              ),
            if (onAddSpouse != null)
              _ActionButton(
                icon: Icons.favorite,
                tooltip: 'Add Spouse',
                onPressed: onAddSpouse!,
                color: Colors.pink,
              ),
            if (onEdit != null)
              _ActionButton(
                icon: Icons.edit,
                tooltip: 'Edit',
                onPressed: onEdit!,
                color: Colors.blue,
              ),
            if (onDelete != null)
              _ActionButton(
                icon: Icons.delete,
                tooltip: 'Delete',
                onPressed: onDelete!,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
