import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionState { disconnected, connecting, connected, error }

class DeviceState {
  final ConnectionState connectionState;
  final String? probeName;
  final String? targetName;
  final String? errorMessage;
  final int frequency;
  final String protocol;

  const DeviceState({
    this.connectionState = ConnectionState.disconnected,
    this.probeName,
    this.targetName,
    this.errorMessage,
    this.frequency = 1000000,
    this.protocol = 'swd',
  });

  DeviceState copyWith({
    ConnectionState? connectionState,
    String? probeName,
    String? targetName,
    String? errorMessage,
    int? frequency,
    String? protocol,
  }) {
    return DeviceState(
      connectionState: connectionState ?? this.connectionState,
      probeName: probeName ?? this.probeName,
      targetName: targetName ?? this.targetName,
      errorMessage: errorMessage ?? this.errorMessage,
      frequency: frequency ?? this.frequency,
      protocol: protocol ?? this.protocol,
    );
  }

  bool get isConnected => connectionState == ConnectionState.connected;
}

class DeviceNotifier extends StateNotifier<DeviceState> {
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
    state = const DeviceState();
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
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>(
  (ref) => DeviceNotifier(),
);
