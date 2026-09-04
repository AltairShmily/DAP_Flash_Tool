@echo off
setlocal
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
where protoc >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: protoc not found in PATH ^(install the protobuf compiler^)
    exit /b 1
)
where protoc-gen-dart >nul 2>nul
if %errorlevel% neq 0 (
    echo protoc-gen-dart not found, activating protoc_plugin 22.5.0...
    call dart pub global activate protoc_plugin 22.5.0
)

echo.
echo [2/4] Setting up Flutter app...
cd flutter_app
call flutter pub get
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
if not exist backend\proto mkdir backend\proto
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto
if not exist backend\proto\__init__.py type nul > backend\proto\__init__.py
rem Keep generated code identical to the committed version (CI enforces sync):
rem rewrite the absolute pb2 import inside the proto package to a relative one.
powershell -NoProfile -Command "(Get-Content backend\proto\dap_flash_pb2_grpc.py -Raw) -replace '(?m)^import dap_flash_pb2', 'from . import dap_flash_pb2' | Set-Content backend\proto\dap_flash_pb2_grpc.py -NoNewline"

cd flutter_app
if not exist lib\proto mkdir lib\proto
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
cd ..

echo.
echo ========================================
echo Setup complete!
echo.
echo Start backend:  cd backend ^&^& venv\Scripts\python server.py
echo Start frontend: cd flutter_app ^&^& flutter run -d windows
echo ========================================
endlocal
