#!/usr/bin/env python3
"""Simple test to verify basic Flask functionality."""

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/test')
def test():
    return jsonify({"status": "ok", "message": "Flask is working!"})

if __name__ == "__main__":
    print("Starting simple Flask test server on port 5002...")
    app.run(host='0.0.0.0', port=5002, debug=False)