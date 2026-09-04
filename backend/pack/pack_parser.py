"""PDSC parser for CMSIS-Pack files.

Handles the real CMSIS-Pack schema:
- <package><vendor>/<name> child elements (NOT root attributes)
- version from <releases><release version="..."> (latest first)
- devices use Dname/Dfamily/Dvendor attributes (family elements nest devices)
- memory info from <memory access/start/size> (inherited from ancestors)
  with <algorithm start/size> as flash-range fallback
"""

import zipfile

from defusedxml import ElementTree as ET

from . import PackInfo, ChipDefinition

_DEFAULT_FLASH_BASE = 0x08000000
_DEFAULT_FLASH_SIZE = 0x10000
_DEFAULT_RAM_BASE = 0x20000000
_DEFAULT_RAM_SIZE = 0x4000

_DEVICE_TAGS = ("family", "subFamily", "device", "variant")


def _parse_int(value, default=0):
    try:
        return int(value, 0)
    except (TypeError, ValueError):
        return default


def _clean_vendor(raw):
    """PDSC Dvendor has the form 'STMicroelectronics:13' — drop the id."""
    return raw.split(":", 1)[0].strip() if raw else ""


def _walk_ancestors(element, parent_map):
    """Yield element, then its device-hierarchy ancestors (closest first)."""
    node = element
    seen = set()
    while node is not None and id(node) not in seen:
        seen.add(id(node))
        yield node
        node = parent_map.get(node)


def _find_memory(device, parent_map):
    """Resolve flash/RAM ranges for a device, honoring ancestor inheritance."""
    flash_start = flash_size = ram_start = ram_size = None

    for node in _walk_ancestors(device, parent_map):
        if node.tag not in _DEVICE_TAGS:
            continue
        for mem in node.findall("memory"):
            start = _parse_int(mem.get("start"))
            size = _parse_int(mem.get("size"))
            if not size:
                continue
            access = (mem.get("access") or "").lower()
            name = f"{mem.get('id', '')}{mem.get('name', '')}".lower()
            is_ram = "w" in access
            if not access:
                is_ram = name.startswith(("iram", "ram", "sram"))
            if is_ram:
                if ram_start is None:
                    ram_start, ram_size = start, size
            else:
                if flash_start is None:
                    flash_start, flash_size = start, size
        # <algorithm> elements describe flash programming ranges
        if flash_start is None:
            for algo in node.findall(".//algorithm"):
                start = _parse_int(algo.get("start"))
                size = _parse_int(algo.get("size"))
                if size:
                    flash_start, flash_size = start, size
                    break
        if flash_start is not None and ram_start is not None:
            break

    return (
        flash_start if flash_start is not None else _DEFAULT_FLASH_BASE,
        flash_size if flash_size is not None else _DEFAULT_FLASH_SIZE,
        ram_start if ram_start is not None else _DEFAULT_RAM_BASE,
        ram_size if ram_size is not None else _DEFAULT_RAM_SIZE,
    )


def parse_pdsc_bytes(pdsc_content: bytes, pack_path: str) -> PackInfo:
    # Legitimate PDSC files never carry a DOCTYPE (they reference an XSD),
    # so DTDs are rejected outright to block entity-expansion attacks.
    root = ET.fromstring(pdsc_content, forbid_dtd=True)

    # Package metadata: child elements, not root attributes.
    pack_vendor = (root.findtext("vendor") or root.get("vendor") or "Unknown").strip()
    pack_name = (root.findtext("name") or root.get("name") or "Unknown").strip()

    pack_version = root.get("version", "")
    if not pack_version:
        releases = root.find("releases")
        if releases is not None:
            # The latest release is conventionally the first entry.
            first = releases.find("release")
            if first is not None:
                pack_version = first.get("version", "")
    pack_version = pack_version or "0.0.0"

    parent_map = {c: p for p in root.iter() for c in p}

    chips = []
    seen_names = set()
    for device in root.findall(".//devices//device"):
        chip_name = (device.get("Dname") or device.get("name") or "").strip()
        if not chip_name or chip_name in seen_names:
            continue

        chip_vendor = ""
        chip_family = ""
        for node in _walk_ancestors(device, parent_map):
            if node.tag not in _DEVICE_TAGS:
                continue
            if not chip_vendor:
                chip_vendor = _clean_vendor(node.get("Dvendor", ""))
            if not chip_family:
                chip_family = (node.get("Dfamily") or node.get("deviceFamily")
                               or node.get("family") or "")
            if chip_vendor and chip_family:
                break

        flash_base, flash_size, ram_base, ram_size = _find_memory(device, parent_map)

        seen_names.add(chip_name)
        chips.append(ChipDefinition(
            name=chip_name,
            vendor=chip_vendor or pack_vendor,
            family=chip_family,
            flash_base=flash_base,
            flash_size=flash_size,
            ram_base=ram_base,
            ram_size=ram_size,
        ))

    return PackInfo(
        name=pack_name,
        vendor=pack_vendor,
        version=pack_version,
        path=pack_path,
        chips=chips,
    )


def parse_pack(pack_path: str) -> PackInfo:
    """Parse a .pack file (ZIP archive) and extract chip definitions."""
    with zipfile.ZipFile(pack_path, 'r') as zf:
        pdsc_files = [f for f in zf.namelist() if f.lower().endswith('.pdsc')]
        if not pdsc_files:
            raise ValueError("No .pdsc file found in pack")
        pdsc_content = zf.read(pdsc_files[0])

    return parse_pdsc_bytes(pdsc_content, pack_path)
