@echo off
echo ========================================
echo DAP Flash Tool - Development Setup
echo ========================================

echo.
echo [1/4] Checking prerequisites...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    exit /b 1
)
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Python not found in PATH
    exit /b 1
)

echo.
echo [2/4] Setting up Flutter app...
cd flutter_app
flutter pub get
cd ..

echo.
echo [3/4] Setting up Python backend...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo.
echo [4/4] Generating gRPC code...
mkdir -p backend\proto
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto

cd flutter_app
mkdir -p lib\proto
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
cd ..

echo.
echo ========================================
echo Setup complete!
echo Run 'scripts\run_dev.bat' to start.
echo ========================================
