"""
10NetZero-FLRTS External API Integration Services

This module provides integration services for external APIs used by the FLRTS system:
- Todoist API for natural language task parsing and backend task management
- Google Drive API for SOP document storage and management
- OpenAI API for advanced natural language processing

Each service encapsulates the API-specific logic and provides a clean interface
for the rest of the application to interact with external systems.
"""

import logging
import json
from typing import Dict, Any, Optional, List
from datetime import datetime, date
from urllib.parse import urlencode

import requests
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from config.settings import settings


class ExternalAPIError(Exception):
    """Custom exception for external API-related errors."""
    pass


class TodoistService:
    """
    Service for integrating with Todoist API for task management and NLP.
    
    According to the system design, Todoist is used for:
    - Natural language parsing of tasks and reminders via Quick Add
    - Backend task management and synchronization
    - Date/time parsing and task structure extraction
    """
    
    def __init__(self):
        """Initialize Todoist service with API configuration."""
        self.logger = logging.getLogger(__name__)
        self.api_token = settings.todoist_api_token
        self.base_url = "https://api.todoist.com/rest/v2"
        
        if not self.api_token:
            self.logger.warning("Todoist API token not configured")
            self.enabled = False
        else:
            self.enabled = True
            self.logger.info("Todoist service initialized")
    
    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """
        Make authenticated request to Todoist API.
        
        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: API endpoint path
            data: Optional request data
            
        Returns:
            API response data
            
        Raises:
            ExternalAPIError: If request fails
        """
        if not self.enabled:
            raise ExternalAPIError("Todoist API not configured")
        
        url = f"{self.base_url}/{endpoint}"
        headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
        
        try:
            if method.upper() == "GET":
                response = requests.get(url, headers=headers, params=data)
            elif method.upper() == "POST":
                response = requests.post(url, headers=headers, json=data)
            else:
                raise ExternalAPIError(f"Unsupported HTTP method: {method}")
            
            response.raise_for_status()
            
            # Handle empty responses
            if not response.content:
                return {}
            
            return response.json()
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Todoist API request failed: {e}")
            raise ExternalAPIError(f"Todoist API error: {e}")
        except json.JSONDecodeError as e:
            self.logger.error(f"Invalid JSON response from Todoist: {e}")
            raise ExternalAPIError("Invalid response from Todoist API")
    
    async def create_task_from_nlp(self, natural_language_input: str) -> Dict[str, Any]:
        """
        Create a task using Todoist's natural language processing.
        
        This method leverages Todoist's Quick Add functionality to parse
        natural language task descriptions including due dates, priorities,
        and other task attributes.
        
        Args:
            natural_language_input: Natural language task description
            
        Returns:
            Dictionary with parsed task data and success status
        """
        try:
            # Create task in Todoist using natural language
            task_data = {
                "content": natural_language_input,
                "description": f"Created via 10NetZero FLRTS system at {datetime.now().isoformat()}"
            }
            
            created_task = self._make_request("POST", "tasks", task_data)
            
            # Parse the created task to extract structured information
            structured_data = {
                'success': True,
                'task_title': created_task.get('content', ''),
                'description': created_task.get('description', ''),
                'due_date': None,
                'due_datetime': None,
                'priority': self._map_todoist_priority(created_task.get('priority', 1)),
                'todoist_id': created_task.get('id'),
                'todoist_url': created_task.get('url')
            }
            
            # Extract due date information if present
            if created_task.get('due'):
                due_info = created_task['due']
                structured_data['due_date'] = due_info.get('date')
                structured_data['due_datetime'] = due_info.get('datetime')
            
            self.logger.info(f"Successfully created task in Todoist: {created_task.get('id')}")
            return structured_data
            
        except Exception as e:
            self.logger.error(f"Error creating task from NLP: {e}")
            return {
                'success': False,
                'error': str(e),
                'message': 'Failed to process task with Todoist'
            }
    
    def _map_todoist_priority(self, todoist_priority: int) -> str:
        """
        Map Todoist priority levels to FLRTS priority levels.
        
        Args:
            todoist_priority: Todoist priority (1-4)
            
        Returns:
            FLRTS priority string
        """
        priority_map = {
            1: 'Low',      # Todoist priority 1 (lowest)
            2: 'Medium',   # Todoist priority 2
            3: 'High',     # Todoist priority 3
            4: 'High'      # Todoist priority 4 (highest)
        }
        return priority_map.get(todoist_priority, 'Medium')
    
    async def get_tasks(self, filter_expr: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieve tasks from Todoist with optional filtering.
        
        Args:
            filter_expr: Optional Todoist filter expression
            
        Returns:
            List of task dictionaries
        """
        try:
            params = {}
            if filter_expr:
                params['filter'] = filter_expr
            
            tasks = self._make_request("GET", "tasks", params)
            
            self.logger.debug(f"Retrieved {len(tasks)} tasks from Todoist")
            return tasks
            
        except Exception as e:
            self.logger.error(f"Error retrieving tasks from Todoist: {e}")
            raise ExternalAPIError(f"Failed to retrieve tasks: {e}")
    
    async def complete_task(self, task_id: str) -> bool:
        """
        Mark a Todoist task as completed.
        
        Args:
            task_id: Todoist task ID
            
        Returns:
            True if successful
        """
        try:
            self._make_request("POST", f"tasks/{task_id}/close")
            self.logger.info(f"Completed Todoist task: {task_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error completing Todoist task {task_id}: {e}")
            return False


class GoogleDriveService:
    """
    Service for integrating with Google Drive API for SOP document management.
    
    Handles creation, storage, and linking of Standard Operating Procedure
    documents for sites in the FLRTS system.
    """
    
    def __init__(self):
        """Initialize Google Drive service with API configuration."""
        self.logger = logging.getLogger(__name__)
        
        # Check if Google API credentials are configured
        if not all([settings.google_api_key, settings.google_client_id, settings.google_client_secret]):
            self.logger.warning("Google Drive API credentials not fully configured")
            self.enabled = False
        else:
            self.enabled = True
            self.logger.info("Google Drive service initialized")
    
    def _get_credentials(self) -> Optional[Credentials]:
        """
        Get Google API credentials for authentication.
        
        Returns:
            Google API credentials or None if not configured
        """
        if not self.enabled:
            return None
        
        try:
            # For service account or OAuth2 flow, credentials would be loaded here
            # This is a placeholder for actual credential management
            credentials = Credentials(
                token=None,  # Would be loaded from refresh token
                refresh_token=settings.google_refresh_token,
                token_uri="https://oauth2.googleapis.com/token",
                client_id=settings.google_client_id,
                client_secret=settings.google_client_secret
            )
            return credentials
            
        except Exception as e:
            self.logger.error(f"Error loading Google credentials: {e}")
            return None
    
    async def create_site_sop_document(self, site_data: Dict[str, Any]) -> Optional[str]:
        """
        Create a Standard Operating Procedure document for a new site.
        
        Args:
            site_data: Site information including name, location, etc.
            
        Returns:
            Google Drive link to the created document or None if failed
        """
        try:
            credentials = self._get_credentials()
            if not credentials:
                self.logger.warning("Cannot create SOP document - Google credentials not available")
                return None
            
            # Build Google Drive service
            service = build('drive', 'v3', credentials=credentials)
            
            # Create document content
            document_title = f"SOP - {site_data.get('site_name', 'Unknown Site')}"
            
            # Create a new Google Doc
            document_metadata = {
                'name': document_title,
                'mimeType': 'application/vnd.google-apps.document'
            }
            
            document = service.files().create(body=document_metadata).execute()
            document_id = document.get('id')
            
            # Set permissions to allow organization access
            permission = {
                'type': 'domain',
                'role': 'writer',
                'domain': '10netzero.com'  # Replace with actual domain
            }
            service.permissions().create(fileId=document_id, body=permission).execute()
            
            # Generate shareable link
            document_link = f"https://docs.google.com/document/d/{document_id}/edit"
            
            self.logger.info(f"Created SOP document for site {site_data.get('site_name')}: {document_id}")
            return document_link
            
        except HttpError as e:
            self.logger.error(f"Google Drive API error creating SOP document: {e}")
            return None
        except Exception as e:
            self.logger.error(f"Error creating SOP document: {e}")
            return None
    
    async def update_document_content(self, document_id: str, content: str) -> bool:
        """
        Update the content of an existing Google Document.
        
        Args:
            document_id: Google Document ID
            content: New content for the document
            
        Returns:
            True if successful
        """
        try:
            credentials = self._get_credentials()
            if not credentials:
                return False
            
            # Build Google Docs service
            docs_service = build('docs', 'v1', credentials=credentials)
            
            # Insert content into the document
            requests_body = [
                {
                    'insertText': {
                        'location': {'index': 1},
                        'text': content
                    }
                }
            ]
            
            docs_service.documents().batchUpdate(
                documentId=document_id,
                body={'requests': requests_body}
            ).execute()
            
            self.logger.info(f"Updated Google Document content: {document_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error updating document content: {e}")
            return False


class OpenAIService:
    """
    Service for integrating with OpenAI API for advanced natural language processing.
    
    Provides structured text analysis, content extraction, and language understanding
    capabilities for complex FLRTS operations.
    """
    
    def __init__(self):
        """Initialize OpenAI service with API configuration."""
        self.logger = logging.getLogger(__name__)
        
        if not settings.openai_api_key:
            self.logger.warning("OpenAI API key not configured")
            self.enabled = False
        else:
            self.enabled = True
            import openai
            openai.api_key = settings.openai_api_key
            self.logger.info("OpenAI service initialized")
    
    async def analyze_text_structure(self, text: str, analysis_type: str) -> Dict[str, Any]:
        """
        Analyze text structure for specific FLRTS use cases.
        
        Args:
            text: Text to analyze
            analysis_type: Type of analysis (field_report, list_items, etc.)
            
        Returns:
            Dictionary with structured analysis results
        """
        if not self.enabled:
            return {'success': False, 'error': 'OpenAI not configured'}
        
        try:
            import openai
            
            if analysis_type == 'field_report':
                system_prompt = """
                Analyze this field report and extract structured information.
                Return JSON with: title, report_type, equipment_mentioned, 
                priority_level, requires_followup, key_observations.
                """
            elif analysis_type == 'list_items':
                system_prompt = """
                Extract individual items from this text for adding to lists.
                Return JSON with: items (array), list_type_suggestion, quantity_info.
                """
            else:
                system_prompt = "Analyze this text and provide structured insights."
            
            response = await openai.ChatCompletion.acreate(
                model=settings.openai_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": text}
                ],
                max_tokens=settings.openai_max_tokens,
                temperature=0.1
            )
            
            result = json.loads(response.choices[0].message.content)
            result['success'] = True
            
            return result
            
        except Exception as e:
            self.logger.error(f"Error analyzing text with OpenAI: {e}")
            return {
                'success': False,
                'error': str(e)
            }


# Global service instances
todoist_service = TodoistService()
google_drive_service = GoogleDriveService()
openai_service = OpenAIService()