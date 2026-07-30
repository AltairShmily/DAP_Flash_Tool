"""Tests for firmware file parsers (BIN, HEX, ELF)."""

import os
import struct
import sys

sys.path.insert(0, os.path.dirname(__file__))

from parsers.hex_parser import parse_hex
from parsers.elf_parser import parse_elf
from parsers.bin_parser import parse_bin
from parsers import FirmwareFormat


def test_bin_parser():
    """Test BIN parser with a simple binary file."""
    test_path = "test.bin"
    with open(test_path, "wb") as f:
        f.write(b"\x00" * 1024)

    result = parse_bin(test_path, base_address=0x08000000)
    assert result.total_size == 1024
    assert result.base_address == 0x08000000
    assert len(result.segments) == 1
    assert result.format == FirmwareFormat.BIN
    assert result.entry_point is None
    assert result.segments[0].address == 0x08000000
    assert result.segments[0].size == 1024
    print("BIN parser OK")

    os.remove(test_path)


def test_bin_parser_custom_address():
    """Test BIN parser with custom base address."""
    test_path = "test_custom.bin"
    test_data = bytes(range(256)) * 4  # 1024 bytes of pattern data
    with open(test_path, "wb") as f:
        f.write(test_data)

    result = parse_bin(test_path, base_address=0x00000000)
    assert result.total_size == 1024
    assert result.base_address == 0x00000000
    assert result.segments[0].data == test_data
    print("BIN parser custom address OK")

    os.remove(test_path)


def test_hex_parser():
    """Test HEX parser with a synthetically created Intel HEX file."""
    test_path = "test.hex"

    # Create a minimal valid Intel HEX file manually
    # Format: :LLAAAATT[DD...]CC
    lines = []

    # Extended linear address record (sets upper 16 bits to 0x0800)
    lines.append(":020000040800F2")

    # Data record at offset 0x0000 with 4 bytes: 0xDEADBEEF
    data = bytes([0xDE, 0xAD, 0xBE, 0xEF])
    addr = 0x0000
    rec_type = 0x00
    byte_count = len(data)
    checksum = (~(byte_count + (addr >> 8) + (addr & 0xFF) + rec_type + sum(data)) + 1) & 0xFF
    hex_line = f":{byte_count:02X}{addr:04X}{rec_type:02X}{data.hex().upper()}{checksum:02X}"
    lines.append(hex_line)

    # End of file record
    lines.append(":00000001FF")

    with open(test_path, "w") as f:
        f.write("\n".join(lines) + "\n")

    result = parse_hex(test_path)
    assert result.format == FirmwareFormat.HEX
    assert len(result.segments) >= 1
    assert result.total_size > 0
    assert result.base_address == 0x08000000
    # Verify data content
    assert result.segments[0].data[:4] == b"\xDE\xAD\xBE\xEF"
    print("HEX parser OK")

    os.remove(test_path)


def test_elf_parser():
    """Test ELF parser with a synthetically created minimal ELF file."""
    test_path = "test.elf"

    # Build a minimal 32-bit little-endian ELF with one PT_LOAD segment
    EI_MAG = b"\x7fELF"
    EI_CLASS = b"\x01"  # 32-bit
    EI_DATA = b"\x01"   # little-endian
    EI_VERSION = b"\x01"
    EI_OSABI = b"\x00"
    EI_PAD = b"\x00" * 8

    e_ident = EI_MAG + EI_CLASS + EI_DATA + EI_VERSION + EI_OSABI + EI_PAD  # 16 bytes
    assert len(e_ident) == 16

    e_type = struct.pack("<H", 2)       # ET_EXEC
    e_machine = struct.pack("<H", 40)    # ARM
    e_version = struct.pack("<I", 1)
    e_entry = struct.pack("<I", 0x08000100)  # entry point
    e_phoff = struct.pack("<I", 52)      # program header offset right after ELF header
    e_shoff = struct.pack("<I", 0)       # no section headers
    e_flags = struct.pack("<I", 0x05000200)  # ARM flags
    e_ehsize = struct.pack("<H", 52)
    e_phentsize = struct.pack("<H", 32)
    e_phnum = struct.pack("<H", 1)
    e_shentsize = struct.pack("<H", 0)
    e_shnum = struct.pack("<H", 0)
    e_shstrndx = struct.pack("<H", 0)

    elf_header = (e_ident + e_type + e_machine + e_version + e_entry +
                  e_phoff + e_shoff + e_flags + e_ehsize + e_phentsize +
                  e_phnum + e_shentsize + e_shnum + e_shstrndx)
    assert len(elf_header) == 52

    # Program header (32 bytes each)
    load_data = b"\x00\x01\x02\x03\x04\x05\x06\x07" * 4  # 32 bytes
    p_filesz = len(load_data)
    p_memsz = p_filesz + 64  # some BSS

    phdr = struct.pack("<IIIIIIII",
        1,               # PT_LOAD
        64,              # p_offset (after ELF header + phdr)
        0x08000000,      # p_vaddr
        0x08000000,      # p_paddr
        p_filesz,        # p_filesz
        p_memsz,         # p_memsz
        5,               # p_flags (PF_R | PF_X)
        4,               # p_align
    )
    assert len(phdr) == 32

    # Padding to offset 64
    padding = b"\x00" * (64 - 52 - 32)  # should be negative, let me fix

    # Recalculate: ELF header = 52, phdr = 32, total = 84. But p_offset = 64 won't work.
    # Let me set p_offset = 84 (right after header + phdr)
    phdr = struct.pack("<IIIIIIII",
        1,               # PT_LOAD
        52 + 32,         # p_offset = 84 (right after header + phdr)
        0x08000000,      # p_vaddr
        0x08000000,      # p_paddr
        p_filesz,        # p_filesz
        p_memsz,         # p_memsz
        5,               # p_flags (PF_R | PF_X)
        4,               # p_align
    )

    with open(test_path, "wb") as f:
        f.write(elf_header)
        f.write(phdr)
        f.write(load_data)

    result = parse_elf(test_path)
    assert result.format == FirmwareFormat.ELF
    assert result.entry_point == 0x08000100
    assert len(result.segments) == 1
    assert result.segments[0].address == 0x08000000
    assert result.segments[0].data == load_data
    assert result.segments[0].size == 32
    assert result.total_size == 32
    assert result.base_address == 0x08000000
    print("ELF parser OK")

    os.remove(test_path)


if __name__ == "__main__":
    test_bin_parser()
    test_bin_parser_custom_address()
    test_hex_parser()
    test_elf_parser()
    print("All parser tests passed!")
