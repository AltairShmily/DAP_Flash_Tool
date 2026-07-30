"""DAP Flash Tool - gRPC Backend Server"""
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

def main():
    print("DAP Flash Tool backend server starting...")
    print("gRPC server will listen on localhost:50051")
    # TODO: Implement gRPC server startup
    print("Server not yet implemented.")

if __name__ == "__main__":
    main()
