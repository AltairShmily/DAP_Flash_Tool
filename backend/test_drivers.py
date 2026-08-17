import sys
import os
import pytest
sys.path.insert(0, os.path.dirname(__file__))

from drivers.base import BaseDriver, ProbeInfo, ChipInfo
from drivers.openocd_driver import OpenOCDDriver

try:
    from drivers.pyocd_driver import PyOCDDriver
    HAS_PYOCD = True
except ImportError:
    HAS_PYOCD = False

def test_base_class():
    """Verify BaseDriver is abstract."""
    try:
        BaseDriver()
        print("FAIL: BaseDriver should not be instantiable")
        sys.exit(1)
    except TypeError:
        print("BaseDriver is abstract OK")

def test_pyocd_init():
    if not HAS_PYOCD:
        print("PyOCD driver init SKIPPED (pyocd not installed)")
        return
    driver = PyOCDDriver()
    assert not driver.is_connected()
    print("PyOCD driver init OK")

def test_openocd_init():
    driver = OpenOCDDriver()
    assert not driver.is_connected()
    print("OpenOCD driver init OK")

def test_pyocd_install_pack():
    """Test pyocd pack installation."""
    if not HAS_PYOCD:
        pytest.skip("pyocd not installed")
    driver = PyOCDDriver()
    # This will fail in test environment, but verifies the method exists
    with pytest.raises(RuntimeError):
        driver.install_pack("nonexistent.pack")

def test_pyocd_list_installed_packs():
    """Test listing installed packs."""
    if not HAS_PYOCD:
        pytest.skip("pyocd not installed")
    driver = PyOCDDriver()
    packs = driver.list_installed_packs()
    assert isinstance(packs, list)

def test_openocd_install_pack():
    """Test that OpenOCD raises RuntimeError for pack management."""
    driver = OpenOCDDriver()
    with pytest.raises(RuntimeError):
        driver.install_pack("any.pack")

def test_openocd_list_installed_packs():
    """Test that OpenOCD returns empty list for pack listing."""
    driver = OpenOCDDriver()
    packs = driver.list_installed_packs()
    assert isinstance(packs, list)
    assert len(packs) == 0

if __name__ == "__main__":
    test_base_class()
    test_pyocd_init()
    test_openocd_init()
    print("All driver tests passed!")
