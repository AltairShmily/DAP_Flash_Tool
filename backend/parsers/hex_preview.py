"""HEX Preview - Provides hexadecimal preview of firmware files.

Supports BIN, HEX and ELF formats, displaying content in classic hex dump
format with address, hex bytes, and ASCII representation.

Offset semantics are unified across formats: `offset` is always a byte
offset relative to the start of the file's data (for HEX that means
relative to its lowest memory address), so UI pagination works the same
way for every format.
"""

import os


def _hex_base_and_dump(file_path: str, offset: int, length: int):
    from intelhex import IntelHex
    ih = IntelHex(file_path)
    segments = ih.segments()
    if not segments:
        raise ValueError("HEX file contains no data segments")
    base = min(start for start, _ in segments)
    data = bytes(ih.tobinarray(start=base + offset, size=length))
    return base, data


def preview_hex(file_path: str, offset: int = 0, length: int = 256) -> str:
    """Preview firmware file as a hex dump.

    Args:
        file_path: Path to firmware file (.bin, .hex or .elf)
        offset: Byte offset relative to the start of the file's data
        length: Number of bytes to preview

    Returns:
        Formatted hex dump string
    """
    offset = max(0, int(offset))
    length = max(1, min(int(length), 4096))

    if file_path.lower().endswith('.hex'):
        base, data = _hex_base_and_dump(file_path, offset, length)
        display_base = base + offset
    else:
        # BIN and ELF are previewed as raw file bytes.
        with open(file_path, 'rb') as f:
            f.seek(offset)
            data = f.read(length)
        display_base = offset

    lines = []
    for i in range(0, len(data), 16):
        chunk = data[i:i + 16]
        hex_str = ' '.join(f'{b:02X}' for b in chunk)
        ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        lines.append(f'{display_base + i:08X}  {hex_str:<48s}  |{ascii_str}|')
    return '\n'.join(lines)


def get_file_info(file_path: str) -> dict:
    """Get basic firmware file information.

    Returns:
        Dictionary with file format, total data size, and base address
    """
    lower = file_path.lower()

    if lower.endswith('.hex'):
        from intelhex import IntelHex
        ih = IntelHex(file_path)
        segments = list(ih.segments())
        if not segments:
            raise ValueError("HEX file contains no data segments")
        total_size = sum(end - start for start, end in segments)
        base_address = min(start for start, _ in segments)
        return {
            "format": "hex",
            "total_size": total_size,
            "base_address": base_address,
        }

    if lower.endswith('.elf'):
        from .elf_parser import parse_elf
        parsed = parse_elf(file_path)
        return {
            "format": "elf",
            "total_size": parsed.total_size,
            "base_address": parsed.base_address,
        }

    return {
        "format": "bin",
        "total_size": os.path.getsize(file_path),
        "base_address": 0,
    }
