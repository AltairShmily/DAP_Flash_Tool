import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:iconsax/iconsax.dart';
import '../l10n/app_strings.dart';
import '../providers/history_provider.dart';

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

  String _formatTimestamp(DateTime ts) {
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int ms) {
    if (ms < 1000) return '$ms ms';
    return '${(ms / 1000).toStringAsFixed(1)} s';
  }

  String _fileName(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : path;
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
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 18),
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

        // ── Summary chips ──
        if (records.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _summaryChip(
                  '${records.length} ${strings.recordsStored}',
                  Iconsax.document,
                  cs.primary,
                ),
                const SizedBox(width: 8),
                _summaryChip(
                  '${records.where((r) => r.success).length} ${strings.flashSuccess}',
                  Iconsax.tick_circle,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _summaryChip(
                  '${records.where((r) => !r.success).length} ${strings.flashFailed}',
                  Iconsax.close_circle,
                  cs.error,
                ),
              ],
            ),
          ),

        // ── Content ──
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(theme, cs, strings)
              : _buildGrid(filtered, theme, cs, strings),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, size: 64, color: cs.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? strings.noHistory : strings.noResults,
            style: theme.textTheme.titleMedium?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? strings.noHistoryHint : strings.tryDifferentSearch,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<FlashRecord> records,
    ThemeData theme,
    ColorScheme cs,
    AppStrings strings,
  ) {
    final columns = [
      PlutoColumn(
        title: '',
        field: 'status',
        type: PlutoColumnType.text(),
        width: 40,
        minWidth: 40,
        enableSorting: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final success = rendererContext.cell.value == 'ok';
          return Icon(
            success ? Iconsax.tick_circle5 : Iconsax.close_circle5,
            size: 18,
            color: success ? Colors.green : cs.error,
          );
        },
      ),
      PlutoColumn(
        title: strings.firmwareFile,
        field: 'file',
        type: PlutoColumnType.text(),
        minWidth: 160,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: strings.chipName,
        field: 'chip',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
        renderer: (ctx) {
          final v = ctx.cell.value as String;
          return Text(v.isEmpty ? '—' : v, style: const TextStyle(fontFamily: 'monospace', fontSize: 12));
        },
      ),
      PlutoColumn(
        title: 'Probe',
        field: 'probe',
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: false,
        renderer: (ctx) {
          final v = ctx.cell.value as String;
          return Text(v.isEmpty ? '—' : v, style: const TextStyle(fontFamily: 'monospace', fontSize: 12));
        },
      ),
      PlutoColumn(
        title: strings.duration,
        field: 'duration',
        type: PlutoColumnType.text(),
        width: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.right,
      ),
      PlutoColumn(
        title: 'Time',
        field: 'time',
        type: PlutoColumnType.text(),
        width: 140,
        enableEditingMode: false,
        renderer: (ctx) {
          return Text(
            ctx.cell.value as String,
            style: TextStyle(fontSize: 12, color: cs.outline),
          );
        },
      ),
    ];

    final rows = records.map((r) {
      return PlutoRow(cells: {
        'status': PlutoCell(value: r.success ? 'ok' : 'fail'),
        'file': PlutoCell(value: _fileName(r.firmwarePath)),
        'chip': PlutoCell(value: r.chipName),
        'probe': PlutoCell(value: r.probeName),
        'duration': PlutoCell(value: _formatDuration(r.durationMs)),
        'time': PlutoCell(value: _formatTimestamp(r.timestamp)),
      });
    }).toList();

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onRowDoubleTap: (event) {
        final idx = event.rowIdx;
        if (idx < records.length && widget.onReFlash != null) {
          widget.onReFlash!(records[idx].firmwarePath);
        }
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: theme.scaffoldBackgroundColor,
          rowColor: theme.cardTheme.color ?? cs.surface,
          activatedColor: cs.primaryContainer,
          gridBorderColor: cs.outlineVariant.withValues(alpha: 0.3),
          borderColor: cs.outlineVariant.withValues(alpha: 0.15),
          iconColor: cs.onSurfaceVariant,
          columnTextStyle: theme.textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          cellTextStyle: theme.textTheme.bodyMedium!,
          rowHeight: 36,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        ),
      ),
    );
  }
}
