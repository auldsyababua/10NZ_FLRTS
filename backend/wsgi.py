"""
10NetZero-FLRTS Backend WSGI Entry Point

This module provides the WSGI entry point for production deployment
using servers like Gunicorn, uWSGI, or other WSGI-compatible servers.

Example deployment commands:
  gunicorn --bind 0.0.0.0:5000 --workers 4 wsgi:application
  waitress-serve --host=0.0.0.0 --port=5000 wsgi:application
"""

import sys
from pathlib import Path

# Add the backend directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from app import create_app
from config.settings import settings

# Create application instance for WSGI server
application = create_app()

if __name__ == "__main__":
    # This allows testing the WSGI interface directly
    application.run(
        host=settings.flask_host,
        port=settings.flask_port,
        debug=False  # Never use debug in production
    )