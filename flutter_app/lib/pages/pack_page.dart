import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // TODO: Replace with real pack data model once gRPC proto is generated for Dart
  final List<_MockPackInfo> _mockPacks = [
    _MockPackInfo(
      name: 'STM32F1xx_DFP',
      vendor: 'Keil.STM32F1xx_DFP',
      version: '2.4.1',
      description: 'STM32F1xx Device Family Pack',
      chips: ['STM32F103C8', 'STM32F103CB', 'STM32F103R8', 'STM32F103RB', 'STM32F103RC', 'STM32F103RE'],
      path: '/packs/Keil.STM32F1xx_DFP.2.4.1.pack',
    ),
    _MockPackInfo(
      name: 'STM32F4xx_DFP',
      vendor: 'Keil.STM32F4xx_DFP',
      version: '2.17.0',
      description: 'STM32F4xx Device Family Pack',
      chips: ['STM32F407VG', 'STM32F407VE', 'STM32F429ZI', 'STM32F446RE'],
      path: '/packs/Keil.STM32F4xx_DFP.2.17.0.pack',
    ),
    _MockPackInfo(
      name: 'nRF528xx_DFP',
      vendor: 'NordicSemiconductor.nRF52_DFP',
      version: '8.42.1',
      description: 'nRF52 Series Device Family Pack',
      chips: ['nRF52832', 'nRF52840'],
      path: '/packs/NordicSemiconductor.nRF52_DFP.8.42.1.pack',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MockPackInfo> get _filteredPacks {
    if (_searchQuery.isEmpty) return _mockPacks;
    final q = _searchQuery.toLowerCase();
    return _mockPacks.where((pack) {
      return pack.name.toLowerCase().contains(q) ||
          pack.vendor.toLowerCase().contains(q) ||
          pack.description.toLowerCase().contains(q) ||
          pack.chips.any((c) => c.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packState = ref.watch(packProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search & Actions ──
          CollapsibleCard(
            title: 'Pack Management',
            icon: Icons.inventory_2,
            subtitle: '${_mockPacks.length} packs loaded',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search packs or chips...',
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
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement scan local directories for .pack files via gRPC
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scan directories — gRPC not yet connected')),
                          );
                        },
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Scan Directory'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement import .pack file
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Import pack — gRPC not yet connected')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Import Pack'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        // TODO: Implement refresh via gRPC
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refresh — gRPC not yet connected')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Pack List ──
          if (packState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_filteredPacks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty ? 'No packs installed' : 'No packs match your search',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Scan a directory or import a .pack file to get started'
                          : 'Try a different search term',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_filteredPacks.length, (i) {
              final pack = _filteredPacks[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PackCard(
                  pack: pack,
                  isSelected: packState.selectedPack == pack.name,
                  onSelect: () {
                    // TODO: Wire up gRPC call to load pack chips
                    ref.read(packProvider.notifier).selectPack(pack.name);
                    ref.read(packProvider.notifier).setChips(pack.chips);
                  },
                ),
              );
            }),

          // ── Selected Pack Chips ──
          if (packState.selectedPack != null && packState.availableChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            CollapsibleCard(
              title: 'Chips in ${packState.selectedPack}',
              icon: Icons.memory,
              subtitle: '${packState.availableChips.length} chips',
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

// ── Mock data model (temporary until gRPC proto is generated for Dart) ──
class _MockPackInfo {
  final String name;
  final String vendor;
  final String version;
  final String description;
  final List<String> chips;
  final String path;

  const _MockPackInfo({
    required this.name,
    required this.vendor,
    required this.version,
    required this.description,
    required this.chips,
    required this.path,
  });
}

// ── Pack Card Widget ──
class _PackCard extends StatelessWidget {
  final _MockPackInfo pack;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PackCard({
    required this.pack,
    required this.isSelected,
    required this.onSelect,
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
                pack.description,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
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
                      '${pack.chips.length} chips: ${pack.chips.take(3).join(', ')}${pack.chips.length > 3 ? '…' : ''}',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
