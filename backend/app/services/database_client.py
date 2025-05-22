"""
10NetZero-FLRTS Database Client

This module provides a comprehensive interface for interacting with the Supabase PostgreSQL database.
It includes both high-level Supabase client operations and direct PostgreSQL connections for
advanced business logic execution.

The database serves as the Single Source of Truth (SSoT) for all FLRTS data, including:
- Master data (sites, partners, vendors, personnel)
- Financial tracking (invoices, billings with markup calculations)
- Operational data (field reports, tasks, reminders, lists)
- Equipment management (general equipment and ASICs)

Business logic is implemented directly in PostgreSQL using functions and triggers,
which this client interfaces with for complex operations.
"""

import logging
import uuid
from contextlib import contextmanager
from typing import Any, Dict, List, Optional, Union, Generator
from datetime import datetime, date

import psycopg2
import psycopg2.extras
from supabase import create_client, Client
from psycopg2.extensions import connection as Connection

from config.settings import settings


class DatabaseError(Exception):
    """Custom exception for database-related errors."""
    pass


class DatabaseClient:
    """
    Comprehensive database client for 10NetZero-FLRTS system.
    
    Provides both Supabase client operations for standard CRUD and direct PostgreSQL
    connections for executing business logic functions and complex queries.
    All database operations are logged for debugging and audit purposes.
    """
    
    def __init__(self):
        """
        Initialize the database client with Supabase and PostgreSQL connections.
        
        The client maintains both connection types:
        - Supabase client for REST API operations and real-time features
        - Direct PostgreSQL connection for business logic functions and complex queries
        """
        self.logger = logging.getLogger(__name__)
        
        # Initialize Supabase client
        if not settings.supabase_url or not settings.supabase_key:
            raise DatabaseError("Supabase URL and key must be configured")
        
        self.supabase: Client = create_client(
            settings.supabase_url,
            settings.supabase_key
        )
        
        self.logger.info("Database client initialized with Supabase connection")
    
    def check_connection(self) -> bool:
        """
        Verify database connectivity by performing a simple query.
        
        Returns:
            True if connection is successful, False otherwise
        """
        try:
            # Test Supabase connection with a simple query
            result = self.supabase.table('sites').select('count').execute()
            self.logger.debug("Database connection verified")
            return True
        except Exception as e:
            self.logger.error(f"Database connection check failed: {e}")
            return False
    
    @contextmanager
    def get_postgres_connection(self) -> Generator[Connection, None, None]:
        """
        Context manager for direct PostgreSQL connections.
        
        This is used for executing business logic functions, complex queries,
        and operations that require transaction control beyond what Supabase provides.
        
        Yields:
            psycopg2 connection object
            
        Raises:
            DatabaseError: If connection cannot be established
        """
        conn = None
        try:
            conn = psycopg2.connect(
                settings.database_connection_string,
                cursor_factory=psycopg2.extras.RealDictCursor
            )
            self.logger.debug("Direct PostgreSQL connection established")
            yield conn
        except psycopg2.Error as e:
            self.logger.error(f"PostgreSQL connection error: {e}")
            if conn:
                conn.rollback()
            raise DatabaseError(f"Database connection failed: {e}")
        finally:
            if conn:
                conn.close()
                self.logger.debug("PostgreSQL connection closed")
    
    # ==========================================
    # FLRTS USERS OPERATIONS
    # ==========================================
    
    def get_user_by_telegram_id(self, telegram_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve user information by Telegram ID for bot authentication.
        
        Args:
            telegram_id: Telegram user ID as string
            
        Returns:
            User record dictionary or None if not found
        """
        try:
            result = self.supabase.table('flrts_users').select(
                'id, user_id_display, personnel_id, telegram_id, telegram_username, '
                'user_role_flrts, is_active_flrts_user, '
                'personnel!inner(first_name, last_name, email, primary_site_id)'
            ).eq('telegram_id', telegram_id).eq('is_active_flrts_user', True).execute()
            
            if result.data:
                user = result.data[0]
                self.logger.debug(f"Retrieved user for Telegram ID {telegram_id}")
                return user
            
            self.logger.warning(f"No active user found for Telegram ID {telegram_id}")
            return None
            
        except Exception as e:
            self.logger.error(f"Error retrieving user by Telegram ID {telegram_id}: {e}")
            raise DatabaseError(f"Failed to retrieve user: {e}")
    
    def create_flrts_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new FLRTS user record.
        
        Args:
            user_data: Dictionary containing user information
            
        Returns:
            Created user record
        """
        try:
            # Generate user ID display if not provided
            if 'user_id_display' not in user_data:
                user_data['user_id_display'] = f"USER-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"
            
            result = self.supabase.table('flrts_users').insert(user_data).execute()
            
            if result.data:
                user = result.data[0]
                self.logger.info(f"Created FLRTS user: {user['user_id_display']}")
                return user
            
            raise DatabaseError("User creation returned no data")
            
        except Exception as e:
            self.logger.error(f"Error creating FLRTS user: {e}")
            raise DatabaseError(f"Failed to create user: {e}")
    
    # ==========================================
    # SITES OPERATIONS
    # ==========================================
    
    def get_sites(self, active_only: bool = True) -> List[Dict[str, Any]]:
        """
        Retrieve all sites, optionally filtering to active sites only.
        
        Args:
            active_only: If True, return only active sites
            
        Returns:
            List of site records
        """
        try:
            query = self.supabase.table('sites').select('*')
            
            if active_only:
                query = query.eq('is_active', True)
            
            result = query.execute()
            
            self.logger.debug(f"Retrieved {len(result.data)} sites")
            return result.data
            
        except Exception as e:
            self.logger.error(f"Error retrieving sites: {e}")
            raise DatabaseError(f"Failed to retrieve sites: {e}")
    
    def get_site_by_name_or_alias(self, site_identifier: str) -> Optional[Dict[str, Any]]:
        """
        Find a site by name or alias for flexible site identification.
        
        Args:
            site_identifier: Site name or alias to search for
            
        Returns:
            Site record or None if not found
        """
        try:
            # First try to find by site name
            result = self.supabase.table('sites').select('*').eq('site_name', site_identifier).execute()
            
            if result.data:
                return result.data[0]
            
            # Try to find by alias
            alias_result = self.supabase.table('site_aliases').select(
                'site_id, sites!inner(*)'
            ).eq('alias_name', site_identifier).execute()
            
            if alias_result.data:
                return alias_result.data[0]['sites']
            
            self.logger.debug(f"No site found for identifier: {site_identifier}")
            return None
            
        except Exception as e:
            self.logger.error(f"Error finding site by identifier {site_identifier}: {e}")
            raise DatabaseError(f"Failed to find site: {e}")
    
    # ==========================================
    # FIELD REPORTS OPERATIONS
    # ==========================================
    
    def create_field_report(self, report_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new field report with automatic ID generation.
        
        Args:
            report_data: Field report information
            
        Returns:
            Created field report record
        """
        try:
            # Generate report ID display if not provided
            if 'report_id_display' not in report_data:
                today = datetime.now().strftime('%Y%m%d')
                report_data['report_id_display'] = f"FR-{today}-{str(uuid.uuid4())[:8].upper()}"
            
            # Set submission timestamp if not provided
            if 'submission_timestamp' not in report_data:
                report_data['submission_timestamp'] = datetime.now().isoformat()
            
            result = self.supabase.table('field_reports').insert(report_data).execute()
            
            if result.data:
                report = result.data[0]
                self.logger.info(f"Created field report: {report['report_id_display']}")
                return report
            
            raise DatabaseError("Field report creation returned no data")
            
        except Exception as e:
            self.logger.error(f"Error creating field report: {e}")
            raise DatabaseError(f"Failed to create field report: {e}")
    
    def get_field_reports_by_site(self, site_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Retrieve recent field reports for a specific site.
        
        Args:
            site_id: UUID of the site
            limit: Maximum number of reports to return
            
        Returns:
            List of field report records
        """
        try:
            result = self.supabase.table('field_reports').select(
                'id, report_id_display, report_date, report_type, '
                'report_title_summary, report_status, submission_timestamp, '
                'submitted_by_user_id, flrts_users!inner(personnel!inner(first_name, last_name))'
            ).eq('site_id', site_id).order('submission_timestamp', desc=True).limit(limit).execute()
            
            self.logger.debug(f"Retrieved {len(result.data)} field reports for site {site_id}")
            return result.data
            
        except Exception as e:
            self.logger.error(f"Error retrieving field reports for site {site_id}: {e}")
            raise DatabaseError(f"Failed to retrieve field reports: {e}")
    
    # ==========================================
    # TASKS OPERATIONS
    # ==========================================
    
    def create_task(self, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new task with automatic ID generation.
        
        Args:
            task_data: Task information
            
        Returns:
            Created task record
        """
        try:
            # Generate task ID display if not provided
            if 'task_id_display' not in task_data:
                today = datetime.now().strftime('%Y%m%d')
                task_data['task_id_display'] = f"TASK-{today}-{str(uuid.uuid4())[:8].upper()}"
            
            result = self.supabase.table('tasks').insert(task_data).execute()
            
            if result.data:
                task = result.data[0]
                self.logger.info(f"Created task: {task['task_id_display']}")
                return task
            
            raise DatabaseError("Task creation returned no data")
            
        except Exception as e:
            self.logger.error(f"Error creating task: {e}")
            raise DatabaseError(f"Failed to create task: {e}")
    
    def get_tasks_for_user(self, user_id: str, status_filter: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieve tasks assigned to a specific user.
        
        Args:
            user_id: UUID of the assigned user
            status_filter: Optional status to filter by
            
        Returns:
            List of task records
        """
        try:
            query = self.supabase.table('tasks').select(
                'id, task_id_display, task_title, task_description_detailed, '
                'due_date, priority, status, created_at, '
                'sites(site_name), assigned_to_user_id'
            ).eq('assigned_to_user_id', user_id)
            
            if status_filter:
                query = query.eq('status', status_filter)
            
            result = query.order('created_at', desc=True).execute()
            
            self.logger.debug(f"Retrieved {len(result.data)} tasks for user {user_id}")
            return result.data
            
        except Exception as e:
            self.logger.error(f"Error retrieving tasks for user {user_id}: {e}")
            raise DatabaseError(f"Failed to retrieve tasks: {e}")
    
    # ==========================================
    # LISTS AND LIST ITEMS OPERATIONS
    # ==========================================
    
    def get_lists_by_site(self, site_id: str, list_type: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieve lists for a specific site, optionally filtered by type.
        
        Args:
            site_id: UUID of the site
            list_type: Optional list type to filter by
            
        Returns:
            List of list records
        """
        try:
            query = self.supabase.table('lists').select('*').eq('site_id', site_id).eq('status', 'Active')
            
            if list_type:
                query = query.eq('list_type', list_type)
            
            result = query.order('list_name').execute()
            
            self.logger.debug(f"Retrieved {len(result.data)} lists for site {site_id}")
            return result.data
            
        except Exception as e:
            self.logger.error(f"Error retrieving lists for site {site_id}: {e}")
            raise DatabaseError(f"Failed to retrieve lists: {e}")
    
    def add_list_item(self, list_id: str, item_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Add a new item to an existing list.
        
        Args:
            list_id: UUID of the parent list
            item_data: List item information
            
        Returns:
            Created list item record
        """
        try:
            # Set parent list ID
            item_data['parent_list_id'] = list_id
            
            # Generate item ID display if not provided
            if 'list_item_id_display' not in item_data:
                today = datetime.now().strftime('%Y%m%d')
                item_data['list_item_id_display'] = f"LI-{today}-{str(uuid.uuid4())[:8].upper()}"
            
            result = self.supabase.table('list_items').insert(item_data).execute()
            
            if result.data:
                item = result.data[0]
                self.logger.info(f"Added item to list {list_id}: {item['list_item_id_display']}")
                return item
            
            raise DatabaseError("List item creation returned no data")
            
        except Exception as e:
            self.logger.error(f"Error adding item to list {list_id}: {e}")
            raise DatabaseError(f"Failed to add list item: {e}")
    
    # ==========================================
    # BUSINESS LOGIC FUNCTIONS
    # ==========================================
    
    def execute_markup_calculation(self, invoice_id: str) -> bool:
        """
        Execute the markup calculation business logic function for a specific invoice.
        
        Args:
            invoice_id: UUID of the vendor invoice
            
        Returns:
            True if calculation was successful
        """
        try:
            with self.get_postgres_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT calculate_invoice_markup(%s)", (invoice_id,))
                    conn.commit()
                    
            self.logger.info(f"Executed markup calculation for invoice {invoice_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error executing markup calculation for invoice {invoice_id}: {e}")
            raise DatabaseError(f"Failed to calculate markup: {e}")
    
    def get_financial_summary_for_site(self, site_id: str) -> Dict[str, Any]:
        """
        Get financial summary for a site using the database business logic function.
        
        Args:
            site_id: UUID of the site
            
        Returns:
            Financial summary data
        """
        try:
            with self.get_postgres_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM get_site_financial_summary(%s)", (site_id,))
                    result = cursor.fetchone()
                    
            if result:
                summary = dict(result)
                self.logger.debug(f"Retrieved financial summary for site {site_id}")
                return summary
            
            return {}
            
        except Exception as e:
            self.logger.error(f"Error getting financial summary for site {site_id}: {e}")
            raise DatabaseError(f"Failed to get financial summary: {e}")
    
    def get_outstanding_partner_billings(self) -> List[Dict[str, Any]]:
        """
        Retrieve outstanding partner billings using the database view.
        
        Returns:
            List of outstanding billing records
        """
        try:
            result = self.supabase.table('outstanding_partner_billings').select('*').execute()
            
            self.logger.debug(f"Retrieved {len(result.data)} outstanding partner billings")
            return result.data
            
        except Exception as e:
            self.logger.error(f"Error retrieving outstanding partner billings: {e}")
            raise DatabaseError(f"Failed to retrieve outstanding billings: {e}")
    
    # ==========================================
    # UTILITY METHODS
    # ==========================================
    
    def execute_raw_query(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """
        Execute a raw SQL query with optional parameters.
        
        Args:
            query: SQL query string
            params: Optional query parameters
            
        Returns:
            Query results as list of dictionaries
        """
        try:
            with self.get_postgres_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(query, params)
                    results = cursor.fetchall()
                    
            formatted_results = [dict(row) for row in results]
            self.logger.debug(f"Executed raw query, returned {len(formatted_results)} rows")
            return formatted_results
            
        except Exception as e:
            self.logger.error(f"Error executing raw query: {e}")
            raise DatabaseError(f"Failed to execute query: {e}")


# Global database client instance
db_client = DatabaseClient()