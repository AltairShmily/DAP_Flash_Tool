import os
import json
from pathlib import Path

from . import PackInfo
from .pack_parser import parse_pack


class PackManager:
    def __init__(self, packs_dir: str | None = None):
        self._packs_dir = packs_dir or os.path.join(
            os.path.expanduser("~"), ".dap_flash_tool", "packs"
        )
        os.makedirs(self._packs_dir, exist_ok=True)
        self._packs: dict[str, PackInfo] = {}
        self._index_path = os.path.join(self._packs_dir, "index.json")
        self._load_index()

    def _load_index(self):
        if os.path.exists(self._index_path):
            with open(self._index_path, 'r') as f:
                data = json.load(f)
                for pack_data in data:
                    pack_path = pack_data.get('path', '')
                    if os.path.exists(pack_path):
                        try:
                            self._packs[pack_path] = parse_pack(pack_path)
                        except Exception:
                            pass

    def _save_index(self):
        data = [{'path': path} for path in self._packs.keys()]
        with open(self._index_path, 'w') as f:
            json.dump(data, f, indent=2)

    def scan_directory(self, directory: str) -> list[PackInfo]:
        """Scan a directory for .pack files."""
        found = []
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.pack'):
                    pack_path = os.path.join(root, file)
                    try:
                        pack_info = parse_pack(pack_path)
                        self._packs[pack_path] = pack_info
                        found.append(pack_info)
                    except Exception as e:
                        print(f"Failed to parse {pack_path}: {e}")
        self._save_index()
        return found

    def get_all_packs(self) -> list[PackInfo]:
        """Get all loaded packs."""
        return list(self._packs.values())

    def search_chips(self, query: str) -> list[tuple[str, PackInfo]]:
        """Search for chips matching query across all packs."""
        results = []
        for pack in self._packs.values():
            for chip in pack.chips:
                if query.lower() in chip.name.lower():
                    results.append((chip.name, pack))
        return results

    def get_chip_info(self, chip_name: str) -> tuple | None:
        """Get chip info by name."""
        for pack in self._packs.values():
            for chip in pack.chips:
                if chip.name.lower() == chip_name.lower():
                    return chip
        return None
