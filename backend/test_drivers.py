"""Tests for the driver abstraction layer (no hardware required)."""
import sys
import os
import pytest
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'proto'))

from drivers.base import BaseDriver, ProbeInfo, ChipInfo
from drivers.openocd_driver import OpenOCDDriver

try:
    from drivers.pyocd_driver import PyOCDDriver
    HAS_PYOCD = True
except ImportError:
    HAS_PYOCD = False


def test_base_class():
    """Verify BaseDriver is abstract."""
    with pytest.raises(TypeError):
        BaseDriver()
    print("BaseDriver is abstract OK")


def test_drivers_have_no_pack_methods():
    """Pack management is decoupled from drivers (lives in PackManager)."""
    driver = OpenOCDDriver()
    assert not hasattr(driver, 'install_pack')
    assert not hasattr(driver, 'list_installed_packs')
    if HAS_PYOCD:
        pyocd_driver = PyOCDDriver()
        assert not hasattr(pyocd_driver, 'install_pack')
        assert not hasattr(pyocd_driver, 'list_installed_packs')


def test_pyocd_init():
    if not HAS_PYOCD:
        pytest.skip("pyocd not installed")
    driver = PyOCDDriver()
    assert not driver.is_connected()
    print("PyOCD driver init OK")


def test_openocd_init():
    driver = OpenOCDDriver()
    assert not driver.is_connected()
    print("OpenOCD driver init OK")


def test_openocd_requires_running_process():
    """All target operations must fail cleanly when OpenOCD is not running."""
    driver = OpenOCDDriver()
    with pytest.raises(RuntimeError):
        driver.flash("any.bin", 0, lambda p, m, bw, tb: None)
    with pytest.raises(RuntimeError):
        driver.erase("chip")
    with pytest.raises(RuntimeError):
        driver.reset()


def test_pyocd_requires_session():
    if not HAS_PYOCD:
        pytest.skip("pyocd not installed")
    driver = PyOCDDriver()
    with pytest.raises(RuntimeError):
        driver.flash("any.bin", 0, lambda p, m, bw, tb: None)
    with pytest.raises(RuntimeError):
        driver.erase("sector", start_address=0x08000000, length=0x400)
    with pytest.raises(RuntimeError):
        driver.reset_software()


def test_probe_info_fields():
    """Test ProbeInfo has all required fields."""
    info = ProbeInfo(
        id="test",
        name="Test Probe",
        vendor="Test Vendor",
        serial_number="12345",
        firmware_version="1.0.0",
        hardware_version="2.0.0",
        target_voltage=3.3,
    )
    assert info.firmware_version == "1.0.0"
    assert info.hardware_version == "2.0.0"
    assert info.target_voltage == 3.3
    assert info.is_connected is False


def test_pyocd_reset_methods_exist():
    if not HAS_PYOCD:
        pytest.skip("pyocd not installed")
    driver = PyOCDDriver()
    assert hasattr(driver, 'reset_software')
    assert hasattr(driver, 'reset_hardware')


def test_openocd_reset_methods_exist():
    driver = OpenOCDDriver()
    assert hasattr(driver, 'reset_software')
    assert hasattr(driver, 'reset_hardware')


if __name__ == "__main__":
    test_base_class()
    test_drivers_have_no_pack_methods()
    test_pyocd_init()
    test_openocd_init()
    test_openocd_requires_running_process()
    test_probe_info_fields()
    print("All driver tests passed!")
