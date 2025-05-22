"""
10NetZero-FLRTS Backend Application Entry Point

This is the main entry point for the Flask backend application.
It initializes the application, configures logging, and starts the server.

For production deployment, this file should be imported by a WSGI server
like Gunicorn rather than run directly.
"""

import os
import sys
import logging
from pathlib import Path

# Add the backend directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from app import create_app
from config.settings import settings


def setup_environment():
    """
    Set up the application environment and validate configuration.
    
    This function ensures all necessary environment variables are set
    and validates the configuration before starting the application.
    """
    logger = logging.getLogger(__name__)
    
    # Validate configuration
    config_errors = settings.validate_configuration()
    
    if config_errors:
        logger.error("Configuration validation failed:")
        for error in config_errors:
            logger.error(f"  - {error}")
        
        if settings.is_production:
            logger.critical("Cannot start application with invalid configuration in production")
            sys.exit(1)
        else:
            logger.warning("Starting with incomplete configuration (development mode)")
    
    # Create necessary directories
    log_dir = Path(settings.log_file_path).parent
    log_dir.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"Environment: {settings.environment}")
    logger.info(f"Debug mode: {settings.flask_debug}")
    logger.info(f"Log level: {settings.log_level}")


def main():
    """
    Main application entry point.
    
    Creates the Flask application and starts the development server.
    In production, this should be called by a WSGI server instead.
    """
    # Set up environment
    setup_environment()
    
    # Create Flask application
    app = create_app()
    
    # Log startup information
    app.logger.info("=" * 50)
    app.logger.info("10NetZero-FLRTS Backend Starting")
    app.logger.info("=" * 50)
    app.logger.info(f"Environment: {settings.environment}")
    app.logger.info(f"Host: {settings.flask_host}")
    app.logger.info(f"Port: {settings.flask_port}")
    app.logger.info(f"Debug: {settings.flask_debug}")
    
    # Print configuration summary for development
    if settings.is_development:
        app.logger.info("\nConfiguration Summary:")
        app.logger.info(f"  Supabase URL: {'✓' if settings.supabase_url else '✗'}")
        app.logger.info(f"  Telegram Bot: {'✓' if settings.telegram_bot_token else '✗'}")
        app.logger.info(f"  OpenAI API: {'✓' if settings.openai_api_key else '✗'}")
        app.logger.info(f"  Todoist API: {'✓' if settings.todoist_api_token else '✗'}")
        app.logger.info(f"  Google Drive: {'✓' if settings.google_api_key else '✗'}")
    
    app.logger.info("=" * 50)
    
    try:
        # Start the Flask development server
        if settings.is_development:
            app.logger.info("Starting Flask development server...")
            app.run(
                host=settings.flask_host,
                port=settings.flask_port,
                debug=settings.flask_debug,
                threaded=True
            )
        else:
            app.logger.info("Application created for production WSGI server")
            return app
    
    except KeyboardInterrupt:
        app.logger.info("Application shutdown requested")
    except Exception as e:
        app.logger.error(f"Application startup failed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()