import sys
from pathlib import Path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from app import create_app
import requests
import threading
import time

def test_endpoints():
    app = create_app()
    
    # Start the app in a thread
    def run_app():
        app.run(host='127.0.0.1', port=5002, debug=False, use_reloader=False)
    
    server_thread = threading.Thread(target=run_app, daemon=True)
    server_thread.start()
    
    # Wait for server to start
    time.sleep(2)
    
    print("Testing endpoints...")
    
    # Test health endpoint (should work)
    try:
        response = requests.get('http://127.0.0.1:5002/health')
        print(f"Health endpoint: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"Health endpoint error: {e}")
    
    # Test GET endpoint that was failing
    try:
        headers = {'X-API-Key': 'test-key'}  # Use a dummy key for now
        response = requests.get('http://127.0.0.1:5002/api/sites', headers=headers)
        print(f"Sites endpoint: {response.status_code} - {response.text[:100]}")
    except Exception as e:
        print(f"Sites endpoint error: {e}")

if __name__ == '__main__':
    test_endpoints()
