"""Flash Service - Handles firmware flashing operations.

Provides gRPC service methods for:
- Writing firmware to target MCU
- Erasing flash memory
- Verifying written firmware
- Streaming progress updates during operations
- Flash history tracking
"""

import time
import grpc

from proto import dap_flash_pb2


class FlashServiceMixin:
    """Flash and erase operations for the gRPC servicer."""

    def _init_flash_history(self):
        self._flash_history: list[dap_flash_pb2.FlashRecord] = []

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
            self._flash_history.append(dap_flash_pb2.FlashRecord(
                firmware_path=request.firmware_path,
                chip_name="",
                probe_name=self._active_driver_name,
                timestamp=int(time.time()),
                success=True,
                duration_ms=duration_ms,
            ))
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0, message=f"Error: {str(e)}"
            )
            # Record failed flash
            duration_ms = int((time.time() - start_time) * 1000)
            self._flash_history.append(dap_flash_pb2.FlashRecord(
                firmware_path=request.firmware_path,
                chip_name="",
                probe_name=self._active_driver_name,
                timestamp=int(time.time()),
                success=False,
                duration_ms=duration_ms,
                error_message=str(e),
            ))

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
        return dap_flash_pb2.FlashHistoryList(records=list(self._flash_history))
