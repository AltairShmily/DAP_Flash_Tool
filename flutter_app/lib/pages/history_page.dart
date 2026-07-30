import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../providers/history_provider.dart';
import '../providers/device_provider.dart';
import '../providers/flash_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final void Function(String firmwarePath)? onReFlash;

  const HistoryPage({super.key, this.onReFlash});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FlashRecord> _filteredRecords(List<FlashRecord> records) {
    if (_searchQuery.isEmpty) return records;
    final q = _searchQuery.toLowerCase();
    return records.where((r) {
      return r.firmwarePath.toLowerCase().contains(q) ||
          r.chipName.toLowerCase().contains(q) ||
          r.probeName.toLowerCase().contains(q);
    }).toList();
  }

  String _formatFileSize(String path) {
    // Extract just the filename for display
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : path;
  }

  String _formatTimestamp(DateTime ts) {
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int ms) {
    if (ms < 1000) return '$ms ms';
    return '${(ms / 1000).toStringAsFixed(1)} s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.of(context);
    final records = ref.watch(historyProvider);
    final filtered = _filteredRecords(records);

    return Column(
      children: [
        // ── Search Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: strings.searchHistory,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // ── Content ──
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(theme, cs, strings)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final record = filtered[index];
                    return _buildRecordCard(record, theme, cs, strings, records);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: cs.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? strings.noProbesFound // reuse: "No items found"
                : strings.noResults,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? strings.flashHistory
                : strings.tryDifferentSearch,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    FlashRecord record,
    ThemeData theme,
    ColorScheme cs,
    AppStrings strings,
    List<FlashRecord> allRecords,
  ) {
    final fileName = _formatFileSize(record.firmwarePath);

    return Dismissible(
      key: ValueKey(record.timestamp.toIso8601String() + record.firmwarePath),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      confirmDismiss: (direction) async {
        final index = allRecords.indexOf(record);
        ref.read(historyProvider.notifier).state = List.from(allRecords)
          ..removeAt(index);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.recordDeleted),
              action: SnackBarAction(
                label: strings.undo,
                onPressed: () {
                  final newList = List<FlashRecord>.from(
                      ref.read(historyProvider));
                  newList.insert(index, record);
                  ref.read(historyProvider.notifier).state = newList;
                },
              ),
            ),
          );
        }
        return false; // Already handled above
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (widget.onReFlash != null) {
              widget.onReFlash!(record.firmwarePath);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: filename + status
                Row(
                  children: [
                    Icon(
                      record.success ? Icons.check_circle : Icons.error_outline,
                      size: 20,
                      color: record.success ? Colors.green : cs.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: record.success
                            ? Colors.green.withValues(alpha: 0.15)
                            : cs.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.success ? strings.success : strings.errorLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: record.success ? Colors.green : cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: chip + probe
                Row(
                  children: [
                    _tagChip(Icons.memory, record.chipName, theme),
                    const SizedBox(width: 8),
                    _tagChip(Icons.usb, record.probeName, theme),
                  ],
                ),
                const SizedBox(height: 4),

                // Row 3: timestamp + duration
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: cs.outline),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(record.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: cs.outline),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(record.durationMs),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                  ],
                ),
                if (record.errorMessage != null &&
                    record.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tagChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Text(
          label.isEmpty ? '—' : label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
