"""
10NetZero-FLRTS Backend Configuration Settings

This module provides configuration management for the Flask backend application.
All configuration is loaded from environment variables for security and flexibility.
Different configurations are available for development, testing, and production environments.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Main configuration class for the 10NetZero-FLRTS backend application.
    
    This class uses Pydantic for configuration validation and environment variable loading.
    All sensitive values (API keys, database passwords) are loaded from environment variables
    and should never be hardcoded or committed to version control.
    """
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )
    
    # Flask Application Configuration
    flask_app_name: str = "10NetZero-FLRTS"
    flask_debug: bool = False
    flask_host: str = "0.0.0.0"
    flask_port: int = 5000
    flask_secret_key: Optional[str] = None
    
    # Environment and Deployment
    environment: str = "development"  # development, staging, production
    log_level: str = "INFO"
    
    # Supabase Database Configuration
    supabase_url: Optional[str] = None
    supabase_key: Optional[str] = None
    supabase_service_role_key: Optional[str] = None
    
    # Direct PostgreSQL Configuration (for advanced operations)
    database_url: Optional[str] = None
    postgres_host: str = "db.thnwlykidzhrsagyjncc.supabase.co"
    postgres_port: int = 5432
    postgres_db: str = "postgres"
    postgres_user: str = "postgres"
    postgres_password: Optional[str] = None
    
    # Telegram Bot Configuration
    telegram_bot_token: Optional[str] = None
    telegram_webhook_url: Optional[str] = None
    telegram_webhook_secret: Optional[str] = None
    
    # External API Configuration
    openai_api_key: Optional[str] = None
    openai_model: str = "gpt-4"
    openai_max_tokens: int = 1000
    
    todoist_api_token: Optional[str] = None
    
    # Google Drive API Configuration
    google_api_key: Optional[str] = None
    google_client_id: Optional[str] = None
    google_client_secret: Optional[str] = None
    google_refresh_token: Optional[str] = None
    
    # NLP and Processing Configuration
    max_message_length: int = 2000
    nlp_confidence_threshold: float = 0.7
    default_site_id: Optional[str] = None
    
    # Logging Configuration
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    log_file_path: str = "logs/flrts_backend.log"
    log_max_bytes: int = 10485760  # 10MB
    log_backup_count: int = 5
    
    # Security Configuration
    cors_origins: list[str] = ["*"]  # Configure appropriately for production
    rate_limit_per_minute: int = 60
    
    @property
    def database_connection_string(self) -> str:
        """
        Constructs the PostgreSQL connection string from individual components.
        This is used for direct database connections when Supabase client is not sufficient.
        """
        if self.database_url:
            return self.database_url
        
        if not self.postgres_password:
            raise ValueError("PostgreSQL password must be configured")
            
        return (
            f"postgresql://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )
    
    @property
    def is_production(self) -> bool:
        """Returns True if running in production environment."""
        return self.environment.lower() == "production"
    
    @property
    def is_development(self) -> bool:
        """Returns True if running in development environment."""
        return self.environment.lower() == "development"
    
    def validate_configuration(self) -> list[str]:
        """
        Validates that all required configuration is present for the current environment.
        Returns a list of missing or invalid configuration items.
        """
        errors = []
        
        # Always required
        if not self.flask_secret_key:
            errors.append("FLASK_SECRET_KEY is required")
        
        if not self.supabase_url:
            errors.append("SUPABASE_URL is required")
        
        if not self.supabase_key:
            errors.append("SUPABASE_KEY is required")
        
        if not self.postgres_password:
            errors.append("POSTGRES_PASSWORD is required")
        
        # Telegram bot configuration
        if not self.telegram_bot_token:
            errors.append("TELEGRAM_BOT_TOKEN is required")
        
        # Production-specific requirements
        if self.is_production:
            if not self.telegram_webhook_url:
                errors.append("TELEGRAM_WEBHOOK_URL is required in production")
            
            if not self.openai_api_key:
                errors.append("OPENAI_API_KEY is required")
            
            if "*" in self.cors_origins:
                errors.append("CORS_ORIGINS should be restricted in production")
        
        return errors


class DevelopmentSettings(Settings):
    """Development environment configuration with debug mode enabled."""
    flask_debug: bool = True
    log_level: str = "DEBUG"
    environment: str = "development"


class ProductionSettings(Settings):
    """Production environment configuration with security hardening."""
    flask_debug: bool = False
    log_level: str = "WARNING"
    environment: str = "production"
    cors_origins: list[str] = []  # Must be explicitly configured


def get_settings() -> Settings:
    """
    Factory function to return the appropriate settings class based on environment.
    
    The environment is determined by the ENVIRONMENT variable, defaulting to development.
    This allows for different configurations without code changes.
    """
    env = os.getenv("ENVIRONMENT", "development").lower()
    
    if env == "production":
        return ProductionSettings()
    else:
        return DevelopmentSettings()


# Global settings instance
settings = get_settings()