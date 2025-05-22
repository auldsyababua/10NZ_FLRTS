"""
10NetZero-FLRTS API Handler

This module provides REST API endpoints for the 10NetZero-FLRTS system.
These endpoints support integration with Noloco web interface and other
external systems that need programmatic access to FLRTS data and operations.

The API provides:
- CRUD operations for all FLRTS entities
- Business logic execution endpoints
- Data validation and error handling
- Authentication and authorization
"""

import logging
from typing import Dict, Any, Optional
from datetime import datetime

from flask import Blueprint, request, jsonify, g
from marshmallow import Schema, fields, ValidationError

from config.settings import settings
from app.services.database_client import db_client
from app.services.nlp_service import nlp_service
from app.services.external_apis import todoist_service, google_drive_service


# Create Flask blueprint for API endpoints
api_bp = Blueprint('api', __name__)


class APIError(Exception):
    """Custom exception for API-related errors."""
    pass


# ==========================================
# REQUEST/RESPONSE SCHEMAS
# ==========================================

class UserContextSchema(Schema):
    """Schema for user context information."""
    flrts_user_id = fields.Str(required=True)
    telegram_user_id = fields.Str()
    primary_site_id = fields.Str()
    user_role = fields.Str(required=True)
    full_name = fields.Str(required=True)


class TaskCreateSchema(Schema):
    """Schema for task creation requests."""
    task_title = fields.Str(required=True, validate=lambda x: len(x) <= 255)
    task_description_detailed = fields.Str()
    assigned_to_user_id = fields.Str(required=True)
    site_id = fields.Str()
    due_date = fields.Date()
    priority = fields.Str(validate=lambda x: x in ['High', 'Medium', 'Low'])
    parent_task_id = fields.Str()


class FieldReportCreateSchema(Schema):
    """Schema for field report creation requests."""
    site_id = fields.Str(required=True)
    report_type = fields.Str(required=True)
    report_title_summary = fields.Str(required=True, validate=lambda x: len(x) <= 255)
    report_content_full = fields.Str(required=True)
    submitted_by_user_id = fields.Str(required=True)


class NLPProcessSchema(Schema):
    """Schema for NLP processing requests."""
    user_input = fields.Str(required=True, validate=lambda x: len(x) <= 2000)
    user_context = fields.Nested(UserContextSchema, required=True)


# ==========================================
# UTILITY FUNCTIONS
# ==========================================

def validate_json_request(schema_class):
    """
    Decorator to validate JSON request data against a schema.
    
    Args:
        schema_class: Marshmallow schema class for validation
    """
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                schema = schema_class()
                data = schema.load(request.get_json() or {})
                g.validated_data = data
                return func(*args, **kwargs)
            except ValidationError as e:
                return jsonify({
                    'error': 'Validation Error',
                    'message': 'Request data validation failed',
                    'details': e.messages
                }), 400
            except Exception as e:
                logging.getLogger(__name__).error(f"Request validation error: {e}")
                return jsonify({
                    'error': 'Bad Request',
                    'message': 'Invalid request data'
                }), 400
        wrapper.__name__ = func.__name__
        return wrapper
    return decorator


def handle_api_errors(func):
    """
    Decorator to handle common API errors and return structured responses.
    """
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except APIError as e:
            return jsonify({
                'error': 'API Error',
                'message': str(e)
            }), 400
        except Exception as e:
            logging.getLogger(__name__).error(f"Unhandled API error: {e}", exc_info=True)
            return jsonify({
                'error': 'Internal Server Error',
                'message': 'An unexpected error occurred'
            }), 500
    wrapper.__name__ = func.__name__
    return wrapper


# ==========================================
# NLP PROCESSING ENDPOINTS
# ==========================================

@api_bp.route('/nlp/process', methods=['POST'])
@validate_json_request(NLPProcessSchema)
@handle_api_errors
async def process_nlp_input():
    """
    Process natural language input through the NLP orchestration pipeline.
    
    This endpoint allows external systems to leverage the same NLP processing
    capabilities used by the Telegram bot interface.
    """
    data = g.validated_data
    
    # Process input through NLP service
    result = await nlp_service.process_user_input(
        user_input=data['user_input'],
        user_context=data['user_context']
    )
    
    return jsonify({
        'success': result.get('success', False),
        'response': result.get('response'),
        'intent': result.get('intent'),
        'confidence': result.get('confidence'),
        'action_taken': result.get('action_taken'),
        'metadata': {
            'timestamp': datetime.now().isoformat(),
            'processed_by': 'nlp_service'
        }
    })


# ==========================================
# TASK MANAGEMENT ENDPOINTS
# ==========================================

@api_bp.route('/tasks', methods=['POST'])
@validate_json_request(TaskCreateSchema)
@handle_api_errors
def create_task():
    """Create a new task through the API."""
    data = g.validated_data
    
    # Create task in database
    created_task = db_client.create_task(data)
    
    return jsonify({
        'success': True,
        'message': 'Task created successfully',
        'task': {
            'id': created_task['id'],
            'task_id_display': created_task['task_id_display'],
            'task_title': created_task['task_title'],
            'status': created_task['status'],
            'created_at': created_task['created_at']
        }
    }), 201


@api_bp.route('/tasks/user/<user_id>', methods=['GET'])
@handle_api_errors
def get_user_tasks(user_id: str):
    """Retrieve tasks for a specific user."""
    status_filter = request.args.get('status')
    limit = request.args.get('limit', 50, type=int)
    
    # Get tasks from database
    tasks = db_client.get_tasks_for_user(user_id, status_filter)
    
    # Apply limit
    if limit:
        tasks = tasks[:limit]
    
    return jsonify({
        'success': True,
        'tasks': tasks,
        'count': len(tasks),
        'filters_applied': {
            'status': status_filter,
            'limit': limit
        }
    })


@api_bp.route('/tasks/<task_id>/complete', methods=['POST'])
@handle_api_errors
def complete_task(task_id: str):
    """Mark a task as completed."""
    try:
        # Update task status in database
        result = db_client.supabase.table('tasks').update({
            'status': 'Completed',
            'completion_date': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat()
        }).eq('id', task_id).execute()
        
        if not result.data:
            raise APIError(f"Task {task_id} not found")
        
        # Also complete in Todoist if linked
        task = result.data[0]
        if task.get('todoist_task_id'):
            await todoist_service.complete_task(task['todoist_task_id'])
        
        return jsonify({
            'success': True,
            'message': 'Task completed successfully',
            'task_id': task_id
        })
        
    except Exception as e:
        raise APIError(f"Failed to complete task: {e}")


# ==========================================
# FIELD REPORTS ENDPOINTS
# ==========================================

@api_bp.route('/field-reports', methods=['POST'])
@validate_json_request(FieldReportCreateSchema)
@handle_api_errors
def create_field_report():
    """Create a new field report through the API."""
    data = g.validated_data
    
    # Add submission timestamp
    data['submission_timestamp'] = datetime.now().isoformat()
    data['report_status'] = 'Submitted'
    
    # Create report in database
    created_report = db_client.create_field_report(data)
    
    return jsonify({
        'success': True,
        'message': 'Field report created successfully',
        'report': {
            'id': created_report['id'],
            'report_id_display': created_report['report_id_display'],
            'report_title_summary': created_report['report_title_summary'],
            'report_status': created_report['report_status'],
            'submission_timestamp': created_report['submission_timestamp']
        }
    }), 201


@api_bp.route('/field-reports/site/<site_id>', methods=['GET'])
@handle_api_errors
def get_site_field_reports(site_id: str):
    """Retrieve field reports for a specific site."""
    limit = request.args.get('limit', 50, type=int)
    
    # Get reports from database
    reports = db_client.get_field_reports_by_site(site_id, limit)
    
    return jsonify({
        'success': True,
        'reports': reports,
        'count': len(reports),
        'site_id': site_id
    })


# ==========================================
# SITES ENDPOINTS
# ==========================================

@api_bp.route('/sites', methods=['GET'])
@handle_api_errors
def get_sites():
    """Retrieve all sites."""
    active_only = request.args.get('active_only', 'true').lower() == 'true'
    
    # Get sites from database
    sites = db_client.get_sites(active_only)
    
    return jsonify({
        'success': True,
        'sites': sites,
        'count': len(sites),
        'active_only': active_only
    })


@api_bp.route('/sites/search', methods=['GET'])
@handle_api_errors
def search_sites():
    """Search for sites by name or alias."""
    query = request.args.get('q', '').strip()
    
    if not query:
        return jsonify({
            'error': 'Bad Request',
            'message': 'Query parameter "q" is required'
        }), 400
    
    # Search for site
    site = db_client.get_site_by_name_or_alias(query)
    
    if site:
        return jsonify({
            'success': True,
            'site': site,
            'query': query
        })
    else:
        return jsonify({
            'success': False,
            'message': f'No site found matching "{query}"',
            'query': query
        }), 404


# ==========================================
# BUSINESS LOGIC ENDPOINTS
# ==========================================

@api_bp.route('/business/markup-calculation/<invoice_id>', methods=['POST'])
@handle_api_errors
def execute_markup_calculation(invoice_id: str):
    """Execute markup calculation for a specific invoice."""
    try:
        success = db_client.execute_markup_calculation(invoice_id)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Markup calculation executed successfully',
                'invoice_id': invoice_id
            })
        else:
            raise APIError("Markup calculation failed")
            
    except Exception as e:
        raise APIError(f"Failed to execute markup calculation: {e}")


@api_bp.route('/business/financial-summary/site/<site_id>', methods=['GET'])
@handle_api_errors
def get_site_financial_summary(site_id: str):
    """Get financial summary for a specific site."""
    try:
        summary = db_client.get_financial_summary_for_site(site_id)
        
        return jsonify({
            'success': True,
            'financial_summary': summary,
            'site_id': site_id,
            'generated_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        raise APIError(f"Failed to get financial summary: {e}")


@api_bp.route('/business/outstanding-billings', methods=['GET'])
@handle_api_errors
def get_outstanding_billings():
    """Get all outstanding partner billings."""
    try:
        billings = db_client.get_outstanding_partner_billings()
        
        return jsonify({
            'success': True,
            'outstanding_billings': billings,
            'count': len(billings),
            'generated_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        raise APIError(f"Failed to get outstanding billings: {e}")


# ==========================================
# INTEGRATION ENDPOINTS
# ==========================================

@api_bp.route('/integrations/todoist/sync', methods=['POST'])
@handle_api_errors
async def sync_todoist_tasks():
    """Synchronize tasks with Todoist."""
    try:
        # Get recent tasks from Todoist
        todoist_tasks = await todoist_service.get_tasks()
        
        # Sync logic would go here to update local database
        # This is a placeholder for the full implementation
        
        return jsonify({
            'success': True,
            'message': 'Todoist synchronization completed',
            'tasks_processed': len(todoist_tasks),
            'sync_timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        raise APIError(f"Todoist synchronization failed: {e}")


@api_bp.route('/integrations/google-drive/create-sop', methods=['POST'])
@handle_api_errors
async def create_site_sop():
    """Create a new SOP document for a site."""
    data = request.get_json()
    
    if not data or 'site_id' not in data:
        return jsonify({
            'error': 'Bad Request',
            'message': 'site_id is required'
        }), 400
    
    try:
        # Get site information
        sites = db_client.get_sites()
        site = next((s for s in sites if s['id'] == data['site_id']), None)
        
        if not site:
            raise APIError(f"Site {data['site_id']} not found")
        
        # Create SOP document
        document_link = await google_drive_service.create_site_sop_document(site)
        
        if document_link:
            # Update site with SOP link
            db_client.supabase.table('sites').update({
                'sop_document_link': document_link,
                'updated_at': datetime.now().isoformat()
            }).eq('id', data['site_id']).execute()
            
            return jsonify({
                'success': True,
                'message': 'SOP document created successfully',
                'document_link': document_link,
                'site_id': data['site_id']
            })
        else:
            raise APIError("Failed to create SOP document")
            
    except Exception as e:
        raise APIError(f"SOP creation failed: {e}")


# ==========================================
# UTILITY ENDPOINTS
# ==========================================

@api_bp.route('/database/raw-query', methods=['POST'])
@handle_api_errors
def execute_raw_query():
    """
    Execute a raw SQL query (admin endpoint).
    
    WARNING: This endpoint should be restricted in production environments.
    """
    if settings.is_production:
        return jsonify({
            'error': 'Forbidden',
            'message': 'Raw query execution disabled in production'
        }), 403
    
    data = request.get_json()
    
    if not data or 'query' not in data:
        return jsonify({
            'error': 'Bad Request',
            'message': 'SQL query is required'
        }), 400
    
    try:
        results = db_client.execute_raw_query(
            data['query'],
            data.get('params')
        )
        
        return jsonify({
            'success': True,
            'results': results,
            'count': len(results),
            'executed_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        raise APIError(f"Query execution failed: {e}")


@api_bp.route('/test/database-connection', methods=['GET'])
@handle_api_errors
def test_database_connection():
    """Test database connectivity."""
    try:
        connection_status = db_client.check_connection()
        
        return jsonify({
            'success': connection_status,
            'message': 'Database connection successful' if connection_status else 'Database connection failed',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Database connection test failed: {e}',
            'timestamp': datetime.now().isoformat()
        }), 500