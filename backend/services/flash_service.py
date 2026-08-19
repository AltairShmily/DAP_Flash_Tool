"""Flash Service - Handles firmware flashing operations.

Provides gRPC service methods for:
- Writing firmware to target MCU
- Erasing flash memory
- Verifying written firmware
- Streaming progress updates during operations
- Flash history tracking
"""

import time
import json
import os
import grpc

from proto import dap_flash_pb2


class FlashServiceMixin:
    """Flash and erase operations for the gRPC servicer."""

    _HISTORY_DIR = os.path.join(os.path.expanduser("~"), ".dap_flash_tool")
    _HISTORY_FILE = os.path.join(_HISTORY_DIR, "flash_history.json")
    _MAX_HISTORY = 100

    def _init_flash_history(self):
        self._flash_history: list[dict] = []
        self._load_history()

    def _load_history(self):
        """Load flash history from disk."""
        try:
            if os.path.exists(self._HISTORY_FILE):
                with open(self._HISTORY_FILE, 'r', encoding='utf-8') as f:
                    self._flash_history = json.load(f)
        except Exception:
            self._flash_history = []

    def _save_history(self):
        """Persist flash history to disk."""
        try:
            os.makedirs(self._HISTORY_DIR, exist_ok=True)
            with open(self._HISTORY_FILE, 'w', encoding='utf-8') as f:
                json.dump(self._flash_history, f, ensure_ascii=False, indent=2)
        except Exception:
            pass

    def _record_flash(self, firmware_path: str, success: bool,
                      duration_ms: int, error_message: str = ""):
        """Append a flash record and persist."""
        record = {
            "firmware_path": firmware_path,
            "chip_name": "",
            "probe_name": self._active_driver_name,
            "timestamp": int(time.time()),
            "success": success,
            "duration_ms": duration_ms,
            "error_message": error_message,
        }
        self._flash_history.insert(0, record)
        if len(self._flash_history) > self._MAX_HISTORY:
            self._flash_history = self._flash_history[:self._MAX_HISTORY]
        self._save_history()

    def FlashFirmware(self, request, context):
        driver = self._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")

        start_time = time.time()
        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING, progress=0.0, message="Starting flash operation..."
            )

            collected_progress = []
            def on_progress(progress, message):
                collected_progress.append((progress, message))

            driver.flash(request.firmware_path, request.start_address, on_progress)

            for progress, message in collected_progress:
                yield dap_flash_pb2.ProgressUpdate(
                    phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=progress, message=message
                )

            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.RESETTING, progress=1.0, message="Flash complete! Target reset."
            )

            # Record successful flash
            duration_ms = int((time.time() - start_time) * 1000)
            self._record_flash(request.firmware_path, True, duration_ms)
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0, message=f"Error: {str(e)}"
            )
            # Record failed flash
            duration_ms = int((time.time() - start_time) * 1000)
            self._record_flash(request.firmware_path, False, duration_ms, str(e))

    def EraseChip(self, request, context):
        driver = self._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")
        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=0.0, message="Erasing chip..."
            )
            driver.erase(request.mode)
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=1.0, message="Erase complete!"
            )
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING, progress=0.0, message=f"Error: {str(e)}"
            )

    def GetFlashHistory(self, request, context):
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
            for r in self._flash_history
        ]
        return dap_flash_pb2.FlashHistoryList(records=records)
