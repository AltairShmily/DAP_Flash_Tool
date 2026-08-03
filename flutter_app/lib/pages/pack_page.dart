import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../proto/dap_flash.pb.dart';
import '../providers/pack_provider.dart';
import '../widgets/collapsible_card.dart';

class PackPage extends ConsumerStatefulWidget {
  const PackPage({super.key});

  @override
  ConsumerState<PackPage> createState() => _PackPageState();
}

class _PackPageState extends ConsumerState<PackPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        ref.read(packProvider.notifier).searchPacks(query);
      } else {
        ref.read(packProvider.notifier).clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packState = ref.watch(packProvider);
    final strings = AppStrings.of(context);

    // Determine which list to display
    final bool showSearchResults = _searchQuery.isNotEmpty;
    final List<PackInfo> displayPacks =
        showSearchResults ? packState.searchResults : packState.packs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search & Actions ──
          CollapsibleCard(
            title: strings.packManagement,
            icon: Icons.inventory_2,
            subtitle: '${packState.packs.length} ${strings.packsLoaded}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings.searchPacksOrChips,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(packProvider.notifier).loadPacks();
                        },
                        icon: const Icon(Icons.folder_open),
                        label: Text(strings.scanDirectory),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.importNotConnected)),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(strings.importPack),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        ref.read(packProvider.notifier).loadPacks();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: strings.refresh,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Download Progress ──
          if (packState.isDownloading) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${strings.inProgress} ${(packState.downloadProgress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: packState.downloadProgress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Error Message ──
          if (packState.errorMessage != null) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        packState.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Pack List ──
          if (packState.isLoading || packState.isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (displayPacks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 8),
                    Text(
                      showSearchResults ? strings.noPacksMatchSearch : strings.noPacksInstalled,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showSearchResults ? strings.tryDifferentSearch : strings.scanOrImportHint,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(displayPacks.length, (i) {
              final pack = displayPacks[i];
              final isInstalled = packState.packs.any(
                (p) => p.name == pack.name && p.version == pack.version,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PackCard(
                  pack: pack,
                  isSelected: packState.selectedPack == pack.name,
                  isInstalled: isInstalled,
                  isSearchResult: showSearchResults,
                  onSelect: () {
                    ref.read(packProvider.notifier).selectPack(pack.name);
                  },
                  onDownload: () {
                    ref.read(packProvider.notifier).downloadPack(pack.path, pack.name);
                  },
                ),
              );
            }),

          // ── Selected Pack Chips ──
          if (packState.selectedPack != null && packState.availableChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            CollapsibleCard(
              title: '${strings.chipsIn} ${packState.selectedPack}',
              icon: Icons.memory,
              subtitle: '${packState.availableChips.length} ${strings.chips}',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: packState.availableChips.map((chip) {
                  final isSelected = packState.selectedChip == chip;
                  return FilterChip(
                    label: Text(chip),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(packProvider.notifier).selectChip(chip);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pack Card Widget ──
class _PackCard extends StatelessWidget {
  final PackInfo pack;
  final bool isSelected;
  final bool isInstalled;
  final bool isSearchResult;
  final VoidCallback onSelect;
  final VoidCallback onDownload;

  const _PackCard({
    required this.pack,
    required this.isSelected,
    required this.isInstalled,
    required this.isSearchResult,
    required this.onSelect,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: isSelected ? cs.primaryContainer.withValues(alpha: 0.3) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 20,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pack.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, size: 18, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    'v${pack.version}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                pack.vendor,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.outline,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.memory, size: 14, color: cs.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${pack.supportedChips.length} chips: ${pack.supportedChips.take(3).join(', ')}${pack.supportedChips.length > 3 ? '…' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.folder, size: 14, color: cs.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pack.path,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Download button for search results that aren't installed
                  if (isSearchResult && !isInstalled)
                    OutlinedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('下载'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
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
}
