@echo off
echo Setting up DAP Flash Tool development environment...

echo [1/3] Installing Flutter dependencies...
cd flutter_app
flutter pub get
cd ..

echo [2/3] Creating Python virtual environment...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo [3/3] Generating gRPC code...
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto
cd flutter_app
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
cd ..

echo Setup complete!
