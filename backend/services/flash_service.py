"""Flash Service - Handles firmware flashing operations.

Provides gRPC service methods for:
- Writing firmware to target MCU (real-time streamed progress)
- Erasing flash memory (chip or sector range)
- Streaming progress updates during operations
- Flash history tracking (persisted to ~/.dap_flash_tool/flash_history.json)
"""

import hashlib
import json
import os
import queue
import threading
import time

import grpc

from proto import dap_flash_pb2

_DONE = "done"
_ERROR = "error"
_PROGRESS = "progress"


class FlashServiceMixin:
    """Flash and erase operations for the gRPC servicer."""

    _HISTORY_DIR = os.path.join(os.path.expanduser("~"), ".dap_flash_tool")
    _HISTORY_FILE = os.path.join(_HISTORY_DIR, "flash_history.json")
    _MAX_HISTORY = 100

    def _init_flash_history(self):
        self._flash_history: list[dict] = []
        self._history_lock = threading.Lock()
        self._load_history()

    def _load_history(self):
        try:
            if os.path.exists(self._HISTORY_FILE):
                with open(self._HISTORY_FILE, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        self._flash_history = data
        except Exception:
            self._flash_history = []

    def _save_history(self):
        """Persist history to disk. Caller must hold _history_lock."""
        try:
            os.makedirs(self._HISTORY_DIR, exist_ok=True)
            tmp_path = self._HISTORY_FILE + ".tmp"
            with open(tmp_path, 'w', encoding='utf-8') as f:
                json.dump(self._flash_history, f, ensure_ascii=False, indent=2)
            os.replace(tmp_path, self._HISTORY_FILE)
        except Exception:
            pass

    @staticmethod
    def _file_sha256(path: str) -> str:
        try:
            h = hashlib.sha256()
            with open(path, 'rb') as f:
                for chunk in iter(lambda: f.read(1 << 20), b''):
                    h.update(chunk)
            return h.hexdigest()
        except Exception:
            return ""

    def _record_flash(self, firmware_path: str, success: bool,
                      duration_ms: int, error_message: str = ""):
        record = {
            "firmware_path": firmware_path,
            "firmware_hash": self._file_sha256(firmware_path),
            "chip_name": getattr(self, "_active_target_name", ""),
            "probe_name": getattr(self, "_active_probe_id", "")
                          or getattr(self, "_active_driver_name", ""),
            "timestamp": int(time.time()),
            "success": success,
            "duration_ms": duration_ms,
            "error_message": error_message,
        }
        with self._history_lock:
            self._flash_history.insert(0, record)
            if len(self._flash_history) > self._MAX_HISTORY:
                self._flash_history = self._flash_history[:self._MAX_HISTORY]
            self._save_history()

    def FlashFirmware(self, request, context):
        driver = self._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")
            return

        if not os.path.isfile(request.firmware_path):
            error = f"Firmware file not found: {request.firmware_path}"
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0,
                message=f"Error: {error}", success=False, error=error,
            )
            self._record_flash(request.firmware_path, False, 0, error)
            return

        start_time = time.time()
        yield dap_flash_pb2.ProgressUpdate(
            phase=dap_flash_pb2.ProgressUpdate.CONNECTING, progress=0.0,
            message="Starting flash operation...",
        )

        # Real-time streaming: the driver runs in a worker thread and pushes
        # progress into a queue; this generator yields updates as they arrive.
        events: queue.Queue = queue.Queue()

        def on_progress(progress, message, bytes_written=-1, total_bytes=-1):
            events.put((_PROGRESS, (progress, message, bytes_written, total_bytes)))

        def worker():
            try:
                driver.flash(request.firmware_path, request.start_address, on_progress)
                events.put((_DONE, None))
            except Exception as e:  # noqa: BLE001 - surfaced to the client
                events.put((_ERROR, e))

        thread = threading.Thread(target=worker, daemon=True)
        thread.start()

        failure: str | None = None
        while True:
            try:
                kind, payload = events.get(timeout=0.25)
            except queue.Empty:
                if not context.is_active():
                    # Client disconnected; let the worker finish so the device
                    # is not left mid-write, but stop streaming.
                    return
                continue
            if kind == _PROGRESS:
                progress, message, bytes_written, total_bytes = payload
                yield dap_flash_pb2.ProgressUpdate(
                    phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                    progress=max(0.0, min(1.0, float(progress))),
                    bytes_written=max(0, int(bytes_written)),
                    total_bytes=max(0, int(total_bytes)),
                    message=message,
                )
            elif kind == _DONE:
                break
            else:
                failure = str(payload)
                break

        duration_ms = int((time.time() - start_time) * 1000)
        if failure is not None:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0,
                message=f"Error: {failure}", success=False, error=failure,
            )
            self._record_flash(request.firmware_path, False, duration_ms, failure)
        else:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.RESETTING, progress=1.0,
                message="Flash complete! Target reset.", success=True,
            )
            self._record_flash(request.firmware_path, True, duration_ms)

    def EraseChip(self, request, context):
        driver = self._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")
            return

        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=0.0,
                message="Erasing chip..." if request.mode != "sector"
                        else f"Erasing sectors 0x{request.start_address:X} +{request.length} bytes...",
            )
            driver.erase(
                request.mode,
                start_address=request.start_address or None,
                length=request.length or None,
            )
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=1.0,
                message="Erase complete!", success=True,
            )
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=0.0,
                message=f"Error: {str(e)}", success=False, error=str(e),
            )

    def GetFlashHistory(self, request, context):
        with self._history_lock:
            snapshot = list(self._flash_history)
        records = [
            dap_flash_pb2.FlashRecord(
                firmware_path=r.get("firmware_path", ""),
                firmware_hash=r.get("firmware_hash", ""),
                chip_name=r.get("chip_name", ""),
                probe_name=r.get("probe_name", ""),
                timestamp=r.get("timestamp", 0),
                success=r.get("success", False),
                duration_ms=r.get("duration_ms", 0),
                error_message=r.get("error_message", ""),
            )
            for r in snapshot
        ]
        return dap_flash_pb2.FlashHistoryList(records=records)

    def ClearFlashHistory(self, request, context):
        with self._history_lock:
            self._flash_history = []
            self._save_history()
        return dap_flash_pb2.OperationResult(success=True, message="Flash history cleared")
