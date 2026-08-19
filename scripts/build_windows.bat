@echo off
echo ========================================
echo DAP Flash Tool - Windows Build
echo ========================================

echo.
echo [1/4] Building Python backend (PyInstaller)...
cd backend
call venv\Scripts\activate.bat
pip install pyinstaller -q
pyinstaller server.spec --noconfirm --clean
cd ..

echo.
echo [2/4] Building Flutter app...
cd flutter_app
flutter build windows --release
cd ..

echo.
echo [3/4] Assembling distribution...
if not exist dist mkdir dist
xcopy /E /Y /Q flutter_app\build\windows\x64\runner\Release\* dist\
if not exist dist\backend mkdir dist\backend
copy /Y backend\dist\server.exe dist\backend\server.exe

echo.
echo [4/4] Done!
echo ========================================
echo Output: dist\
echo   dist\dap_flash_tool.exe    (Flutter frontend)
echo   dist\backend\server.exe    (standalone backend, no Python needed)
echo ========================================
