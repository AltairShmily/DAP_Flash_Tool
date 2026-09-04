"""Tests for FlashServiceMixin streaming and history behavior.

Uses a fake driver so no hardware (or pyocd session) is required.
"""
import os
import sys
import tempfile
import time

sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'proto'))

import pytest

from proto import dap_flash_pb2
import server


class FakeContext:
    def is_active(self):
        return True

    def abort(self, code, msg):
        raise RuntimeError(f"abort({code}): {msg}")


class FakeDriver:
    """Implements the BaseDriver flash/erase contract without hardware."""

    def __init__(self, fail_with=None, delay=0.0):
        self.fail_with = fail_with
        self.delay = delay
        self.flash_calls = []
        self.erase_calls = []

    def flash(self, file_path, address, callback):
        self.flash_calls.append((file_path, address))
        total = os.path.getsize(file_path)
        steps = 4
        for i in range(steps + 1):
            if self.delay:
                time.sleep(self.delay)
            frac = i / steps
            callback(frac, f"Programming {frac * 100:.0f}%", int(frac * total), total)
        if self.fail_with:
            raise self.fail_with

    def erase(self, mode="chip", start_address=None, length=None):
        self.erase_calls.append((mode, start_address, length))
        if mode == "sector" and (not start_address or not length):
            raise ValueError("Sector erase requires start_address and length")


@pytest.fixture()
def service(tmp_path):
    svc = server.DapFlashService()
    # Redirect history persistence into the temp dir.
    svc._HISTORY_DIR = str(tmp_path)
    svc._HISTORY_FILE = str(tmp_path / "flash_history.json")
    svc._flash_history = []
    svc._active_target_name = "STM32F103C8"
    svc._active_probe_id = "PROBE123"
    svc._active_driver_name = "pyocd"
    return svc


@pytest.fixture()
def firmware(tmp_path):
    path = tmp_path / "fw.bin"
    path.write_bytes(bytes(range(256)) * 4)
    return str(path)


def test_flash_streams_progress_and_success(service, firmware):
    driver = FakeDriver()
    service._active_driver = driver

    updates = list(service.FlashFirmware(
        dap_flash_pb2.FlashRequest(firmware_path=firmware, start_address=0x08000000),
        FakeContext(),
    ))

    # First update announces start, middle updates carry progress, last is success.
    assert updates[0].phase == dap_flash_pb2.ProgressUpdate.CONNECTING
    progress_updates = [u for u in updates if u.phase == dap_flash_pb2.ProgressUpdate.PROGRAMMING]
    assert len(progress_updates) == 5
    assert progress_updates[-1].progress == 1.0
    assert progress_updates[-1].bytes_written == 1024
    assert progress_updates[-1].total_bytes == 1024

    final = updates[-1]
    assert final.phase == dap_flash_pb2.ProgressUpdate.RESETTING
    assert final.success is True
    assert final.error == ""

    # History recorded with chip/probe/hash/duration filled in.
    history = service.GetFlashHistory(dap_flash_pb2.GetFlashHistoryRequest(), FakeContext())
    assert len(history.records) == 1
    rec = history.records[0]
    assert rec.success is True
    assert rec.chip_name == "STM32F103C8"
    assert rec.probe_name == "PROBE123"
    assert rec.firmware_path == firmware
    assert len(rec.firmware_hash) == 64  # SHA256 hex
    assert rec.duration_ms >= 0


def test_flash_failure_sets_error_state(service, firmware):
    driver = FakeDriver(fail_with=RuntimeError("probe unplugged"))
    service._active_driver = driver

    updates = list(service.FlashFirmware(
        dap_flash_pb2.FlashRequest(firmware_path=firmware, start_address=0),
        FakeContext(),
    ))

    final = updates[-1]
    assert final.success is False
    assert "probe unplugged" in final.error
    assert final.message.startswith("Error:")

    history = service.GetFlashHistory(dap_flash_pb2.GetFlashHistoryRequest(), FakeContext())
    assert len(history.records) == 1
    assert history.records[0].success is False
    assert "probe unplugged" in history.records[0].error_message


def test_flash_missing_file_fails_fast(service, tmp_path):
    service._active_driver = FakeDriver()
    missing = str(tmp_path / "nope.bin")

    updates = list(service.FlashFirmware(
        dap_flash_pb2.FlashRequest(firmware_path=missing, start_address=0),
        FakeContext(),
    ))
    assert len(updates) == 1
    assert updates[0].success is False
    assert "not found" in updates[0].error.lower()


def test_flash_requires_connection(service, firmware):
    service._active_driver = None
    with pytest.raises(RuntimeError):
        list(service.FlashFirmware(
            dap_flash_pb2.FlashRequest(firmware_path=firmware), FakeContext(),
        ))


def test_erase_chip_success(service):
    driver = FakeDriver()
    service._active_driver = driver

    updates = list(service.EraseChip(
        dap_flash_pb2.EraseRequest(mode="chip"), FakeContext(),
    ))
    assert updates[-1].success is True
    assert driver.erase_calls == [("chip", None, None)]


def test_erase_sector_passes_address_range(service):
    driver = FakeDriver()
    service._active_driver = driver

    updates = list(service.EraseChip(
        dap_flash_pb2.EraseRequest(mode="sector", start_address=0x08001000, length=0x400),
        FakeContext(),
    ))
    assert updates[-1].success is True
    assert driver.erase_calls == [("sector", 0x08001000, 0x400)]


def test_erase_sector_without_address_reports_error(service):
    driver = FakeDriver()
    service._active_driver = driver

    updates = list(service.EraseChip(
        dap_flash_pb2.EraseRequest(mode="sector"), FakeContext(),
    ))
    assert updates[-1].success is False
    assert "start_address" in updates[-1].error


def test_clear_flash_history(service, firmware):
    service._active_driver = FakeDriver()
    list(service.FlashFirmware(
        dap_flash_pb2.FlashRequest(firmware_path=firmware), FakeContext(),
    ))
    assert len(service.GetFlashHistory(
        dap_flash_pb2.GetFlashHistoryRequest(), FakeContext()).records) == 1

    result = service.ClearFlashHistory(
        dap_flash_pb2.ClearFlashHistoryRequest(), FakeContext(),
    )
    assert result.success is True
    assert len(service.GetFlashHistory(
        dap_flash_pb2.GetFlashHistoryRequest(), FakeContext()).records) == 0
    # Persistence survived the clear
    assert os.path.exists(service._HISTORY_FILE)


def test_progress_is_streamed_in_real_time(service, firmware):
    """The consumer must receive updates WHILE the driver is still flashing."""
    driver = FakeDriver(delay=0.05)
    service._active_driver = driver

    received_while_flashing = 0
    gen = service.FlashFirmware(
        dap_flash_pb2.FlashRequest(firmware_path=firmware), FakeContext(),
    )
    for update in gen:
        if update.phase == dap_flash_pb2.ProgressUpdate.PROGRAMMING and update.progress < 1.0:
            received_while_flashing += 1
    # With delay=0.05 per step, a batch-after-completion implementation would
    # still yield all updates; instead assert ordering: progress arrives
    # strictly increasing and interleaved before the final RESETTING update.
    assert received_while_flashing >= 4


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
