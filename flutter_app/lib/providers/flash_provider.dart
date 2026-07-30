import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FlashPhase { idle, connecting, erasing, programming, verifying, resetting }

class FlashState {
  final FlashPhase phase;
  final double progress;
  final String statusMessage;
  final bool isOperating;
  final String? firmwarePath;
  final String? firmwareFormat;
  final int startAddress;

  const FlashState({
    this.phase = FlashPhase.idle,
    this.progress = 0.0,
    this.statusMessage = '',
    this.isOperating = false,
    this.firmwarePath,
    this.firmwareFormat,
    this.startAddress = 0x08000000,
  });

  FlashState copyWith({
    FlashPhase? phase,
    double? progress,
    String? statusMessage,
    bool? isOperating,
    String? firmwarePath,
    String? firmwareFormat,
    int? startAddress,
  }) {
    return FlashState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      isOperating: isOperating ?? this.isOperating,
      firmwarePath: firmwarePath ?? this.firmwarePath,
      firmwareFormat: firmwareFormat ?? this.firmwareFormat,
      startAddress: startAddress ?? this.startAddress,
    );
  }
}

class FlashNotifier extends StateNotifier<FlashState> {
  FlashNotifier() : super(const FlashState());

  void setFirmware(String path, String format) {
    state = state.copyWith(firmwarePath: path, firmwareFormat: format);
  }

  void setStartAddress(int address) {
    state = state.copyWith(startAddress: address);
  }

  void startOperation(FlashPhase phase) {
    state = state.copyWith(
      phase: phase,
      progress: 0.0,
      isOperating: true,
      statusMessage: 'Starting...',
    );
  }

  void updateProgress(double progress, String message) {
    state = state.copyWith(
      progress: progress,
      statusMessage: message,
    );
  }

  void complete(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      progress: 1.0,
      isOperating: false,
      statusMessage: message,
    );
  }

  void error(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      isOperating: false,
      statusMessage: 'Error: $message',
    );
  }

  void reset() {
    state = const FlashState();
  }
}

final flashProvider = StateNotifierProvider<FlashNotifier, FlashState>(
  (ref) => FlashNotifier(),
);
