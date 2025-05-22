"""
10NetZero-FLRTS NLP Orchestration Service

This module implements the core NLP orchestration pipeline for processing natural language
commands received from field technicians via the Telegram bot interface.

The service performs:
1. Initial intent classification to determine user intent
2. Routing to specialized processing services based on intent
3. Integration with external APIs (Todoist, OpenAI, Google Drive)
4. Coordination with database operations for FLRTS CRUD
5. Response generation and formatting

The NLP pipeline follows the system design specifications for handling different types
of natural language input and routing them to appropriate processing mechanisms.
"""

import logging
import re
from typing import Dict, Any, Optional, List
from datetime import datetime, date
from enum import Enum

import openai
from config.settings import settings
from app.services.database_client import db_client
from app.services.external_apis import todoist_service, google_drive_service


class Intent(Enum):
    """
    Enumeration of supported user intents for FLRTS operations.
    
    These intents map to the core FLRTS functionalities and determine
    which processing pipeline and external services are used.
    """
    CREATE_TASK = "create_task"
    CREATE_REMINDER = "create_reminder"
    CREATE_FIELD_REPORT = "create_field_report"
    ADD_LIST_ITEM = "add_list_item"
    QUERY_TASKS = "query_tasks"
    QUERY_LISTS = "query_lists"
    QUERY_REPORTS = "query_reports"
    UPDATE_TASK_STATUS = "update_task_status"
    GENERAL_QUERY = "general_query"
    UNKNOWN = "unknown"


class NLPService:
    """
    Core NLP orchestration service for the 10NetZero-FLRTS system.
    
    Processes natural language input from field technicians and routes
    requests to appropriate services based on intent classification.
    Integrates with external APIs and database operations to fulfill requests.
    """
    
    def __init__(self):
        """Initialize the NLP service with OpenAI client and intent patterns."""
        self.logger = logging.getLogger(__name__)
        
        # Initialize OpenAI client if API key is available
        if settings.openai_api_key:
            openai.api_key = settings.openai_api_key
            self.openai_enabled = True
            self.logger.info("OpenAI client initialized for NLP processing")
        else:
            self.openai_enabled = False
            self.logger.warning("OpenAI API key not configured - using fallback intent classification")
        
        # Define intent classification patterns for fallback processing
        self.intent_patterns = {
            Intent.CREATE_TASK: [
                r'\b(create|add|new)\s+(task|todo|assignment)\b',
                r'\btask\s*:\s*',
                r'\b(remind|tell)\s+\w+\s+to\b',
                r'\bneed\s+to\b',
                r'\bschedule\b.*\bfor\b'
            ],
            Intent.CREATE_REMINDER: [
                r'\b(remind|reminder)\b',
                r'\b(alert|notify)\s+me\b',
                r'\b(don\'t\s+forget|remember)\b',
                r'\bat\s+\d+\s*(am|pm|:)\b'
            ],
            Intent.CREATE_FIELD_REPORT: [
                r'\b(field\s+report|report|log|incident)\b',
                r'\bsite\s+\w+\s*:\s*',
                r'\b(noticed|observed|found|checked)\b',
                r'\b(generator|equipment|pump|system)\b.*\b(running|working|issue|problem)\b'
            ],
            Intent.ADD_LIST_ITEM: [
                r'\b(add|put)\b.*\b(to|on)\b.*\b(list|inventory)\b',
                r'\b(shopping|tool|equipment)\s+list\b',
                r'\bneed\b.*\b(supplies|parts|tools)\b'
            ],
            Intent.QUERY_TASKS: [
                r'\b(what|show|list|check)\b.*\b(task|todo|assignment)\b',
                r'\bmy\s+(schedule|work|tasks)\b',
                r'\bwhat.*\b(today|tomorrow|this\s+week)\b',
                r'\bdue\s+(today|soon)\b'
            ],
            Intent.QUERY_LISTS: [
                r'\b(show|check|what)\b.*\blist\b',
                r'\b(shopping|inventory|equipment)\s+list\b',
                r'\bwhat.*\b(need|supplies|tools)\b'
            ],
            Intent.QUERY_REPORTS: [
                r'\b(show|check|view)\b.*\b(report|reports)\b',
                r'\brecent\s+(reports|logs)\b',
                r'\breport\s+(history|status)\b'
            ],
            Intent.UPDATE_TASK_STATUS: [
                r'\b(done|complete|completed|finish|finished)\b',
                r'\bmark.*\b(complete|done)\b',
                r'\b(close|cancel)\s+(task|todo)\b'
            ]
        }
    
    async def process_user_input(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Main entry point for processing user input through the NLP pipeline.
        
        Args:
            user_input: Natural language text from the user
            user_context: User information including site assignments and permissions
            
        Returns:
            Dictionary containing response text, success status, and metadata
        """
        try:
            self.logger.info(f"Processing input from user {user_context.get('flrts_user_id')}: {user_input[:100]}")
            
            # Step 1: Classify user intent
            intent, confidence = await self.classify_intent(user_input)
            
            self.logger.debug(f"Classified intent: {intent.value} (confidence: {confidence:.2f})")
            
            # Step 2: Route to appropriate handler based on intent
            if intent == Intent.CREATE_TASK or intent == Intent.CREATE_REMINDER:
                return await self.handle_task_creation(user_input, user_context, intent)
            
            elif intent == Intent.CREATE_FIELD_REPORT:
                return await self.handle_field_report_creation(user_input, user_context)
            
            elif intent == Intent.ADD_LIST_ITEM:
                return await self.handle_list_item_addition(user_input, user_context)
            
            elif intent == Intent.QUERY_TASKS:
                return await self.handle_task_query(user_input, user_context)
            
            elif intent == Intent.QUERY_LISTS:
                return await self.handle_list_query(user_input, user_context)
            
            elif intent == Intent.QUERY_REPORTS:
                return await self.handle_report_query(user_input, user_context)
            
            elif intent == Intent.UPDATE_TASK_STATUS:
                return await self.handle_task_status_update(user_input, user_context)
            
            elif intent == Intent.GENERAL_QUERY:
                return await self.handle_general_query(user_input, user_context)
            
            else:  # Intent.UNKNOWN
                return {
                    'success': False,
                    'response': "I'm not sure how to help with that. Try asking me to create a task, log a field report, or check your schedule. You can also use /help for examples.",
                    'intent': intent.value,
                    'confidence': confidence
                }
        
        except Exception as e:
            self.logger.error(f"Error processing user input: {e}", exc_info=True)
            return {
                'success': False,
                'response': "Sorry, I encountered an error processing your request. Please try again.",
                'error': str(e)
            }
    
    async def classify_intent(self, user_input: str) -> tuple[Intent, float]:
        """
        Classify user intent using OpenAI or fallback pattern matching.
        
        Args:
            user_input: User's natural language input
            
        Returns:
            Tuple of (Intent, confidence_score)
        """
        # First try OpenAI classification if available
        if self.openai_enabled:
            try:
                return await self.classify_intent_openai(user_input)
            except Exception as e:
                self.logger.warning(f"OpenAI intent classification failed, using fallback: {e}")
        
        # Fallback to pattern-based classification
        return self.classify_intent_patterns(user_input)
    
    async def classify_intent_openai(self, user_input: str) -> tuple[Intent, float]:
        """
        Use OpenAI to classify user intent with structured output.
        
        Args:
            user_input: User's natural language input
            
        Returns:
            Tuple of (Intent, confidence_score)
        """
        system_prompt = """
        You are an intent classifier for a field technician management system called FLRTS.
        Classify the user's input into one of these intents:
        
        - create_task: Creating new tasks or assignments
        - create_reminder: Setting up reminders or alerts
        - create_field_report: Logging field observations, incidents, or site reports
        - add_list_item: Adding items to lists (shopping, inventory, tools)
        - query_tasks: Asking about tasks, schedule, or assignments
        - query_lists: Asking about list contents or inventory
        - query_reports: Asking about field reports or logs
        - update_task_status: Marking tasks complete or updating status
        - general_query: General questions about sites, equipment, or status
        - unknown: Input that doesn't fit any category
        
        Respond with just the intent name and a confidence score (0.0-1.0).
        Format: intent_name,confidence_score
        """
        
        try:
            response = await openai.ChatCompletion.acreate(
                model=settings.openai_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_input}
                ],
                max_tokens=50,
                temperature=0.1
            )
            
            result = response.choices[0].message.content.strip()
            intent_str, confidence_str = result.split(',')
            
            # Map string to Intent enum
            try:
                intent = Intent(intent_str.strip())
                confidence = float(confidence_str.strip())
                return intent, confidence
            except (ValueError, KeyError):
                self.logger.warning(f"Invalid intent classification result: {result}")
                return Intent.UNKNOWN, 0.5
                
        except Exception as e:
            self.logger.error(f"OpenAI intent classification error: {e}")
            raise
    
    def classify_intent_patterns(self, user_input: str) -> tuple[Intent, float]:
        """
        Fallback intent classification using regex patterns.
        
        Args:
            user_input: User's natural language input
            
        Returns:
            Tuple of (Intent, confidence_score)
        """
        user_input_lower = user_input.lower()
        
        # Check each intent pattern
        for intent, patterns in self.intent_patterns.items():
            for pattern in patterns:
                if re.search(pattern, user_input_lower):
                    # Calculate simple confidence based on pattern specificity
                    confidence = 0.7 + (len(pattern) / 1000)  # Longer patterns = higher confidence
                    confidence = min(confidence, 0.9)  # Cap at 0.9 for pattern matching
                    return intent, confidence
        
        # No patterns matched
        return Intent.UNKNOWN, 0.1
    
    async def handle_task_creation(self, user_input: str, user_context: Dict[str, Any], intent: Intent) -> Dict[str, Any]:
        """
        Handle task and reminder creation using Todoist API for NLP processing.
        
        According to the system design, tasks and reminders are processed through
        Todoist's Quick Add feature for natural language parsing, then structured
        data is stored in Supabase.
        """
        try:
            # Use Todoist API for natural language parsing
            todoist_result = await todoist_service.create_task_from_nlp(user_input)
            
            if not todoist_result['success']:
                return {
                    'success': False,
                    'response': "I couldn't parse that task request. Please try rephrasing it.",
                    'intent': intent.value
                }
            
            # Extract structured data from Todoist
            task_data = {
                'task_title': todoist_result['task_title'],
                'task_description_detailed': todoist_result.get('description', user_input),
                'assigned_to_user_id': user_context['flrts_user_id'],
                'site_id': user_context.get('primary_site_id'),
                'due_date': todoist_result.get('due_date'),
                'priority': todoist_result.get('priority', 'Medium'),
                'status': 'To Do',
                'todoist_task_id': todoist_result.get('todoist_id'),
                'created_by_user_id': user_context['flrts_user_id']
            }
            
            # Store in Supabase database
            created_task = db_client.create_task(task_data)
            
            # Create reminder if this was a reminder intent
            if intent == Intent.CREATE_REMINDER and todoist_result.get('due_datetime'):
                reminder_data = {
                    'reminder_title': task_data['task_title'],
                    'reminder_date_time': todoist_result['due_datetime'],
                    'user_to_remind_id': user_context['flrts_user_id'],
                    'related_task_id': created_task['id'],
                    'related_site_id': user_context.get('primary_site_id'),
                    'status': 'Scheduled',
                    'notification_channels': ['Telegram'],
                    'created_by_user_id': user_context['flrts_user_id']
                }
                
                db_client.supabase.table('reminders').insert(reminder_data).execute()
            
            response_text = f"✅ Created task: {created_task['task_title']}"
            if todoist_result.get('due_date'):
                response_text += f"\\nDue: {todoist_result['due_date']}"
            
            return {
                'success': True,
                'response': response_text,
                'intent': intent.value,
                'action_taken': 'task_created',
                'task_id': created_task['id'],
                'use_markdown': True
            }
            
        except Exception as e:
            self.logger.error(f"Error creating task: {e}")
            return {
                'success': False,
                'response': "Sorry, I couldn't create that task right now. Please try again.",
                'intent': intent.value,
                'error': str(e)
            }
    
    async def handle_field_report_creation(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Handle field report creation using OpenAI for natural language processing.
        
        Field reports are processed by OpenAI to extract structured information
        from narrative text input.
        """
        try:
            # Use OpenAI to structure the field report
            if self.openai_enabled:
                structured_report = await self.extract_field_report_data(user_input, user_context)
            else:
                # Fallback structured data extraction
                structured_report = self.extract_field_report_fallback(user_input, user_context)
            
            # Create field report in database
            report_data = {
                'site_id': structured_report.get('site_id') or user_context.get('primary_site_id'),
                'report_date': structured_report.get('report_date', date.today().isoformat()),
                'submitted_by_user_id': user_context['flrts_user_id'],
                'report_type': structured_report.get('report_type', 'Daily Operational Summary'),
                'report_title_summary': structured_report.get('title', 'Field Report'),
                'report_content_full': user_input,
                'report_status': 'Submitted'
            }
            
            created_report = db_client.create_field_report(report_data)
            
            response_text = f"📝 Field report logged: {created_report['report_title_summary']}"
            if structured_report.get('site_name'):
                response_text += f"\\nSite: {structured_report['site_name']}"
            
            return {
                'success': True,
                'response': response_text,
                'intent': Intent.CREATE_FIELD_REPORT.value,
                'action_taken': 'field_report_created',
                'report_id': created_report['id'],
                'use_markdown': True
            }
            
        except Exception as e:
            self.logger.error(f"Error creating field report: {e}")
            return {
                'success': False,
                'response': "Sorry, I couldn't log that field report right now. Please try again.",
                'intent': Intent.CREATE_FIELD_REPORT.value,
                'error': str(e)
            }
    
    async def extract_field_report_data(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Use OpenAI to extract structured data from field report narrative.
        
        Args:
            user_input: Natural language field report
            user_context: User context information
            
        Returns:
            Dictionary with structured report data
        """
        system_prompt = """
        Extract structured information from this field report text.
        Return a JSON object with these fields:
        - title: Brief summary (max 100 chars)
        - report_type: One of: Daily Operational Summary, Incident Report, Maintenance Log, Safety Observation, Equipment Check, Security Update, Visitor Log, Other
        - site_name: Site name if mentioned
        - equipment_mentioned: List of equipment/systems mentioned
        - priority_level: High, Medium, or Low based on content
        - requires_followup: true/false
        
        Only include fields that can be determined from the text.
        """
        
        try:
            response = await openai.ChatCompletion.acreate(
                model=settings.openai_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_input}
                ],
                max_tokens=200,
                temperature=0.1
            )
            
            import json
            result = json.loads(response.choices[0].message.content)
            
            # Map site name to site ID if possible
            if result.get('site_name'):
                site = db_client.get_site_by_name_or_alias(result['site_name'])
                if site:
                    result['site_id'] = site['id']
            
            return result
            
        except Exception as e:
            self.logger.error(f"Error extracting field report data with OpenAI: {e}")
            return {}
    
    def extract_field_report_fallback(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Fallback method to extract basic field report data using patterns.
        
        Args:
            user_input: Natural language field report
            user_context: User context information
            
        Returns:
            Dictionary with basic structured report data
        """
        result = {}
        
        # Extract site name from patterns like "Site Alpha:" or "at Site Beta"
        site_pattern = r'\b(?:site\s+|at\s+site\s+)(\w+)'
        site_match = re.search(site_pattern, user_input, re.IGNORECASE)
        if site_match:
            result['site_name'] = site_match.group(1)
        
        # Determine report type based on keywords
        user_lower = user_input.lower()
        if any(word in user_lower for word in ['incident', 'problem', 'issue', 'error', 'failure']):
            result['report_type'] = 'Incident Report'
        elif any(word in user_lower for word in ['maintenance', 'service', 'repair', 'check']):
            result['report_type'] = 'Maintenance Log'
        elif any(word in user_lower for word in ['safety', 'hazard', 'danger']):
            result['report_type'] = 'Safety Observation'
        else:
            result['report_type'] = 'Daily Operational Summary'
        
        # Generate simple title
        result['title'] = f"Field Report - {datetime.now().strftime('%Y-%m-%d')}"
        
        return result
    
    async def handle_list_item_addition(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle adding items to lists using OpenAI for item extraction."""
        # Implementation for list item addition
        # This would extract items and list type from user input
        # and add them to the appropriate list in the database
        return {
            'success': False,
            'response': "List item addition is not fully implemented yet.",
            'intent': Intent.ADD_LIST_ITEM.value
        }
    
    async def handle_task_query(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle task queries and status requests."""
        try:
            # Get user's tasks
            tasks = db_client.get_tasks_for_user(user_context['flrts_user_id'])
            
            if not tasks:
                return {
                    'success': True,
                    'response': "You don't have any tasks assigned right now.",
                    'intent': Intent.QUERY_TASKS.value
                }
            
            # Filter tasks based on query context
            today_tasks = [t for t in tasks if t.get('due_date') == date.today().isoformat()]
            pending_tasks = [t for t in tasks if t['status'] in ['To Do', 'In Progress']]
            
            response_text = "*Your Tasks:*\\n"
            for task in pending_tasks[:5]:  # Show up to 5 tasks
                status_emoji = "🔄" if task['status'] == 'In Progress' else "📝"
                due_text = f" (Due: {task['due_date']})" if task.get('due_date') else ""
                response_text += f"{status_emoji} {task['task_title']}{due_text}\\n"
            
            if len(pending_tasks) > 5:
                response_text += f"\\n...and {len(pending_tasks) - 5} more tasks"
            
            return {
                'success': True,
                'response': response_text,
                'intent': Intent.QUERY_TASKS.value,
                'use_markdown': True
            }
            
        except Exception as e:
            self.logger.error(f"Error querying tasks: {e}")
            return {
                'success': False,
                'response': "Sorry, I couldn't retrieve your tasks right now.",
                'intent': Intent.QUERY_TASKS.value
            }
    
    async def handle_list_query(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle list content queries."""
        # Implementation placeholder
        return {
            'success': False,
            'response': "List queries are not fully implemented yet.",
            'intent': Intent.QUERY_LISTS.value
        }
    
    async def handle_report_query(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle field report queries."""
        # Implementation placeholder
        return {
            'success': False,
            'response': "Report queries are not fully implemented yet.",
            'intent': Intent.QUERY_REPORTS.value
        }
    
    async def handle_task_status_update(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle task status updates and completion."""
        # Implementation placeholder
        return {
            'success': False,
            'response': "Task status updates are not fully implemented yet.",
            'intent': Intent.UPDATE_TASK_STATUS.value
        }
    
    async def handle_general_query(self, user_input: str, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Handle general queries about sites, status, etc."""
        # Implementation placeholder
        return {
            'success': True,
            'response': "I can help you with tasks, field reports, and lists. Try asking me to create a task or log a field report!",
            'intent': Intent.GENERAL_QUERY.value
        }


# Global NLP service instance
nlp_service = NLPService()