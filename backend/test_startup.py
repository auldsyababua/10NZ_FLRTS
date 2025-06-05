#!/usr/bin/env python3
"""Test Flask app startup without blocking."""

import sys
import time
import requests
from multiprocessing import Process

def run_app():
    """Run the Flask app in a subprocess."""
    from app import create_app
    app = create_app()
    app.run(host='0.0.0.0', port=5001, debug=False)

def test_startup():
    """Test if the Flask app starts successfully."""
    # Start the app in a separate process
    p = Process(target=run_app)
    p.start()
    
    # Give it time to start
    time.sleep(5)
    
    try:
        # Test the health endpoint
        response = requests.get('http://localhost:5001/api/health', timeout=5)
        if response.status_code == 200:
            print("✅ Flask app started successfully!")
            print(f"Health check response: {response.json()}")
        else:
            print(f"❌ Health check failed with status {response.status_code}")
    except Exception as e:
        print(f"❌ Failed to connect to Flask app: {e}")
    finally:
        # Terminate the process
        p.terminate()
        p.join()

if __name__ == "__main__":
    test_startup()