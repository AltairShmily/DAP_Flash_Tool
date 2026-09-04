import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/flash_service.dart';
import '../proto/dap_flash.pb.dart';

enum FlashPhase { idle, connecting, erasing, programming, verifying, resetting }

/// Which operation is running — used to avoid recording erases as flash history.
enum FlashOperationType { none, flash, erase }

class FlashState {
  final FlashPhase phase;
  final FlashOperationType operationType;
  final double progress;
  final String statusMessage;
  final bool isOperating;
  final String? firmwarePath;
  final String? firmwareFormat;
  final int startAddress;
  final String? speedText;
  final int bytesWritten;
  final int totalBytes;

  /// Explicit outcome of the last finished operation (null while idle/running).
  final bool? success;
  final int durationMs;

  const FlashState({
    this.phase = FlashPhase.idle,
    this.operationType = FlashOperationType.none,
    this.progress = 0.0,
    this.statusMessage = '',
    this.isOperating = false,
    this.firmwarePath,
    this.firmwareFormat,
    this.startAddress = 0x08000000,
    this.speedText,
    this.bytesWritten = 0,
    this.totalBytes = 0,
    this.success,
    this.durationMs = 0,
  });

  FlashState copyWith({
    FlashPhase? phase,
    FlashOperationType? operationType,
    double? progress,
    String? statusMessage,
    bool? isOperating,
    String? firmwarePath,
    String? firmwareFormat,
    int? startAddress,
    String? speedText,
    bool clearSpeedText = false,
    int? bytesWritten,
    int? totalBytes,
    bool? success,
    bool clearSuccess = false,
    int? durationMs,
  }) {
    return FlashState(
      phase: phase ?? this.phase,
      operationType: operationType ?? this.operationType,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      isOperating: isOperating ?? this.isOperating,
      firmwarePath: firmwarePath ?? this.firmwarePath,
      firmwareFormat: firmwareFormat ?? this.firmwareFormat,
      startAddress: startAddress ?? this.startAddress,
      speedText: clearSpeedText ? null : (speedText ?? this.speedText),
      bytesWritten: bytesWritten ?? this.bytesWritten,
      totalBytes: totalBytes ?? this.totalBytes,
      success: clearSuccess ? null : (success ?? this.success),
      durationMs: durationMs ?? this.durationMs,
    );
  }

  /// Index into the 5-step phase indicator (连接/擦除/编程/验证/复位).
  int get phaseIndex {
    switch (phase) {
      case FlashPhase.connecting:
        return 0;
      case FlashPhase.erasing:
        return 1;
      case FlashPhase.programming:
        return 2;
      case FlashPhase.verifying:
        return 3;
      case FlashPhase.resetting:
        return 4;
      case FlashPhase.idle:
        return 0;
    }
  }
}

class FlashNotifier extends StateNotifier<FlashState> {
  final FlashService _service = FlashService();
  DateTime? _operationStart;

  FlashNotifier() : super(const FlashState());

  void setFirmware(String path, String format) {
    state = state.copyWith(firmwarePath: path, firmwareFormat: format);
  }

  void setStartAddress(int address) {
    state = state.copyWith(startAddress: address);
  }

  void startOperation(FlashPhase phase, FlashOperationType type) {
    _operationStart = DateTime.now();
    state = state.copyWith(
      phase: phase,
      operationType: type,
      progress: 0.0,
      isOperating: true,
      statusMessage: 'Starting...',
      clearSpeedText: true,
      bytesWritten: 0,
      totalBytes: 0,
      clearSuccess: true,
      durationMs: 0,
    );
  }

  void complete(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      progress: 1.0,
      isOperating: false,
      statusMessage: message,
      success: true,
      durationMs: _elapsedMs(),
    );
  }

  void error(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      isOperating: false,
      statusMessage: 'Error: $message',
      success: false,
      durationMs: _elapsedMs(),
    );
  }

  int _elapsedMs() {
    final start = _operationStart;
    if (start == null) return 0;
    return DateTime.now().difference(start).inMilliseconds;
  }

  void reset() {
    state = const FlashState();
  }

  /// Map proto ProgressUpdate phase to FlashPhase
  FlashPhase _mapPhase(ProgressUpdate_Phase protoPhase) {
    switch (protoPhase) {
      case ProgressUpdate_Phase.CONNECTING:
        return FlashPhase.connecting;
      case ProgressUpdate_Phase.ERASING:
        return FlashPhase.erasing;
      case ProgressUpdate_Phase.PROGRAMMING:
        return FlashPhase.programming;
      case ProgressUpdate_Phase.VERIFYING:
        return FlashPhase.verifying;
      case ProgressUpdate_Phase.RESETTING:
        return FlashPhase.resetting;
      default:
        return FlashPhase.connecting;
    }
  }

  String? _computeSpeed(int bytesWritten) {
    final start = _operationStart;
    if (start == null || bytesWritten <= 0) return null;
    final seconds = DateTime.now().difference(start).inMilliseconds / 1000.0;
    if (seconds <= 0.05) return null;
    final kbPerSec = bytesWritten / seconds / 1024.0;
    if (kbPerSec >= 1024) {
      return '${(kbPerSec / 1024).toStringAsFixed(2)} MB/s';
    }
    return '${kbPerSec.toStringAsFixed(1)} KB/s';
  }

  /// Consume one streamed update; returns an error string when the backend
  /// reported a failure, otherwise null.
  String? _applyUpdate(ProgressUpdate update,
      void Function(String message, {bool isError})? onLog) {
    final phase = _mapPhase(update.phase);
    final bytesWritten = update.bytesWritten.toInt();
    state = state.copyWith(
      phase: phase,
      progress: update.progress.clamp(0.0, 1.0),
      statusMessage: update.message,
      bytesWritten: bytesWritten,
      totalBytes: update.totalBytes.toInt(),
      speedText: _computeSpeed(bytesWritten),
    );
    onLog?.call(
      '[${phase.name}] ${update.message} (${(update.progress * 100).toStringAsFixed(1)}%)',
      isError: update.error.isNotEmpty,
    );
    return update.error.isNotEmpty ? update.error : null;
  }

  /// Start firmware flash via gRPC streaming.
  Future<void> startFlash({
    String? driver,
    void Function(String message, {bool isError})? onLog,
  }) async {
    if (state.firmwarePath == null) return;
    if (state.isOperating) return;

    startOperation(FlashPhase.connecting, FlashOperationType.flash);
    onLog?.call('Starting flash: ${state.firmwarePath}');

    String? failure;
    try {
      await for (final update in _service.flashFirmware(
        firmwarePath: state.firmwarePath!,
        startAddress: state.startAddress,
        driver: driver ?? '',
      )) {
        failure = _applyUpdate(update, onLog) ?? failure;
      }
      if (failure != null) {
        error(failure);
        onLog?.call('Flash failed: $failure', isError: true);
      } else {
        complete('Flash completed successfully');
        onLog?.call('Flash completed successfully');
      }
    } catch (e) {
      error(e.toString());
      onLog?.call('Flash error: $e', isError: true);
    }
  }

  /// Start chip/sector erase via gRPC streaming.
  Future<void> startErase({
    String mode = 'chip',
    int startAddress = 0,
    int length = 0,
    void Function(String message, {bool isError})? onLog,
  }) async {
    if (state.isOperating) return;

    startOperation(FlashPhase.erasing, FlashOperationType.erase);
    onLog?.call('Starting $mode erase');

    String? failure;
    try {
      await for (final update in _service.eraseChip(
        mode: mode,
        startAddress: startAddress,
        length: length,
      )) {
        failure = _applyUpdate(update, onLog) ?? failure;
      }
      if (failure != null) {
        error(failure);
        onLog?.call('Erase failed: $failure', isError: true);
      } else {
        complete('Erase completed successfully');
        onLog?.call('Erase completed successfully');
      }
    } catch (e) {
      error(e.toString());
      onLog?.call('Erase error: $e', isError: true);
    }
  }
}

final flashProvider = StateNotifierProvider<FlashNotifier, FlashState>(
  (ref) => FlashNotifier(),
);
