"""Device Service - Handles DAP-Link probe discovery and management.

Provides gRPC service methods for:
- Listing connected DAP-Link probes
- Connecting/disconnecting from probes
- Reading chip identification
- Resetting target device
"""

import grpc
from google.protobuf import empty_pb2

from proto import dap_flash_pb2
from drivers.base import BaseDriver

# Import drivers gracefully - they may not be installed in all environments
try:
    from drivers.pyocd_driver import PyOCDDriver
    _HAS_PYOCD = True
except ImportError:
    _HAS_PYOCD = False

try:
    from drivers.openocd_driver import OpenOCDDriver
    _HAS_OPENOCD = True
except ImportError:
    _HAS_OPENOCD = False


class DeviceServiceMixin:
    """Device management methods for the gRPC servicer."""

    def _init_drivers(self):
        self._drivers: dict[str, BaseDriver] = {}
        if _HAS_PYOCD:
            self._drivers["pyocd"] = PyOCDDriver()
        if _HAS_OPENOCD:
            self._drivers["openocd"] = OpenOCDDriver()
        self._active_driver: BaseDriver | None = None
        self._active_driver_name: str = ""

    def ListProbes(self, request, context):
        all_probes = []
        for name, driver in self._drivers.items():
            try:
                probes = driver.list_probes()
                for p in probes:
                    all_probes.append(dap_flash_pb2.Probe(
                        id=p.id, name=p.name, vendor=p.vendor, serial_number=p.serial_number,
                    ))
            except Exception:
                pass
        return dap_flash_pb2.ProbeList(probes=all_probes)

    def ConnectProbe(self, request, context):
        driver_name = "pyocd"
        driver = self._drivers.get(driver_name)
        if not driver:
            return dap_flash_pb2.ConnectResponse(
                success=False, error_message=f"Driver '{driver_name}' not available"
            )
        try:
            driver.connect(
                probe_id=request.probe_id,
                target=request.target,
                frequency=request.frequency,
                protocol=request.protocol,
            )
            self._active_driver = driver
            self._active_driver_name = driver_name
            return dap_flash_pb2.ConnectResponse(success=True, target_name=request.target)
        except Exception as e:
            return dap_flash_pb2.ConnectResponse(success=False, error_message=str(e))

    def DisconnectProbe(self, request, context):
        if self._active_driver:
            self._active_driver.disconnect()
            self._active_driver = None
            self._active_driver_name = ""
        return empty_pb2.Empty()

    def GetProbeDetails(self, request, context):
        """Get detailed probe information."""
        probe_id = request.probe_id
        for driver in self._drivers.values():
            try:
                if hasattr(driver, 'get_probe_details'):
                    details = driver.get_probe_details(probe_id)
                    return dap_flash_pb2.ProbeDetails(
                        id=details.id,
                        name=details.name,
                        vendor=details.vendor,
                        serial_number=details.serial_number,
                        firmware_version=details.firmware_version,
                        hardware_version=details.hardware_version,
                        target_voltage=details.target_voltage,
                        is_connected=details.is_connected,
                    )
            except Exception:
                continue
        context.abort(grpc.StatusCode.NOT_FOUND, f"Probe {probe_id} not found")

    def ResetTarget(self, request, context):
        if not self._active_driver:
            return dap_flash_pb2.OperationResult(success=False, message="No device connected")
        try:
            if request.type == dap_flash_pb2.ResetRequest.SOFTWARE:
                self._active_driver.reset_software()
            else:
                self._active_driver.reset_hardware()
            return dap_flash_pb2.OperationResult(success=True, message="Target reset successfully")
        except Exception as e:
            return dap_flash_pb2.OperationResult(success=False, message=str(e))

    def ReadChipId(self, request, context):
        if not self._active_driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")
        try:
            chip_info = self._active_driver.read_chip_id()
            return dap_flash_pb2.ChipIdResult(
                chip_id=chip_info.chip_id, description=chip_info.description
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INTERNAL, str(e))
