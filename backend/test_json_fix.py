import sys
from pathlib import Path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
import time
import requests

def create_test_app():
    """Create a minimal Flask app to test the JSON handling fix"""
    app = Flask(__name__)
    CORS(app)
    app.config['DEBUG'] = True
    
    # Add the problematic before_request handler (fixed version)
    @app.before_request
    def log_request_info():
        """Log incoming request details for debugging."""
        if request.path.startswith('/health'):
            return  # Skip health check logging to reduce noise
        
        app.logger.debug(f"Request: {request.method} {request.path}")
        if request.args:
            app.logger.debug(f"Query params: {dict(request.args)}")
        # FIXED: Only check JSON for appropriate methods and when it's safe
        if request.method in ["POST", "PUT", "PATCH"] and request.is_json and request.json:
            app.logger.debug(f"Request body: {request.json}")
    
    @app.route('/health')
    def health_check():
        return jsonify({'status': 'healthy'})
    
    @app.route('/api/test-get')
    def test_get():
        return jsonify({'method': 'GET', 'success': True})
    
    @app.route('/api/test-post', methods=['POST'])
    def test_post():
        data = request.get_json(force=True, silent=True) or {}
        return jsonify({'method': 'POST', 'received_data': data, 'success': True})
    
    return app

def test_endpoints():
    app = create_test_app()
    
    # Start the app in a thread
    def run_app():
        app.run(host='127.0.0.1', port=5003, debug=False, use_reloader=False)
    
    server_thread = threading.Thread(target=run_app, daemon=True)
    server_thread.start()
    
    # Wait for server to start
    time.sleep(2)
    
    print("Testing JSON handling fix...")
    
    # Test health endpoint
    try:
        response = requests.get('http://127.0.0.1:5003/health')
        print(f"✓ Health endpoint: {response.status_code}")
    except Exception as e:
        print(f"✗ Health endpoint error: {e}")
    
    # Test GET endpoint (this was failing before the fix)
    try:
        response = requests.get('http://127.0.0.1:5003/api/test-get')
        print(f"✓ GET endpoint: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"✗ GET endpoint error: {e}")
    
    # Test POST endpoint with JSON
    try:
        response = requests.post('http://127.0.0.1:5003/api/test-post', 
                               json={'test': 'data'},
                               headers={'Content-Type': 'application/json'})
        print(f"✓ POST endpoint with JSON: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"✗ POST endpoint error: {e}")
    
    # Test POST endpoint without JSON content-type (should not fail now)
    try:
        response = requests.post('http://127.0.0.1:5003/api/test-post', 
                               data='some data')
        print(f"✓ POST endpoint without JSON: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"✗ POST endpoint without JSON error: {e}")

if __name__ == '__main__':
    test_endpoints()
