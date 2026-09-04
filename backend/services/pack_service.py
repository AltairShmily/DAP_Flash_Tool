"""Pack Service - Handles CMSIS Pack management.

Provides gRPC service methods for:
- Listing installed packs
- Searching packs online (Keil pidx index) with local fallback
- Downloading packs (streamed progress, HTTP Range resume, integrity check)
- Installing and scanning local packs
"""

import os
import threading
import time
import urllib.parse
import urllib.request
import zipfile

from defusedxml import ElementTree as ET

from proto import dap_flash_pb2
from pack.pack_manager import PackManager

_PIDX_URL = "https://www.keil.com/pack/index.pidx"
_PIDX_CACHE_TTL = 6 * 3600  # seconds
_DOWNLOAD_CHUNK = 64 * 1024


class PackServiceMixin:
    """Pack management operations for the gRPC servicer."""

    def _init_pack_manager(self):
        self._pack_manager = PackManager()
        self._pidx_lock = threading.Lock()
        self._pidx_cache: list[dict] | None = None
        self._pidx_fetched_at = 0.0

    # ── online index ──────────────────────────────────────────────────────

    def _fetch_pidx(self) -> list[dict]:
        """Fetch and parse the Keil pack index. Cached for _PIDX_CACHE_TTL."""
        with self._pidx_lock:
            now = time.monotonic()
            if self._pidx_cache is not None and now - self._pidx_fetched_at < _PIDX_CACHE_TTL:
                return self._pidx_cache

            req = urllib.request.Request(_PIDX_URL, headers={"User-Agent": "DAPFlashTool/0.1"})
            with urllib.request.urlopen(req, timeout=20) as resp:
                root = ET.fromstring(resp.read(), forbid_dtd=True)

            entries = []
            for pdsc in root.iter("pdsc"):
                if pdsc.get("deprecated"):
                    continue  # skip deprecated packs (replacement exists)
                url = pdsc.get("url", "")
                vendor = pdsc.get("vendor", "")
                name = pdsc.get("name", "")
                version = pdsc.get("version", "")
                if not (url and vendor and name and version):
                    continue
                if not url.endswith("/"):
                    url += "/"
                entries.append({
                    "vendor": vendor,
                    "name": name,
                    "version": version,
                    "url": url,
                    "download_url": f"{url}{vendor}.{name}.{version}.pack",
                    "description": pdsc.get("description", ""),
                })
            self._pidx_cache = entries
            self._pidx_fetched_at = now
            return entries

    # ── RPCs ──────────────────────────────────────────────────────────────

    def _pack_to_pb(self, p) -> "dap_flash_pb2.PackInfo":
        return dap_flash_pb2.PackInfo(
            name=p.name, vendor=p.vendor, version=p.version, path=p.path,
            supported_chips=[c.name for c in p.chips],
            download_url='',
        )

    def ListPacks(self, request, context):
        packs = self._pack_manager.get_all_packs()
        return dap_flash_pb2.PackList(packs=[self._pack_to_pb(p) for p in packs])

    def SearchPacks(self, request, context):
        query = request.query.strip().lower()
        if not query:
            return dap_flash_pb2.PackSearchResult(packs=[])

        results: list[dap_flash_pb2.PackInfo] = []
        seen: set[tuple[str, str]] = set()

        # Online search via the Keil index (primary)
        try:
            for entry in self._fetch_pidx():
                haystack = f"{entry['vendor']} {entry['name']} {entry['description']}".lower()
                if query in haystack:
                    key = (entry["vendor"].lower(), entry["name"].lower())
                    if key in seen:
                        continue
                    seen.add(key)
                    results.append(dap_flash_pb2.PackInfo(
                        name=entry["name"],
                        vendor=entry["vendor"],
                        version=entry["version"],
                        path="",
                        supported_chips=[],
                        download_url=entry["download_url"],
                    ))
        except Exception:
            # Network unavailable — fall back to local chip search only.
            pass

        # Local search (installed packs, matched by chip name or pack name)
        for chip_name, pack in self._pack_manager.search_chips(request.query):
            key = (pack.vendor.lower(), pack.name.lower())
            if key in seen:
                continue
            seen.add(key)
            results.append(dap_flash_pb2.PackInfo(
                name=pack.name, vendor=pack.vendor, version=pack.version,
                path=pack.path, supported_chips=[chip_name], download_url='',
            ))
        for pack in self._pack_manager.get_all_packs():
            if query in f"{pack.vendor} {pack.name}".lower():
                key = (pack.vendor.lower(), pack.name.lower())
                if key in seen:
                    continue
                seen.add(key)
                results.append(self._pack_to_pb(pack))

        return dap_flash_pb2.PackSearchResult(packs=results[:100])

    def DownloadPack(self, request, context):
        url = request.pack_url.strip()

        # Security: only http(s); refuse file:// and other schemes.
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme not in ("http", "https") or not parsed.netloc:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING, progress=0.0,
                message=f"Download failed: invalid URL scheme '{parsed.scheme}'",
                success=False, error="Only http:// and https:// URLs are allowed",
            )
            return

        pack_dir = self._pack_manager.packs_dir
        os.makedirs(pack_dir, exist_ok=True)

        # Security: sanitize the destination filename (no path traversal).
        pack_name = os.path.basename(request.pack_name.strip()) or os.path.basename(parsed.path)
        if not pack_name:
            pack_name = "download.pack"
        if not pack_name.lower().endswith(".pack"):
            pack_name += ".pack"
        dest_path = os.path.join(pack_dir, pack_name)
        tmp_path = dest_path + ".part"

        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING, progress=0.0,
                message=f"Downloading {pack_name}...",
            )

            # Resume support: keep an existing partial download and request the rest.
            downloaded = os.path.getsize(tmp_path) if os.path.exists(tmp_path) else 0
            req = urllib.request.Request(url, headers={"User-Agent": "DAPFlashTool/0.1"})
            if downloaded > 0:
                req.add_header("Range", f"bytes={downloaded}-")

            with urllib.request.urlopen(req, timeout=30) as resp:
                status = resp.status
                if downloaded > 0 and status == 200:
                    downloaded = 0  # server ignored Range — restart from scratch
                length_hdr = resp.headers.get("Content-Length")
                total = downloaded + (int(length_hdr) if length_hdr else 0)
                mode = "ab" if (downloaded > 0 and status == 206) else "wb"

                last_yield = 0.0
                with open(tmp_path, mode) as f:
                    while True:
                        chunk = resp.read(_DOWNLOAD_CHUNK)
                        if not chunk:
                            break
                        f.write(chunk)
                        downloaded += len(chunk)
                        now = time.monotonic()
                        if total > 0 and (now - last_yield >= 0.1):
                            last_yield = now
                            yield dap_flash_pb2.ProgressUpdate(
                                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                                progress=downloaded / total,
                                bytes_written=downloaded,
                                total_bytes=total,
                                message=f"Downloading... {downloaded // 1024} / {total // 1024} KB",
                            )

            # Integrity check: a valid .pack is a ZIP containing a .pdsc file.
            if not zipfile.is_zipfile(tmp_path):
                raise ValueError("Downloaded file is not a valid pack (ZIP) archive")
            with zipfile.ZipFile(tmp_path) as zf:
                if not any(n.lower().endswith(".pdsc") for n in zf.namelist()):
                    raise ValueError("Pack archive contains no .pdsc descriptor")

            os.replace(tmp_path, dest_path)
            self._pack_manager.install_pack(dest_path)

            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=1.0,
                message=f"Download complete: {dest_path}", success=True,
            )
        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING, progress=0.0,
                message=f"Download failed: {str(e)}", success=False, error=str(e),
            )

    def InstallPack(self, request, context):
        try:
            success = self._pack_manager.install_pack(request.pack_path)
            return dap_flash_pb2.OperationResult(success=success, message="Pack installed successfully")
        except (FileNotFoundError, ValueError) as e:
            return dap_flash_pb2.OperationResult(success=False, message=str(e))
        except Exception as e:
            return dap_flash_pb2.OperationResult(success=False, message=str(e))

    def ListInstalledPacks(self, request, context):
        packs = self._pack_manager.list_installed_packs()
        return dap_flash_pb2.InstalledPackList(
            packs=[
                dap_flash_pb2.InstalledPack(
                    name=p['name'],
                    vendor=p['vendor'],
                    version=p['version'],
                    supported_chips=p.get('supported_chips', []),
                )
                for p in packs
            ]
        )

    def ScanPacks(self, request, context):
        directory = request.directory.strip() or self._pack_manager.packs_dir
        if not os.path.isdir(directory):
            return dap_flash_pb2.PackList(packs=[])
        found = self._pack_manager.scan_directory(directory)
        return dap_flash_pb2.PackList(packs=[self._pack_to_pb(p) for p in found])
