import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/flash_service.dart';
import '../proto/dap_flash.pb.dart';

enum FlashPhase { idle, connecting, erasing, programming, verifying, resetting }

class FlashState {
  final FlashPhase phase;
  final double progress;
  final String statusMessage;
  final bool isOperating;
  final String? firmwarePath;
  final String? firmwareFormat;
  final int startAddress;
  final String? speedText;
  final int bytesWritten;
  final int totalBytes;

  const FlashState({
    this.phase = FlashPhase.idle,
    this.progress = 0.0,
    this.statusMessage = '',
    this.isOperating = false,
    this.firmwarePath,
    this.firmwareFormat,
    this.startAddress = 0x08000000,
    this.speedText,
    this.bytesWritten = 0,
    this.totalBytes = 0,
  });

  FlashState copyWith({
    FlashPhase? phase,
    double? progress,
    String? statusMessage,
    bool? isOperating,
    String? firmwarePath,
    String? firmwareFormat,
    int? startAddress,
    String? speedText,
    int? bytesWritten,
    int? totalBytes,
  }) {
    return FlashState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      isOperating: isOperating ?? this.isOperating,
      firmwarePath: firmwarePath ?? this.firmwarePath,
      firmwareFormat: firmwareFormat ?? this.firmwareFormat,
      startAddress: startAddress ?? this.startAddress,
      speedText: speedText ?? this.speedText,
      bytesWritten: bytesWritten ?? this.bytesWritten,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}

class FlashNotifier extends StateNotifier<FlashState> {
  final FlashService _service = FlashService();

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
      speedText: null,
      bytesWritten: 0,
      totalBytes: 0,
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

  /// Map proto ProgressUpdate phase to FlashPhase
  FlashPhase _mapPhase(int protoPhase) {
    switch (protoPhase) {
      case ProgressUpdate.CONNECTING:
        return FlashPhase.connecting;
      case ProgressUpdate.ERASING:
        return FlashPhase.erasing;
      case ProgressUpdate.PROGRAMMING:
        return FlashPhase.programming;
      case ProgressUpdate.VERIFYING:
        return FlashPhase.verifying;
      case ProgressUpdate.RESETTING:
        return FlashPhase.resetting;
      default:
        return FlashPhase.connecting;
    }
  }

  /// Start firmware flash via gRPC streaming
  /// Returns a Future that completes when the stream finishes.
  /// Calls [onLog] for each update to append to the log console.
  Future<void> startFlash({
    String? driver,
    void Function(String message, {bool isError})? onLog,
  }) async {
    if (state.firmwarePath == null) return;

    startOperation(FlashPhase.connecting);
    onLog?.call('Starting flash: ${state.firmwarePath}');

    try {
      await for (final update in _service.flashFirmware(
        firmwarePath: state.firmwarePath!,
        startAddress: state.startAddress,
        driver: driver ?? 'pyocd',
      )) {
        final phase = _mapPhase(update.phase);
        state = state.copyWith(
          phase: phase,
          progress: update.progress.clamp(0.0, 1.0),
          statusMessage: update.message,
          bytesWritten: update.bytesWritten.toInt(),
          totalBytes: update.totalBytes.toInt(),
        );
        onLog?.call('[${phase.name}] ${update.message} (${(update.progress * 100).toStringAsFixed(1)}%)');
      }
      complete('Flash completed successfully');
      onLog?.call('Flash completed successfully');
    } catch (e) {
      error(e.toString());
      onLog?.call('Flash error: $e', isError: true);
    }
  }

  /// Start chip erase via gRPC streaming
  Future<void> startErase({
    String mode = 'chip',
    void Function(String message, {bool isError})? onLog,
  }) async {
    startOperation(FlashPhase.erasing);
    onLog?.call('Starting chip erase (mode: $mode)');

    try {
      await for (final update in _service.eraseChip(mode: mode)) {
        final phase = _mapPhase(update.phase);
        state = state.copyWith(
          phase: phase,
          progress: update.progress.clamp(0.0, 1.0),
          statusMessage: update.message,
        );
        onLog?.call('[${phase.name}] ${update.message} (${(update.progress * 100).toStringAsFixed(1)}%)');
      }
      complete('Erase completed successfully');
      onLog?.call('Erase completed successfully');
    } catch (e) {
      error(e.toString());
      onLog?.call('Erase error: $e', isError: true);
    }
  }
}

final flashProvider = StateNotifierProvider<FlashNotifier, FlashState>(
  (ref) => FlashNotifier(),
);
