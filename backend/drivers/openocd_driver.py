import subprocess
import socket
import time
from typing import Callable

from .base import BaseDriver, ProbeInfo, ChipInfo


class OpenOCDDriver(BaseDriver):
    def __init__(self, openocd_path: str = "openocd"):
        self._openocd_path = openocd_path
        self._process: subprocess.Popen | None = None
        self._tcl_port = 6666
        self._connected = False

    def list_probes(self) -> list[ProbeInfo]:
        # OpenOCD doesn't have a simple probe listing API
        return []

    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        interface = "stlink" if "stlink" in probe_id.lower() else "cmsis-dap"
        cmd = [
            self._openocd_path,
            "-f", f"interface/{interface}.cfg",
            "-f", f"target/{target}.cfg",
            "-c", f"adapter speed {frequency}",
        ]
        self._process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        time.sleep(1)
        if self._process.poll() is not None:
            raise RuntimeError("OpenOCD failed to start")
        self._connected = True

    def _send_tcl(self, command: str) -> str:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(("localhost", self._tcl_port))
            s.sendall(command.encode() + b"\x1a")
            return s.recv(4096).decode()

    def disconnect(self) -> None:
        if self._process:
            try:
                self._send_tcl("shutdown")
            except Exception:
                pass
            self._process.terminate()
            self._process = None
        self._connected = False

    def is_connected(self) -> bool:
        return self._connected and self._process is not None

    def flash(self, file_path: str, address: int, callback: Callable[[float, str], None]) -> None:
        callback(0.0, "Starting flash...")
        self._send_tcl(f"flash write_image erase {file_path} 0x{address:x}")
        callback(0.5, "Flash write complete")
        self._send_tcl("verify_image " + file_path)
        callback(0.9, "Verification complete")
        self._send_tcl("reset run")
        callback(1.0, "Done")

    def erase(self, mode: str = "chip") -> None:
        if mode == "chip":
            self._send_tcl("flash erase_address 0x08000000 0x20000")
        else:
            self._send_tcl("flash erase_sector 0 0 last")

    def reset(self) -> None:
        self._send_tcl("reset")

    def read_chip_id(self) -> ChipInfo:
        result = self._send_tcl("targets")
        return ChipInfo(chip_id=0, description=result.strip())

    def install_pack(self, pack_path: str) -> bool:
        """OpenOCD does not support pack management."""
        raise RuntimeError("OpenOCD does not support pack management")

    def list_installed_packs(self) -> list[dict]:
        """OpenOCD does not support pack management."""
        return []
