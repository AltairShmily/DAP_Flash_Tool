import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/device_service.dart';
import '../proto/dap_flash.pb.dart';

enum ConnectionState { disconnected, connecting, connected, error }

class DeviceState {
  final ConnectionState connectionState;
  final String? probeName;
  final String? targetName;
  final String? errorMessage;
  final int frequency;
  final String protocol;
  final List<Probe> probes;
  final bool isScanning;
  final String? selectedProbeId;

  const DeviceState({
    this.connectionState = ConnectionState.disconnected,
    this.probeName,
    this.targetName,
    this.errorMessage,
    this.frequency = 4000,
    this.protocol = 'swd',
    this.probes = const [],
    this.isScanning = false,
    this.selectedProbeId,
  });

  DeviceState copyWith({
    ConnectionState? connectionState,
    String? probeName,
    String? targetName,
    String? errorMessage,
    int? frequency,
    String? protocol,
    List<Probe>? probes,
    bool? isScanning,
    String? selectedProbeId,
  }) {
    return DeviceState(
      connectionState: connectionState ?? this.connectionState,
      probeName: probeName ?? this.probeName,
      targetName: targetName ?? this.targetName,
      errorMessage: errorMessage ?? this.errorMessage,
      frequency: frequency ?? this.frequency,
      protocol: protocol ?? this.protocol,
      probes: probes ?? this.probes,
      isScanning: isScanning ?? this.isScanning,
      selectedProbeId: selectedProbeId ?? this.selectedProbeId,
    );
  }

  bool get isConnected => connectionState == ConnectionState.connected;
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  final DeviceService _service = DeviceService();

  DeviceNotifier() : super(const DeviceState());

  void setConnecting() {
    state = state.copyWith(connectionState: ConnectionState.connecting);
  }

  void setConnected(String probeName, String targetName) {
    state = state.copyWith(
      connectionState: ConnectionState.connected,
      probeName: probeName,
      targetName: targetName,
      errorMessage: null,
    );
  }

  void setDisconnected() {
    state = state.copyWith(
      connectionState: ConnectionState.disconnected,
      probeName: null,
      targetName: null,
      selectedProbeId: null,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      connectionState: ConnectionState.error,
      errorMessage: message,
    );
  }

  void setFrequency(int freq) {
    state = state.copyWith(frequency: freq);
  }

  void setProtocol(String proto) {
    state = state.copyWith(protocol: proto);
  }

  void setTargetName(String name) {
    state = state.copyWith(targetName: name);
  }

  void selectProbe(String probeId) {
    state = state.copyWith(selectedProbeId: probeId);
  }

  /// Scan for debug probes via gRPC
  Future<void> listProbes() async {
    state = state.copyWith(isScanning: true);
    try {
      final probes = await _service.listProbes();
      state = state.copyWith(probes: probes, isScanning: false);
      // Auto-select the first probe if none selected
      if (probes.isNotEmpty && state.selectedProbeId == null) {
        state = state.copyWith(selectedProbeId: probes.first.id);
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'Failed to scan probes: $e',
      );
    }
  }

  /// Connect to the selected probe with current settings
  Future<bool> connect({
    required String probeId,
    required String target,
  }) async {
    state = state.copyWith(connectionState: ConnectionState.connecting);
    try {
      final response = await _service.connect(
        probeId: probeId,
        target: target,
        frequency: state.frequency,
        protocol: state.protocol,
      );
      if (response.success) {
        state = state.copyWith(
          connectionState: ConnectionState.connected,
          probeName: probeId,
          targetName: response.targetName,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          connectionState: ConnectionState.error,
          errorMessage: response.errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        connectionState: ConnectionState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Disconnect from the current probe
  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (_) {
      // Ignore disconnect errors — reset local state anyway
    }
    setDisconnected();
  }

  /// Reset the target device
  Future<String> resetTarget() async {
    try {
      final result = await _service.reset();
      return result.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Read the chip ID from the connected device
  Future<String> readChipId() async {
    try {
      final result = await _service.readChipId();
      final hexId = result.chipId.toRadixString(16).toUpperCase().padLeft(8, '0');
      return '0x$hexId — ${result.description}';
    } catch (e) {
      return 'Error: $e';
    }
  }
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>(
  (ref) => DeviceNotifier(),
);
