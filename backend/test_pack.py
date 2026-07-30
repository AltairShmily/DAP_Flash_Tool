"""Tests for Pack Manager and Pack Parser."""
import os
import sys
import tempfile
import zipfile

sys.path.insert(0, os.path.dirname(__file__))

from pack import ChipDefinition, PackInfo
from pack.pack_manager import PackManager
from pack.pack_parser import parse_pack


SAMPLE_PDSC = """<?xml version="1.0" encoding="UTF-8"?>
<package name="TestPack" vendor="TestVendor" version="1.2.3">
  <devices>
    <device family="STM32F4">
      <device name="STM32F407VG" Dvendor="STMicroelectronics">
        <memory name="Flash" start="0x08000000" size="0x100000" access="rx"/>
        <memory name="RAM" start="0x20000000" size="0x20000" access="rw"/>
      </device>
      <device name="STM32F411RE" Dvendor="STMicroelectronics">
        <memory name="Flash" start="0x08000000" size="0x80000" access="rx"/>
        <memory name="RAM" start="0x20000000" size="0x20000" access="rw"/>
      </device>
    </device>
  </devices>
</package>
"""


def test_dataclasses():
    """Test that dataclasses are importable and work."""
    chip = ChipDefinition(
        name="TEST", vendor="V", family="F",
        flash_base=0x08000000, flash_size=0x10000,
        ram_base=0x20000000, ram_size=0x4000,
    )
    assert chip.name == "TEST"
    assert chip.flash_base == 0x08000000

    pack = PackInfo(name="P", vendor="V", version="1.0", path="/tmp/test.pack", chips=[chip])
    assert len(pack.chips) == 1
    print("Dataclasses OK")


def test_pack_parser():
    """Test parsing a .pack file containing a PDSC."""
    with tempfile.NamedTemporaryFile(suffix='.pack', delete=False) as tmp:
        pack_path = tmp.name

    try:
        # Create a .pack (ZIP) with a .pdsc inside
        with zipfile.ZipFile(pack_path, 'w') as zf:
            zf.writestr("TestVendor.TestPack.pdsc", SAMPLE_PDSC)

        result = parse_pack(pack_path)

        assert result.name == "TestPack"
        assert result.vendor == "TestVendor"
        assert result.version == "1.2.3"
        assert len(result.chips) == 2

        chip0 = result.chips[0]
        assert chip0.name == "STM32F407VG"
        assert chip0.vendor == "STMicroelectronics"
        assert chip0.family == "STM32F4"
        assert chip0.flash_base == 0x08000000
        assert chip0.flash_size == 0x100000
        assert chip0.ram_base == 0x20000000
        assert chip0.ram_size == 0x20000

        chip1 = result.chips[1]
        assert chip1.name == "STM32F411RE"
        assert chip1.flash_size == 0x80000

        print("PackParser OK")
    finally:
        os.unlink(pack_path)


def test_pack_parser_no_pdsc():
    """Test that a .pack without .pdsc raises ValueError."""
    with tempfile.NamedTemporaryFile(suffix='.pack', delete=False) as tmp:
        pack_path = tmp.name

    try:
        with zipfile.ZipFile(pack_path, 'w') as zf:
            zf.writestr("readme.txt", "No PDSC here")

        try:
            parse_pack(pack_path)
            assert False, "Should have raised ValueError"
        except ValueError as e:
            assert "No .pdsc file" in str(e)
        print("PackParser no-pdsc error OK")
    finally:
        os.unlink(pack_path)


def test_pack_manager():
    """Test PackManager with a temp directory of .pack files."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create a .pack file in tmpdir
        pack_path = os.path.join(tmpdir, "TestVendor.TestPack.pack")
        with zipfile.ZipFile(pack_path, 'w') as zf:
            zf.writestr("TestVendor.TestPack.pdsc", SAMPLE_PDSC)

        pm = PackManager(packs_dir=tmpdir)

        # Scan
        found = pm.scan_directory(tmpdir)
        assert len(found) >= 1

        # Get all packs
        packs = pm.get_all_packs()
        assert len(packs) >= 1

        # Search chips
        results = pm.search_chips("STM32F407")
        assert len(results) >= 1
        assert results[0][0] == "STM32F407VG"

        # Get chip info
        chip = pm.get_chip_info("STM32F407VG")
        assert chip is not None
        assert chip.flash_size == 0x100000

        # Chip not found
        assert pm.get_chip_info("NONEXISTENT") is None

        print("PackManager OK")


def test_pack_manager_empty_dir():
    """Test PackManager with empty directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        pm = PackManager(packs_dir=tmpdir)
        packs = pm.get_all_packs()
        assert len(packs) == 0

        results = pm.search_chips("anything")
        assert len(results) == 0

        assert pm.get_chip_info("anything") is None
        print("PackManager empty OK")


if __name__ == "__main__":
    test_dataclasses()
    test_pack_parser()
    test_pack_parser_no_pdsc()
    test_pack_manager()
    test_pack_manager_empty_dir()
    print("All pack tests passed!")
