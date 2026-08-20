import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../l10n/app_strings.dart';
import '../providers/flash_provider.dart';
import '../providers/device_provider.dart' as dev;
import '../providers/log_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/collapsible_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/log_console.dart';
import 'device_page.dart';
import 'history_page.dart';
import 'pack_page.dart';
import 'settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final _firmwarePathController = TextEditingController();
  final _targetChipController = TextEditingController(text: 'STM32F103C8');
  final _startAddressController = TextEditingController(text: '0x08000000');
  String _eraseMode = 'chip';

  @override
  void dispose() {
    _firmwarePathController.dispose();
    _targetChipController.dispose();
    _startAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickFirmware() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Firmware',
      type: FileType.custom,
      allowedExtensions: ['bin', 'hex', 'elf', 'uf2'],
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path!;
      setState(() {
        _firmwarePathController.text = path;
      });
      // Set firmware in flash provider
      final ext = path.split('.').last.toLowerCase();
      ref.read(flashProvider.notifier).setFirmware(path, ext);
      // Parse start address
      final addrText = _startAddressController.text.trim();
      int addr = 0x08000000;
      if (addrText.startsWith('0x') || addrText.startsWith('0X')) {
        addr = int.tryParse(addrText.substring(2), radix:16) ?? 0x08000000;
      } else {
        addr = int.tryParse(addrText) ?? 0x08000000;
      }
      ref.read(flashProvider.notifier).setStartAddress(addr);
    }
  }

  void _startFlash() {
    final path = _firmwarePathController.text.trim();
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a firmware file first')),
      );
      return;
    }

    // Update firmware and address in provider
    final ext = path.split('.').last.toLowerCase();
    ref.read(flashProvider.notifier).setFirmware(path, ext);
    final addrText = _startAddressController.text.trim();
    int addr = 0x08000000;
    if (addrText.startsWith('0x') || addrText.startsWith('0X')) {
      addr = int.tryParse(addrText.substring(2), radix: 16) ?? 0x08000000;
    } else {
      addr = int.tryParse(addrText) ?? 0x08000000;
    }
    ref.read(flashProvider.notifier).setStartAddress(addr);

    final logNotifier = ref.read(logProvider.notifier);
    logNotifier.info('[Flash] Starting flash operation...');
    logNotifier.info('[Flash] Firmware: $path');
    logNotifier.info('[Flash] Target: ${_targetChipController.text}');
    logNotifier.info('[Flash] Start address: ${_startAddressController.text}');

    // Start flash via provider — uses gRPC streaming
    ref.read(flashProvider.notifier).startFlash(
      onLog: (msg, {bool isError = false}) {
        if (isError) {
          logNotifier.error(msg);
        } else {
          logNotifier.info(msg);
        }
      },
    );
  }

  void _startErase() {
    final logNotifier = ref.read(logProvider.notifier);
    logNotifier.info('[Erase] Starting ${_eraseMode == 'chip' ? 'chip' : 'sector'} erase...');
    ref.read(flashProvider.notifier).startErase(
      mode: _eraseMode,
      onLog: (msg, {bool isError = false}) {
        if (isError) {
          logNotifier.error(msg);
        } else {
          logNotifier.info(msg);
        }
      },
    );
  }

  void _resetTarget() async {
    final logNotifier = ref.read(logProvider.notifier);
    logNotifier.info('[Reset] Resetting target...');
    final result = await ref.read(dev.deviceProvider.notifier).resetTarget();
    logNotifier.info('[Reset] $result');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  void _showFlashResultDialog(FlashState flashState) {
    final strings = AppStrings.of(context);
    final isSuccess = !flashState.statusMessage.startsWith('Error');
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          icon: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : theme.colorScheme.error,
            size: 48,
          ),
          title: Text(
            isSuccess ? strings.operationSuccess : strings.operationFailed,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(flashState.statusMessage),
              const SizedBox(height: 8),
              Text(
                '${strings.targetChip}: ${_targetChipController.text}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${strings.bytesWritten}: ${flashState.bytesWritten}/${flashState.totalBytes}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final stringsForLocale = AppStrings(locale);
    final flashState = ref.watch(flashProvider);
    final deviceState = ref.watch(dev.deviceProvider);
    final logEntries = ref.watch(logProvider);

    // Listen for flash completion
    ref.listen<FlashState>(flashProvider, (prev, next) {
      if (prev?.isOperating == true && !next.isOperating) {
        // Flash completed (success or error)
        final logNotifier = ref.read(logProvider.notifier);
        logNotifier.info('[Result] ${next.statusMessage}');
        // Add to history
        final isSuccess = !next.statusMessage.startsWith('Error');
        ref.read(historyProvider.notifier).addRecord(
          FlashRecord(
            firmwarePath: _firmwarePathController.text,
            firmwareHash: '',
            chipName: _targetChipController.text,
            probeName: deviceState.probeName ?? '',
            timestamp: DateTime.now(),
            success: isSuccess,
            durationMs: 0,
            errorMessage: isSuccess ? null : next.statusMessage,
          ),
        );
        _showFlashResultDialog(next);
      }
    });

    return Scaffold(
      body: Row(
        children: [
          // ── Navigation Rail ──
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: Icon(
                  Iconsax.flash_15,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Iconsax.flash_1),
                  selectedIcon: const Icon(Iconsax.flash_15),
                  label: Text(stringsForLocale.flashPage),
                ),
                NavigationRailDestination(
                  icon: const Icon(Iconsax.cpu),
                  selectedIcon: const Icon(Iconsax.cpu5),
                  label: Text(stringsForLocale.devicePage),
                ),
                NavigationRailDestination(
                  icon: const Icon(Iconsax.clock),
                  selectedIcon: const Icon(Iconsax.clock5),
                  label: Text(stringsForLocale.historyPage),
                ),
                NavigationRailDestination(
                  icon: const Icon(Iconsax.box),
                  selectedIcon: const Icon(Iconsax.box5),
                  label: Text(stringsForLocale.packPage),
                ),
                NavigationRailDestination(
                  icon: const Icon(Iconsax.setting_2),
                  selectedIcon: const Icon(Iconsax.setting_25),
                  label: Text(stringsForLocale.settingsPage),
                ),
              ],
            ),
          ),

          // ── Main Content ──
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildFlashPage(theme, stringsForLocale, flashState, deviceState, logEntries),
                const DevicePage(),
                HistoryPage(
                  onReFlash: (path) {
                    _firmwarePathController.text = path;
                    final ext = path.split('.').last.toLowerCase();
                    ref.read(flashProvider.notifier).setFirmware(path, ext);
                    setState(() => _selectedIndex = 0);
                  },
                ),
                const PackPage(),
                const SettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // ── Flash Page ────────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════════

  Widget _buildFlashPage(
    ThemeData theme,
    AppStrings strings,
    FlashState flashState,
    dev.DeviceState deviceState,
    List<LogEntry> logEntries,
  ) {
    return Row(
      children: [
        // ── Left: Flash Config ──
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connection Status Card
                _buildConnectionCard(theme, strings, deviceState),
                const SizedBox(height: 8),

                // Flash Operation Card
                _buildFlashOperationCard(theme, strings, flashState, deviceState),
                const SizedBox(height: 8),

                // Speed Test Card
                _buildSpeedTestCard(theme, strings, flashState),
              ],
            ),
          ),
        ),

        // ── Right: Log Console ──
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              children: [
                // Log header with clear button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terminal, size: 16),
                      const SizedBox(width: 8),
                      Text(strings.outputLog, style: theme.textTheme.labelMedium),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => ref.read(logProvider.notifier).clear(),
                        tooltip: strings.clearLog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LogConsole(entries: logEntries),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Connection Card ────────────────────────────────────────────────────────────
  Widget _buildConnectionCard(ThemeData theme, AppStrings strings, dev.DeviceState deviceState) {
    final isScanning = deviceState.isScanning;
    final isConnected = deviceState.isConnected;

    return CollapsibleCard(index: 0,
      title: strings.connectionStatus,
      icon: Icons.usb,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isConnected
                  ? Colors.green.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.usb,
                  size: 20,
                  color: isConnected ? Colors.green : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isConnected
                        ? '${strings.statusConnected}: ${deviceState.probeName ?? ""}'
                        : strings.noDeviceConnected,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isScanning
                      ? null
                      : () {
                          ref.read(dev.deviceProvider.notifier).listProbes();
                          ref.read(logProvider.notifier).info('[Scan] Scanning for probes...');
                        },
                  icon: isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(isScanning ? strings.scanning : strings.refreshDevices),
                ),
              ),
              const SizedBox(width: 8),
              if (!isConnected)
                FilledButton.tonalIcon(
                  onPressed: deviceState.selectedProbeId == null || isScanning
                      ? null
                      : () async {
                          final probeId = deviceState.selectedProbeId!;
                          ref.read(logProvider.notifier).info('[Connect] Connecting to $probeId...');
                          final success = await ref.read(dev.deviceProvider.notifier).connect(
                            probeId: probeId,
                            target: _targetChipController.text,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? strings.connectedSuccessfully : strings.connectionFailed,
                                ),
                                backgroundColor: success ? Colors.green : theme.colorScheme.error,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.link),
                  label: Text(strings.connectProbe),
                ),
              if (isConnected)
                OutlinedButton.icon(
                  onPressed: () async {
                    ref.read(logProvider.notifier).info('[Disconnect] Disconnecting...');
                    await ref.read(dev.deviceProvider.notifier).disconnect();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.disconnected)),
                      );
                    }
                  },
                  icon: const Icon(Icons.link_off),
                  label: Text(strings.disconnectProbe),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Flash Operation Card ────────────────────────────────────────────────────────
  Widget _buildFlashOperationCard(
    ThemeData theme,
    AppStrings strings,
    FlashState flashState,
    dev.DeviceState deviceState,
  ) {
    final isFlashing = flashState.isOperating;
    final canFlash = deviceState.isConnected && !isFlashing;

    return CollapsibleCard(index: 1,
      title: strings.operation,
      icon: Icons.flash_on,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Firmware file picker
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firmwarePathController,
                  decoration: InputDecoration(
                    labelText: 'Firmware',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    hintText: strings.firmwarePathHint,
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: _pickFirmware,
                icon: const Icon(Icons.folder_open),
                tooltip: strings.loadPack,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target chip
          TextFormField(
            controller: _targetChipController,
            decoration: InputDecoration(
              labelText: strings.targetChip,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Start address
          TextFormField(
            controller: _startAddressController,
            decoration: InputDecoration(
              labelText: strings.address,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar (shown during flash)
          if (isFlashing) ...[
            Text(
              strings.flashProgress,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            FlashProgressBar(
              progress: flashState.progress,
              statusText: flashState.statusMessage,
              speedText: flashState.speedText,
            ),
            const SizedBox(height: 8),
            if (flashState.totalBytes > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${strings.bytesWritten}: ${flashState.bytesWritten}/${flashState.totalBytes}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],

          // Erase mode selector
          Row(
            children: [
              Text(strings.eraseMode, style: theme.textTheme.labelLarge),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'chip',
                    label: Text(strings.chipErase),
                    icon: const Icon(Icons.delete_sweep),
                  ),
                  ButtonSegment(
                    value: 'sector',
                    label: Text(strings.sectorErase),
                    icon: const Icon(Icons.grid_on),
                  ),
                ],
                selected: {_eraseMode},
                onSelectionChanged: isFlashing
                    ? null
                    : (v) => setState(() => _eraseMode = v.first),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: canFlash ? _startFlash : null,
                icon: isFlashing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.flash_on),
                label: Text(isFlashing ? strings.inProgress : strings.startFlash),
              ),
              FilledButton.tonalIcon(
                onPressed: canFlash ? _startErase : null,
                icon: const Icon(Icons.delete_sweep),
                label: Text(strings.eraseChip),
              ),
              OutlinedButton.icon(
                onPressed: deviceState.isConnected ? _resetTarget : null,
                icon: const Icon(Icons.restart_alt),
                label: Text(strings.resetBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Speed Test Card ─────────────────────────────────────────────────────────────
  Widget _buildSpeedTestCard(ThemeData theme, AppStrings strings, FlashState flashState) {
    final hasSpeed = flashState.speedText != null;
    return CollapsibleCard(index: 2,
      title: strings.speedTest,
      icon: Icons.speed,
      initiallyExpanded: false,
      subtitle: flashState.speedText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSpeed ? flashState.speedText! : strings.speedTest,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hasSpeed ? strings.inProgress : strings.notConnected,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
