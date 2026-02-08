import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../models/family_relationship.dart';
import '../../controllers/chart_controller.dart';
import '../../themes/chart_theme.dart';

/// Circular avatar node widget for family members.
///
/// Displays a circular avatar with status indicator and name label.
class CircleAvatarNode extends StatelessWidget {
  /// The family member to display.
  final FamilyMember member;

  /// Size of the avatar.
  final double size;

  /// Current state of the node.
  final NodeState state;

  /// Callback when node is tapped.
  final VoidCallback? onTap;

  /// Callback when node is long pressed.
  final VoidCallback? onLongPress;

  /// Callback when node is double tapped.
  final VoidCallback? onDoubleTap;

  /// Whether to show the name label.
  final bool showName;

  /// Whether to show the status indicator.
  final bool showStatus;

  /// Whether to show relationship badge.
  final bool showRelationship;

  /// Custom theme (overrides inherited theme).
  final GenealogyChartTheme? theme;

  const CircleAvatarNode({
    super.key,
    required this.member,
    this.size = 80,
    this.state = const NodeState(),
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.showName = true,
    this.showStatus = true,
    this.showRelationship = false,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final chartTheme = theme ?? GenealogyChartThemeProvider.maybeOf(context) ?? GenealogyChartTheme.light;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(chartTheme),
          if (showName) ...[
            const SizedBox(height: 8),
            _buildNameLabel(chartTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(GenealogyChartTheme chartTheme) {
    final nodeTheme = chartTheme.nodeTheme;
    final isYou = member.isCurrentUser;
    final statusColor = nodeTheme.getStatusColor(member.status);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Selection/highlight ring
        if (state.isSelected || state.isHighlighted)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: state.isSearchResult
                    ? chartTheme.searchResultColor
                    : chartTheme.selectionColor,
                width: chartTheme.selectionWidth,
              ),
            ),
          ),

        // Avatar container
        Container(
          width: size,
          height: size,
          margin: state.isSelected || state.isHighlighted
              ? const EdgeInsets.all(6)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeTheme.backgroundColor,
            border: Border.all(
              color: isYou ? chartTheme.selectionColor : nodeTheme.borderColor,
              width: isYou ? 2.5 : nodeTheme.borderWidth,
            ),
            boxShadow: state.isSelected || state.isHovered
                ? [
                    BoxShadow(
                      color: chartTheme.selectionColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : nodeTheme.shadow != null
                    ? [nodeTheme.shadow!]
                    : null,
          ),
          padding: const EdgeInsets.all(3),
          child: ClipOval(
            child: _buildAvatarImage(),
          ),
        ),

        // Status indicator
        if (showStatus)
          Positioned(
            bottom: state.isSelected || state.isHighlighted ? 8 : 2,
            right: state.isSelected || state.isHighlighted ? 8 : 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

        // Linked family badge
        if (member.hasLinkedFamily)
          Positioned(
            top: state.isSelected || state.isHighlighted ? 4 : -2,
            right: state.isSelected || state.isHighlighted ? 4 : -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: nodeTheme.badgeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.link,
                size: 10,
                color: nodeTheme.badgeTextColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      if (member.avatar!.startsWith('http')) {
        return Image.network(
          member.avatar!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
        );
      } else {
        return Image.asset(
          member.avatar!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF6F4F7),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildNameLabel(GenealogyChartTheme chartTheme) {
    final isYou = member.isCurrentUser;

    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: state.isHighlighted
            ? chartTheme.highlightColor.withOpacity(0.1)
            : isYou
                ? chartTheme.selectionColor.withOpacity(0.1)
                : chartTheme.nodeTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: state.isHighlighted
              ? chartTheme.highlightColor
              : isYou
                  ? chartTheme.selectionColor
                  : chartTheme.nodeTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            member.displayName,
            style: chartTheme.nameTextStyle.copyWith(
              color: state.isHighlighted || isYou
                  ? chartTheme.selectionColor
                  : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (showRelationship && member.relationship != FamilyRelationship.other)
            Text(
              member.relationship.name,
              style: chartTheme.detailTextStyle.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (isYou)
            Text(
              'You',
              style: chartTheme.detailTextStyle.copyWith(
                color: chartTheme.selectionColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
