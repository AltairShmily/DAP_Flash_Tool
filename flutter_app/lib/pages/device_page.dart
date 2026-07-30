import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../providers/device_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/collapsible_card.dart';

class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({super.key});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  bool _showAdvanced = false;
  bool _targetPower = false;

  String _freqLabel(int freq) {
    switch (freq) {
      case 1000:
        return '1 MHz';
      case 2000:
        return '2 MHz';
      case 4000:
        return '4 MHz';
      case 8000:
        return '8 MHz';
      default:
        return '$freq kHz';
    }
  }

  Color _statusColor(ConnectionState state, ColorScheme cs) {
    switch (state) {
      case ConnectionState.connected:
        return Colors.green;
      case ConnectionState.connecting:
        return cs.primary;
      case ConnectionState.error:
        return cs.error;
      case ConnectionState.disconnected:
        return cs.outline;
    }
  }

  IconData _statusIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return Icons.check_circle;
      case ConnectionState.connecting:
        return Icons.sync;
      case ConnectionState.error:
        return Icons.error;
      case ConnectionState.disconnected:
        return Icons.usb;
    }
  }

  String _statusText(ConnectionState state, AppStrings strings) {
    switch (state) {
      case ConnectionState.connected:
        return strings.statusConnected;
      case ConnectionState.connecting:
        return strings.logConnecting;
      case ConnectionState.error:
        return strings.connectionFailed;
      case ConnectionState.disconnected:
        return strings.noDeviceConnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.of(context);
    final deviceState = ref.watch(deviceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Connection Status ──
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.3),
                    cs.secondaryContainer.withValues(alpha: 0.15),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(deviceState.connectionState),
                    size: 36,
                    color: _statusColor(deviceState.connectionState, cs),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusText(deviceState.connectionState, strings),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _statusColor(deviceState.connectionState, cs),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (deviceState.isConnected &&
                            deviceState.probeName != null)
                          Text(
                            '${deviceState.probeName} → ${deviceState.targetName ?? ""}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        if (deviceState.connectionState ==
                                ConnectionState.error &&
                            deviceState.errorMessage != null)
                          Text(
                            deviceState.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.error,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Probe Scanning ──
          CollapsibleCard(
            title: strings.probeList,
            icon: Icons.radar,
            subtitle: deviceState.isScanning
                ? strings.scanning
                : '${deviceState.probes.length} ${strings.probeScanned}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scan button
                FilledButton.icon(
                  onPressed: deviceState.isScanning
                      ? null
                      : () {
                          ref.read(deviceProvider.notifier).listProbes();
                          ref.read(logProvider.notifier).info('Scanning for probes...');
                        },
                  icon: deviceState.isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    deviceState.isScanning
                        ? strings.scanning
                        : strings.refreshDevices,
                  ),
                ),
                const SizedBox(height: 12),

                // Probe dropdown
                if (deviceState.probes.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: deviceState.selectedProbeId,
                    decoration: InputDecoration(
                      labelText: strings.probeId,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: deviceState.probes.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.name} (${p.vendor})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(deviceProvider.notifier).selectProbe(v);
                      }
                    },
                  ),
                  // Probe info
                  if (deviceState.selectedProbeId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Builder(builder: (context) {
                        final probe = deviceState.probes.firstWhere(
                          (p) => p.id == deviceState.selectedProbeId,
                          orElse: () => deviceState.probes.first,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(strings.probeVendor, probe.vendor, theme),
                            _infoRow(strings.probeSerial, probe.serialNumber, theme),
                          ],
                        );
                      }),
                    ),
                ] else if (!deviceState.isScanning)
                  Text(
                    strings.noProbesFound,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Connection Settings ──
          CollapsibleCard(
            title: strings.connectionParams,
            icon: Icons.settings_ethernet,
            subtitle: '${_freqLabel(deviceState.frequency)} · ${deviceState.protocol.toUpperCase()}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Frequency
                Text(strings.frequency, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: deviceState.frequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1000, child: Text('1 MHz')),
                    DropdownMenuItem(value: 2000, child: Text('2 MHz')),
                    DropdownMenuItem(value: 4000, child: Text('4 MHz')),
                    DropdownMenuItem(value: 8000, child: Text('8 MHz')),
                  ],
                  onChanged: deviceState.isConnected
                      ? null
                      : (v) {
                          if (v != null) {
                            ref.read(deviceProvider.notifier).setFrequency(v);
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Protocol
                Text(strings.protocol, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'swd',
                      label: Text('SWD'),
                      icon: Icon(Icons.cable),
                    ),
                    ButtonSegment(
                      value: 'jtag',
                      label: Text('JTAG'),
                      icon: Icon(Icons.device_hub),
                    ),
                  ],
                  selected: {deviceState.protocol},
                  onSelectionChanged: deviceState.isConnected
                      ? null
                      : (protocols) {
                          ref.read(deviceProvider.notifier).setProtocol(protocols.first);
                        },
                ),
                const SizedBox(height: 16),

                // MCU target name
                TextFormField(
                  enabled: !deviceState.isConnected,
                  decoration: InputDecoration(
                    labelText: strings.targetChip,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    hintText: 'STM32F103C8',
                  ),
                  initialValue: deviceState.targetName ?? 'STM32F103C8',
                ),
                const SizedBox(height: 16),

                // Connect / Disconnect
                Row(
                  children: [
                    Expanded(
                      child: deviceState.isConnected
                          ? OutlinedButton.icon(
                              onPressed: () async {
                                ref.read(logProvider.notifier).info('Disconnecting...');
                                await ref.read(deviceProvider.notifier).disconnect();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(strings.disconnected)),
                                  );
                                }
                                ref.read(logProvider.notifier).info('Disconnected');
                              },
                              icon: const Icon(Icons.link_off),
                              label: Text(strings.disconnectProbe),
                            )
                          : FilledButton.icon(
                              onPressed: deviceState.connectionState ==
                                          ConnectionState.connecting ||
                                      deviceState.selectedProbeId == null
                                  ? null
                                  : () async {
                                      final probeId = deviceState.selectedProbeId!;
                                      final target = deviceState.targetName ?? 'STM32F103C8';
                                      ref.read(logProvider.notifier).info(
                                          'Connecting to $probeId ($target)...');
                                      final success = await ref
                                          .read(deviceProvider.notifier)
                                          .connect(
                                            probeId: probeId,
                                            target: target,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success
                                                ? strings.connectedSuccessfully
                                                : strings.connectionFailed),
                                            backgroundColor:
                                                success ? Colors.green : cs.error,
                                          ),
                                        );
                                      }
                                    },
                              icon: deviceState.connectionState ==
                                      ConnectionState.connecting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.usb),
                              label: Text(strings.connectProbe),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Device Actions ──
          CollapsibleCard(
            title: strings.connectedDeviceInfo,
            icon: Icons.memory,
            subtitle: deviceState.isConnected
                ? (deviceState.targetName ?? strings.ready)
                : strings.notConnected,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: deviceState.isConnected
                            ? () async {
                                ref.read(logProvider.notifier).info('Reading Chip ID...');
                                final result = await ref
                                    .read(deviceProvider.notifier)
                                    .readChipId();
                                ref.read(logProvider.notifier).info('${strings.logChipId}: $result');
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      icon: const Icon(Icons.memory),
                                      title: Text(strings.chipIdBtn),
                                      content: SelectableText(result),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(strings.close),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.info_outline),
                        label: Text(strings.chipIdBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: deviceState.isConnected
                            ? () async {
                                ref.read(logProvider.notifier).info('Resetting target...');
                                final result = await ref
                                    .read(deviceProvider.notifier)
                                    .resetTarget();
                                ref.read(logProvider.notifier).info('${strings.logReset}: $result');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result)),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.restart_alt),
                        label: Text(strings.resetBtn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Advanced ──
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            strings.advanced,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _showAdvanced ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.expand_more),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showAdvanced)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),

                        // Serial number info
                        if (deviceState.isConnected &&
                            deviceState.selectedProbeId != null)
                          Builder(builder: (context) {
                            final probe = deviceState.probes.firstWhere(
                              (p) => p.id == deviceState.selectedProbeId,
                              orElse: () => deviceState.probes.first,
                            );
                            return _infoRow(strings.probeSerial, probe.serialNumber, theme);
                          }),
                        if (!deviceState.isConnected)
                          _infoRow(strings.probeSerial, '—', theme),

                        const SizedBox(height: 12),

                        // Target power
                        Text(strings.targetPower, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(strings.targetPowerOn),
                              icon: const Icon(Icons.power),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(strings.targetPowerOff),
                              icon: const Icon(Icons.power_off),
                            ),
                          ],
                          selected: {_targetPower},
                          onSelectionChanged: (v) {
                            setState(() => _targetPower = v.first);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
