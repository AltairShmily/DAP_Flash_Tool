import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/history_provider.dart';
import '../services/backend_manager.dart';
import '../widgets/collapsible_card.dart';

// ── Settings state providers ──

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

/// Singleton backend manager — shared across the app.
final backendManagerProvider = Provider<BackendManager>((ref) {
  return BackendManager();
});

class AppSettings {
  final String driver;       // 'pyocd' or 'openocd'
  final String frequency;    // '1000', '2000', '4000', '8000'
  final String protocol;     // 'swd' or 'jtag'

  const AppSettings({
    this.driver = 'pyocd',
    this.frequency = '4000',
    this.protocol = 'swd',
  });

  AppSettings copyWith({String? driver, String? frequency, String? protocol}) {
    return AppSettings(
      driver: driver ?? this.driver,
      frequency: frequency ?? this.frequency,
      protocol: protocol ?? this.protocol,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      driver: prefs.getString('driver') ?? 'pyocd',
      frequency: prefs.getString('frequency') ?? '4000',
      protocol: prefs.getString('protocol') ?? 'swd',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver', state.driver);
    await prefs.setString('frequency', state.frequency);
    await prefs.setString('protocol', state.protocol);
  }

  void setDriver(String driver) {
    state = state.copyWith(driver: driver);
    _save();
  }

  void setFrequency(String freq) {
    state = state.copyWith(frequency: freq);
    _save();
  }

  void setProtocol(String protocol) {
    state = state.copyWith(protocol: protocol);
    _save();
  }
}

// ── Runtime environment state ──

class RuntimeStatus {
  final bool grpcConnected;
  final BackendMode backendMode;
  final bool isChecking;

  const RuntimeStatus({
    this.grpcConnected = false,
    this.backendMode = BackendMode.notFound,
    this.isChecking = false,
  });

  RuntimeStatus copyWith({
    bool? grpcConnected,
    BackendMode? backendMode,
    bool? isChecking,
  }) {
    return RuntimeStatus(
      grpcConnected: grpcConnected ?? this.grpcConnected,
      backendMode: backendMode ?? this.backendMode,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class RuntimeNotifier extends StateNotifier<RuntimeStatus> {
  final BackendManager _manager;

  RuntimeNotifier(this._manager) : super(const RuntimeStatus()) {
    check();
  }

  Future<void> check() async {
    state = state.copyWith(isChecking: true);
    final connected = await _manager.checkHealth();
    state = RuntimeStatus(
      grpcConnected: connected,
      backendMode: _manager.mode,
      isChecking: false,
    );
  }
}

final runtimeProvider = StateNotifierProvider<RuntimeNotifier, RuntimeStatus>(
  (ref) {
    final manager = ref.watch(backendManagerProvider);
    return RuntimeNotifier(manager);
  },
);

// ── Settings Page ──

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings.of(context);
    final runtime = ref.watch(runtimeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Runtime Environment ──
          CollapsibleCard(index: 0,
            title: strings.runtimeEnvironment,
            icon: Icons.monitor_heart,
            subtitle: runtime.grpcConnected
                ? strings.grpcConnected
                : strings.grpcDisconnected,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusRow(
                  strings.backendMode,
                  _backendModeLabel(runtime.backendMode, strings),
                  _backendModeIcon(runtime.backendMode),
                  _backendModeColor(runtime.backendMode, theme.colorScheme),
                ),
                const SizedBox(height: 8),
                _statusRow(
                  strings.backendStatus,
                  runtime.grpcConnected ? strings.backendRunning : strings.backendStopped,
                  runtime.grpcConnected ? Icons.check_circle : Icons.cancel,
                  runtime.grpcConnected ? Colors.green : theme.colorScheme.error,
                ),
                const SizedBox(height: 8),
                _statusRow(
                  strings.grpcConnected,
                  runtime.grpcConnected ? strings.environmentOk : strings.environmentError,
                  runtime.grpcConnected ? Icons.link : Icons.link_off,
                  runtime.grpcConnected ? Colors.green : theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: runtime.isChecking
                        ? null
                        : () => ref.read(runtimeProvider.notifier).check(),
                    icon: runtime.isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(strings.checkEnvironment),
                  ),
                ),
                if (runtime.backendMode == BackendMode.notFound) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: theme.colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.environmentError,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Python 3.9+ and pyocd are required if the backend '
                            'is not bundled. Install with:\n'
                            '  pip install pyocd grpcio grpcio-tools protobuf intelhex pyelftools\n\n'
                            'Or download a release that includes server.exe.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Appearance ──
          CollapsibleCard(index: 1,
            title: strings.appearance,
            icon: Icons.palette,
            subtitle: _themeModeLabel(themeMode, strings),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.theme, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(strings.systemMode),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(strings.lightMode),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(strings.darkMode),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                  },
                ),
                const SizedBox(height: 16),
                // Language
                Text(strings.language, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final locale = ref.watch(localeProvider);
                    return DropdownButtonFormField<String>(
                      initialValue: locale.languageCode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'zh', child: Text('中文')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(v));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Driver ──
          CollapsibleCard(index: 2,
            title: strings.debugDriver,
            icon: Icons.build,
            subtitle: settings.driver == 'pyocd' ? strings.pyocd : strings.openocd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.selectDebugDriver, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: settings.driver,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setDriver(v);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(strings.pyocd),
                        subtitle: Text(strings.pyocdSubtitle),
                        value: 'pyocd',
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      RadioListTile<String>(
                        title: Text(strings.openocd),
                        subtitle: Text(strings.openocdSubtitle),
                        value: 'openocd',
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Defaults ──
          CollapsibleCard(index: 3,
            title: strings.flashDefaults,
            icon: Icons.tune,
            subtitle: '${_freqLabel(settings.frequency)} · ${settings.protocol.toUpperCase()}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frequency dropdown
                Text(strings.defaultFrequency, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: settings.frequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: '1000', child: Text('1 MHz')),
                    DropdownMenuItem(value: '2000', child: Text('2 MHz')),
                    DropdownMenuItem(value: '4000', child: Text('4 MHz')),
                    DropdownMenuItem(value: '8000', child: Text('8 MHz')),
                  ],
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setFrequency(v);
                  },
                ),
                const SizedBox(height: 16),

                // Protocol radio
                Text(strings.defaultProtocol, style: theme.textTheme.labelLarge),
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
                  selected: {settings.protocol},
                  onSelectionChanged: (protocols) {
                    ref.read(settingsProvider.notifier).setProtocol(protocols.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── History ──
          CollapsibleCard(index: 4,
            title: strings.flashHistory,
            icon: Icons.history,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final records = ref.watch(historyProvider);
                    return Text(
                      '${records.length} ${strings.recordsStored}',
                      style: theme.textTheme.bodyMedium,
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(strings.clearHistory),
                        content: Text(strings.clearHistoryConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(strings.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(strings.clear)),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(historyProvider.notifier).clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.historyCleared)),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(strings.clearHistory),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── About ──
          CollapsibleCard(index: 5,
            title: strings.about,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aboutRow(strings.application, 'DAP Flash Tool'),
                _aboutRow(strings.version, 'v0.1.0'),
                _aboutRow('Flutter', '3.x / Riverpod'),
                _aboutRow('Backend', 'Python + gRPC'),
                const Divider(height: 24),
                Text(
                  strings.aboutDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.code, size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      'github.com/AltairShmily/DAP_Flash_Tool',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ──

  static Widget _statusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  static String _backendModeLabel(BackendMode mode, AppStrings strings) {
    switch (mode) {
      case BackendMode.bundled:
        return strings.backendModeBundled;
      case BackendMode.venv:
        return strings.backendModeVenv;
      case BackendMode.systemPython:
        return strings.backendModeSystem;
      case BackendMode.notFound:
        return strings.backendModeNotFound;
    }
  }

  static IconData _backendModeIcon(BackendMode mode) {
    switch (mode) {
      case BackendMode.bundled:
        return Icons.inventory_2;
      case BackendMode.venv:
        return Icons.folder_special;
      case BackendMode.systemPython:
        return Icons.terminal;
      case BackendMode.notFound:
        return Icons.error_outline;
    }
  }

  static Color _backendModeColor(BackendMode mode, ColorScheme cs) {
    switch (mode) {
      case BackendMode.bundled:
        return Colors.green;
      case BackendMode.venv:
        return Colors.blue;
      case BackendMode.systemPython:
        return Colors.orange;
      case BackendMode.notFound:
        return cs.error;
    }
  }

  static String _themeModeLabel(ThemeMode mode, AppStrings strings) {
    switch (mode) {
      case ThemeMode.light:
        return strings.lightMode;
      case ThemeMode.dark:
        return strings.darkMode;
      case ThemeMode.system:
        return strings.systemMode;
    }
  }

  static String _freqLabel(String freq) {
    switch (freq) {
      case '1000':
        return '1 MHz';
      case '2000':
        return '2 MHz';
      case '4000':
        return '4 MHz';
      case '8000':
        return '8 MHz';
      default:
        return '$freq kHz';
    }
  }

  static Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
