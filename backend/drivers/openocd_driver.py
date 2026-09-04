import os
import socket
import subprocess
import time
from typing import Optional

from .base import BaseDriver, ProbeInfo, ChipInfo, FlashProgressCallback

# OpenOCD TCL port terminates both commands and responses with 0x1a (SUB).
_TCL_TERMINATOR = b"\x1a"


class OpenOCDDriver(BaseDriver):
    def __init__(self, openocd_path: str = "openocd", tcl_port: int = 6666):
        self._openocd_path = openocd_path
        self._process: Optional[subprocess.Popen] = None
        self._tcl_port = tcl_port
        self._connected = False

    def list_probes(self) -> list[ProbeInfo]:
        # OpenOCD has no probe enumeration API; probes are configured via cfg files.
        return []

    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        if self._process is not None:
            self.disconnect()

        interface = "stlink" if "stlink" in probe_id.lower() else "cmsis-dap"
        cmd = [
            self._openocd_path,
            "-f", f"interface/{interface}.cfg",
            "-f", f"target/{target}.cfg",
        ]
        if frequency and frequency > 0:
            # OpenOCD "adapter speed" takes kHz; the gRPC contract is Hz.
            cmd += ["-c", f"adapter speed {max(1, int(frequency) // 1000)}"]
        if protocol in ("swd", "jtag"):
            cmd += ["-c", f"transport select {protocol}"]

        # DEVNULL: unread PIPE buffers would eventually block the child process.
        self._process = subprocess.Popen(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        # Wait for the TCL port to accept connections instead of a blind sleep.
        deadline = time.monotonic() + 8.0
        while time.monotonic() < deadline:
            exit_code = self._process.poll()
            if exit_code is not None:
                self._process = None
                raise RuntimeError(f"OpenOCD exited during startup (code {exit_code})")
            try:
                with socket.create_connection(("127.0.0.1", self._tcl_port), timeout=0.5):
                    self._connected = True
                    return
            except OSError:
                time.sleep(0.25)

        self._kill_process()
        raise RuntimeError(f"OpenOCD did not open TCL port {self._tcl_port} within 8 s")

    def _kill_process(self) -> None:
        if self._process:
            try:
                self._process.terminate()
                self._process.wait(timeout=3)
            except Exception:
                try:
                    self._process.kill()
                except Exception:
                    pass
            self._process = None
        self._connected = False

    def _send_tcl(self, command: str, timeout: float = 60.0) -> str:
        """Send one TCL command and read the response up to the 0x1a terminator."""
        if self._process is None or self._process.poll() is not None:
            raise RuntimeError("OpenOCD is not running")

        with socket.create_connection(("127.0.0.1", self._tcl_port), timeout=5) as s:
            s.settimeout(timeout)
            s.sendall(command.encode() + _TCL_TERMINATOR)
            chunks = []
            deadline = time.monotonic() + timeout
            while time.monotonic() < deadline:
                try:
                    data = s.recv(4096)
                except socket.timeout:
                    break
                if not data:
                    break
                chunks.append(data)
                if _TCL_TERMINATOR in data:
                    break
            response = b"".join(chunks).replace(_TCL_TERMINATOR, b"").decode(errors="replace")

        if response.startswith("Invalid") or response.startswith("Error"):
            raise RuntimeError(f"OpenOCD command failed: {command!r} -> {response.strip()}")
        return response

    def disconnect(self) -> None:
        if self._process:
            try:
                self._send_tcl("shutdown", timeout=3)
            except Exception:
                pass
            self._kill_process()
        self._connected = False

    def is_connected(self) -> bool:
        return self._connected and self._process is not None and self._process.poll() is None

    def flash(self, file_path: str, address: int, callback: FlashProgressCallback) -> None:
        if not self.is_connected():
            raise RuntimeError("OpenOCD is not running")
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Firmware file not found: {file_path}")

        total_bytes = os.path.getsize(file_path)
        quoted = file_path.replace("\\", "/")

        callback(0.0, "Starting flash...", 0, total_bytes)
        # HEX/ELF carry their own addresses; only bin needs an explicit base.
        if file_path.lower().endswith(".bin") and address and address > 0:
            self._send_tcl(f"flash write_image erase {quoted} 0x{int(address):x}", timeout=300)
        else:
            self._send_tcl(f"flash write_image erase {quoted}", timeout=300)
        callback(0.8, "Verifying...", total_bytes, total_bytes)
        self._send_tcl(f"verify_image {quoted}", timeout=300)
        callback(0.95, "Resetting target...", total_bytes, total_bytes)
        self._send_tcl("reset run")
        callback(1.0, "Done", total_bytes, total_bytes)

    def erase(self, mode: str = "chip",
              start_address: Optional[int] = None,
              length: Optional[int] = None) -> None:
        if not self.is_connected():
            raise RuntimeError("OpenOCD is not running")

        if mode == "sector":
            if not start_address or not length or length <= 0:
                raise ValueError("Sector erase requires start_address and length")
            self._send_tcl(
                f"flash erase_address 0x{int(start_address):x} {int(length)}", timeout=300
            )
        else:
            # Erase all sectors of bank 0 (chip erase) — target-agnostic,
            # unlike the previously hardcoded STM32 address range.
            self._send_tcl("flash erase_sector 0 0 last", timeout=300)

    def reset(self) -> None:
        self._send_tcl("reset run")

    def reset_software(self) -> None:
        self._send_tcl("reset run")

    def reset_hardware(self) -> None:
        self._send_tcl("reset halt")
        self._send_tcl("resume")

    def read_chip_id(self) -> ChipInfo:
        result = self._send_tcl("mdw 0xE0042000")
        return ChipInfo(chip_id=0, description=result.strip())
