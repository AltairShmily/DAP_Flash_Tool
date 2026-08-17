"""HEX Preview - Provides hexadecimal preview of firmware files.

Supports BIN and HEX formats, displaying content in classic hex dump format
with address, hex bytes, and ASCII representation.
"""


def preview_hex(file_path: str, offset: int = 0, length: int = 256) -> str:
    """Preview firmware file in hex format.
    
    Args:
        file_path: Path to firmware file (.bin or .hex)
        offset: Starting offset for preview
        length: Number of bytes to preview
        
    Returns:
        Formatted hex dump string
    """
    if file_path.endswith('.hex'):
        from intelhex import IntelHex
        ih = IntelHex(file_path)
        data = ih.tobinarray(start=offset, size=length)
    else:
        with open(file_path, 'rb') as f:
            f.seek(offset)
            data = f.read(length)
    
    lines = []
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        hex_str = ' '.join(f'{b:02X}' for b in chunk)
        ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        lines.append(f'{offset+i:08X}  {hex_str:<48s}  |{ascii_str}|')
    return '\n'.join(lines)


def get_file_info(file_path: str) -> dict:
    """Get basic firmware file information.
    
    Returns:
        Dictionary with file format, size, and base address
    """
    if file_path.endswith('.hex'):
        from intelhex import IntelHex
        ih = IntelHex(file_path)
        segments = list(ih.segments())
        total_size = sum(end - start for start, end in segments)
        base_address = min(start for start, end in segments) if segments else 0
        return {
            "format": "hex",
            "total_size": total_size,
            "base_address": base_address,
        }
    else:
        import os
        file_size = os.path.getsize(file_path)
        return {
            "format": "bin",
            "total_size": file_size,
            "base_address": 0,
        }
