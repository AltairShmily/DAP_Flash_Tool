"""Pack Service - Handles CMSIS Pack management.

Provides gRPC service methods for:
- Listing installed packs
- Searching for packs by chip/vendor
- Downloading and installing packs
- Extracting flash algorithms from packs
"""

import os
import urllib.request

from proto import dap_flash_pb2
from pack.pack_manager import PackManager


class PackServiceMixin:
    """Pack management operations for the gRPC servicer."""

    def _init_pack_manager(self):
        self._pack_manager = PackManager()

    def ListPacks(self, request, context):
        packs = self._pack_manager.get_all_packs()
        return dap_flash_pb2.PackList(
            packs=[
                dap_flash_pb2.PackInfo(
                    name=p.name, vendor=p.vendor, version=p.version, path=p.path,
                    supported_chips=[c.name for c in p.chips],
                )
                for p in packs
            ]
        )

    def SearchPacks(self, request, context):
        results = self._pack_manager.search_chips(request.query)
        return dap_flash_pb2.PackSearchResult(
            packs=[
                dap_flash_pb2.PackInfo(
                    name=pack.name, vendor=pack.vendor, version=pack.version, path=pack.path,
                    supported_chips=[chip_name],
                )
                for chip_name, pack in results
            ]
        )

    def DownloadPack(self, request, context):
        pack_dir = os.path.join(os.path.expanduser("~"), ".dap_flash_tool", "packs")
        os.makedirs(pack_dir, exist_ok=True)
        dest_path = os.path.join(pack_dir, request.pack_name)
        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING, progress=0.0,
                message=f"Downloading {request.pack_name}...",
            )
            urllib.request.urlretrieve(request.pack_url, dest_path)
            self._pack_manager.scan_directory(pack_dir)
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=1.0,
                message=f"Download complete: {dest_path}",
            )
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0,
                message=f"Download failed: {str(e)}",
            )
