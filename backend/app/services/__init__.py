"""
10NetZero-FLRTS Service Layer

This package contains core services for the FLRTS system:
- database_client: Database operations and queries
- external_apis: External API integrations (Todoist, Google Drive)
- nlp_service: Natural language processing and intent classification
"""

from .database_client import get_db_client
from .nlp_service import nlp_service
from .external_apis import todoist_service, google_drive_service

# Create a db_client proxy
db_client = get_db_client()

__all__ = ['db_client', 'nlp_service', 'todoist_service', 'google_drive_service']