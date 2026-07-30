@echo off
echo ========================================
echo DAP Flash Tool - Windows Build
echo ========================================

echo.
echo [1/3] Building Flutter app...
cd flutter_app
flutter build windows --release
cd ..

echo.
echo [2/3] Packaging Python backend...
cd backend
call venv\Scripts\activate.bat
pip install pyinstaller
pyinstaller --onefile --name server server.py
cd ..

echo.
echo [3/3] Creating distribution...
mkdir -p dist
copy flutter_app\build\windows\x64\runner\Release\* dist\
copy backend\dist\server.exe dist\backend.exe

echo.
echo ========================================
echo Build complete!
echo Output: dist\
echo ========================================
