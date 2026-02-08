import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../controllers/chart_controller.dart';
import '../../themes/chart_theme.dart';

/// Compact node widget for dense family trees.
///
/// Minimalistic display showing only essential information.
class CompactNode extends StatelessWidget {
  /// The family member to display.
  final FamilyMember member;

  /// Size of the node.
  final double size;

  /// Current state of the node.
  final NodeState state;

  /// Callback when node is tapped.
  final VoidCallback? onTap;

  /// Custom theme (overrides inherited theme).
  final GenealogyChartTheme? theme;

  const CompactNode({
    super.key,
    required this.member,
    this.size = 50,
    this.state = const NodeState(),
    this.onTap,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final chartTheme = theme ?? GenealogyChartThemeProvider.maybeOf(context) ?? GenealogyChartTheme.light;
    final nodeTheme = chartTheme.nodeTheme;
    final statusColor = nodeTheme.getStatusColor(member.status);

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: member.name,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeTheme.backgroundColor,
            border: Border.all(
              color: state.isSelected
                  ? chartTheme.selectionColor
                  : statusColor,
              width: state.isSelected ? 2.5 : 2,
            ),
            boxShadow: state.isSelected
                ? [
                    BoxShadow(
                      color: chartTheme.selectionColor.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: member.avatar != null && member.avatar!.isNotEmpty
                ? Image.network(
                    member.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(chartTheme),
                  )
                : _buildInitials(chartTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(GenealogyChartTheme chartTheme) {
    final initials = member.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      color: const Color(0xFFF6F4F7),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
