import 'package:flutter/material.dart';
import '../controllers/chart_controller.dart';
import '../models/family_member.dart';
import '../themes/chart_theme.dart';

/// A search bar widget for finding family members in the chart.
///
/// Integrates with [GenealogyChartController] to highlight search results
/// and navigate between matches.
class ChartSearchBar extends StatefulWidget {
  /// The chart controller to drive search.
  final GenealogyChartController controller;

  /// All family members to search through.
  final List<FamilyMember> members;

  /// Node positions for panning to results.
  final Map<String, Offset>? positions;

  /// Node sizes for panning to results.
  final Map<String, Size>? nodeSizes;

  /// Viewport size for centering.
  final Size? viewportSize;

  /// Called when a member is found and selected.
  final void Function(FamilyMember)? onResultSelected;

  /// Hint text for the search field.
  final String hintText;

  /// Whether to auto-pan to results.
  final bool autoPan;

  const ChartSearchBar({
    super.key,
    required this.controller,
    required this.members,
    this.positions,
    this.nodeSizes,
    this.viewportSize,
    this.onResultSelected,
    this.hintText = 'Search family members...',
    this.autoPan = true,
  });

  @override
  State<ChartSearchBar> createState() => _ChartSearchBarState();
}

class _ChartSearchBarState extends State<ChartSearchBar> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      widget.controller.clearSearch();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final matches = widget.members
        .where((m) =>
            m.name.toLowerCase().contains(lowerQuery) ||
            (m.firstName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (m.lastName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (m.location?.toLowerCase().contains(lowerQuery) ?? false))
        .map((m) => m.id)
        .toList();

    widget.controller.search(query, matches);

    if (matches.isNotEmpty) {
      _panToCurrentResult();
    }
  }

  void _panToCurrentResult() {
    final resultId = widget.controller.currentSearchResult;
    if (resultId == null) return;

    if (widget.autoPan &&
        widget.positions != null &&
        widget.nodeSizes != null &&
        widget.viewportSize != null) {
      widget.controller.panToNode(
        resultId,
        widget.positions!,
        widget.nodeSizes!,
        viewportSize: widget.viewportSize,
      );
    }

    widget.controller.highlightNode(resultId);

    final member = widget.members.where((m) => m.id == resultId).firstOrNull;
    if (member != null) {
      widget.onResultSelected?.call(member);
    }
  }

  void _nextResult() {
    widget.controller.nextSearchResult();
    _panToCurrentResult();
  }

  void _previousResult() {
    widget.controller.previousSearchResult();
    _panToCurrentResult();
  }

  void _close() {
    _textController.clear();
    widget.controller.clearSearch();
    setState(() => _isExpanded = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenealogyChartThemeProvider.maybeOf(context) ??
        GenealogyChartTheme.light;

    if (!_isExpanded) {
      return IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() => _isExpanded = true);
          _focusNode.requestFocus();
        },
        tooltip: 'Search',
      );
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final results = widget.controller.searchResults;
        final currentIndex = widget.controller.currentSearchIndex;
        final hasResults = results.isNotEmpty;
        final query = widget.controller.searchQuery;

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: theme.nodeTheme.backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.nodeTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onChanged: _onSearch,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (query.isNotEmpty) ...[
                Text(
                  hasResults
                      ? '${currentIndex + 1}/${results.length}'
                      : '0 results',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasResults ? Colors.grey[600] : Colors.red[400],
                  ),
                ),
                const SizedBox(width: 4),
                if (hasResults) ...[
                  _NavButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: _previousResult,
                  ),
                  _NavButton(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: _nextResult,
                  ),
                ],
              ],
              _NavButton(
                icon: Icons.close,
                onPressed: _close,
              ),
              const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 14,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
