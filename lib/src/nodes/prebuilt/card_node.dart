import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../models/family_relationship.dart';
import '../../controllers/chart_controller.dart';
import '../../themes/chart_theme.dart';

/// Card-style node widget for family members.
///
/// Displays member information in a card layout, similar to org charts.
class CardNode extends StatelessWidget {
  /// The family member to display.
  final FamilyMember member;

  /// Width of the card.
  final double width;

  /// Current state of the node.
  final NodeState state;

  /// Callback when node is tapped.
  final VoidCallback? onTap;

  /// Callback when node is long pressed.
  final VoidCallback? onLongPress;

  /// Whether to show avatar.
  final bool showAvatar;

  /// Whether to show relationship.
  final bool showRelationship;

  /// Whether to show lifespan dates.
  final bool showLifespan;

  /// Custom theme (overrides inherited theme).
  final GenealogyChartTheme? theme;

  const CardNode({
    super.key,
    required this.member,
    this.width = 160,
    this.state = const NodeState(),
    this.onTap,
    this.onLongPress,
    this.showAvatar = true,
    this.showRelationship = true,
    this.showLifespan = false,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final chartTheme = theme ?? GenealogyChartThemeProvider.maybeOf(context) ?? GenealogyChartTheme.light;
    final nodeTheme = chartTheme.nodeTheme;
    final isYou = member.isCurrentUser;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: nodeTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: state.isSelected || state.isHighlighted
                ? chartTheme.selectionColor
                : isYou
                    ? chartTheme.selectionColor
                    : nodeTheme.borderColor,
            width: state.isSelected ? 2.5 : nodeTheme.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: state.isSelected
                  ? chartTheme.selectionColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: state.isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAvatar) ...[
              _buildAvatar(chartTheme),
              const SizedBox(height: 8),
            ],
            Text(
              member.name,
              style: chartTheme.nameTextStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showRelationship && member.relationship != FamilyRelationship.other) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: chartTheme.selectionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  member.relationship.name,
                  style: chartTheme.detailTextStyle.copyWith(
                    color: chartTheme.selectionColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            if (showLifespan && member.lifespan != null) ...[
              const SizedBox(height: 4),
              Text(
                member.lifespan!,
                style: chartTheme.detailTextStyle.copyWith(fontSize: 11),
              ),
            ],
            if (isYou) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: chartTheme.selectionColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(GenealogyChartTheme chartTheme) {
    final nodeTheme = chartTheme.nodeTheme;
    final statusColor = nodeTheme.getStatusColor(member.status);

    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF6F4F7),
            border: Border.all(color: nodeTheme.borderColor, width: 1),
          ),
          child: ClipOval(
            child: member.avatar != null && member.avatar!.isNotEmpty
                ? Image.network(
                    member.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      color: Colors.grey[400],
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey[400],
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
