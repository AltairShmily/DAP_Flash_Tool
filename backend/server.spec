# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec for DAP Flash Tool backend (server.exe).

Build:  pyinstaller backend/server.spec
Output: dist/server.exe  (standalone, no Python required)
"""
import os, sys

block_cipher = None

# Collect pyocd data files (USB device DB, pack schemas, etc.)
pyocd_datas = []
try:
    import pyocd
    pyocd_dir = os.path.dirname(pyocd.__file__)
    pyocd_datas.append((pyocd_dir, 'pyocd'))
except ImportError:
    pass

a = Analysis(
    ['server.py'],
    pathex=['.'],
    binaries=[],
    datas=pyocd_datas,
    hiddenimports=[
        'grpc',
        'grpc._cython',
        'grpc._cython._cygrpc',
        'google.protobuf',
        'google.protobuf.internal',
        'pyocd',
        'pyocd.core',
        'pyocd.core.helpers',
        'pyocd.flash',
        'pyocd.flash.file_programmer',
        'pyocd.flash.eraser',
        'intelhex',
        'elftools',
        'pyelftools',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['tkinter', 'unittest', 'pytest'],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='server',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
)
