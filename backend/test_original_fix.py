# Test the original Flask app with mocked dependencies
import sys
from pathlib import Path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

# Mock the problematic imports before importing the app
import unittest.mock as mock

# Mock the database client and external services
sys.modules['app.services.database_client'] = mock.MagicMock()
sys.modules['app.services.nlp_service'] = mock.MagicMock()
sys.modules['app.services.external_apis'] = mock.MagicMock()

# Create mock objects
mock_db_client = mock.MagicMock()
mock_db_client.check_connection.return_value = True

# Patch the imports
with mock.patch.dict('sys.modules', {
    'app.services.database_client': mock.MagicMock(db_client=mock_db_client),
    'app.services.nlp_service': mock.MagicMock(nlp_service=mock.MagicMock()),
    'app.services.external_apis': mock.MagicMock(
        todoist_service=mock.MagicMock(),
        google_drive_service=mock.MagicMock()
    )
}):
    from app import create_app
    import requests
    import threading
    import time

    def test_real_app():
        app = create_app()
        
        # Start the app in a thread
        def run_app():
            app.run(host='127.0.0.1', port=5004, debug=False, use_reloader=False)
        
        server_thread = threading.Thread(target=run_app, daemon=True)
        server_thread.start()
        
        # Wait for server to start
        time.sleep(3)
        
        print("Testing real app with our fix...")
        
        # Test health endpoint
        try:
            response = requests.get('http://127.0.0.1:5004/health')
            print(f"✓ Health endpoint: {response.status_code} - {response.json()}")
        except Exception as e:
            print(f"✗ Health endpoint error: {e}")
        
        # Test GET endpoints that were failing before
        try:
            response = requests.get('http://127.0.0.1:5004/api/sites')
            print(f"Sites endpoint (no auth): {response.status_code} - Should be 401 (auth required)")
        except Exception as e:
            print(f"Sites endpoint error: {e}")
        
        # Test with auth header (will still fail due to invalid key, but should not be 415)
        try:
            headers = {'X-API-Key': 'test-key'}
            response = requests.get('http://127.0.0.1:5004/api/sites', headers=headers)
            print(f"Sites endpoint (with auth): {response.status_code} - Should NOT be 415")
        except Exception as e:
            print(f"Sites endpoint with auth error: {e}")

    if __name__ == '__main__':
        test_real_app()
