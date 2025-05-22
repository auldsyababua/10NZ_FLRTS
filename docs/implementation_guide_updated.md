# 10NetZero-FLRTS Implementation Guide 

**Version:** 2.0 (Aligning with SDD v2.1)
**Date:** May 21, 2025

## 1. Project Overview (Updated)

The 10NetZero-FLRTS system has been implemented with these key components:

* **Supabase PostgreSQL Database** as the Single Source of Truth (SSoT) for all data, replacing the originally planned Noloco Tables
* **Complete Database Schema** with tables for:
  * Master data (sites, partners, vendors, personnel)
  * Relationships (site-partner assignments, site-vendor assignments)
  * Financial (vendor invoices, partner billings)
  * Equipment (general equipment, ASICs) 
  * Operational (field reports, lists, tasks, reminders)
* **Business Logic Implementation** via PostgreSQL functions and triggers for:
  * Markup management system
  * Partner billing generation
  * Financial reporting
  * Audit logging

## 2. Database Structure

### 2.1 Master Data Tables
* **operators**: Organizations operating sites
* **sites**: Physical locations with addresses, coordinates, and operational status
* **site_aliases**: Alternative names for sites (many-to-one)
* **partners**: Organizations with business relationships
* **vendors**: Suppliers of goods and services
* **personnel**: Staff members with contact details
* **flrts_users**: System users linked to personnel

### 2.2 Relationship Tables
* **site_partner_assignments**: Links sites to partners with markup percentages
* **site_vendor_assignments**: Links sites to vendors with service descriptions

### 2.3 Financial Tables
* **vendor_invoices**: Tracks vendor invoices with markup processing
* **partner_billings**: Billing records for partners based on vendor invoices

### 2.4 Equipment Tables
* **equipment**: General equipment inventory
* **asics**: Mining hardware tracking
* **licenses_agreements**: Legal documents and contracts

### 2.5 Operational Tables
* **field_reports**: On-site observations
* **field_report_edits**: Version control for field reports
* **lists**: Checklists, inventories, procedures
* **list_items**: Individual entries in lists
* **tasks**: Assignable work items
* **reminders**: Time-based notifications
* **notifications_log**: System notification history

## 3. Business Logic

### 3.1 Markup Management
The markup management system handles:

1. **Automatic Markup Calculation**
   * Based on site-partner relationships in site_partner_assignments
   * Implemented in calculate_invoice_markup() function
   * Triggers when new invoices are created or existing ones updated

2. **Partner Billing Generation**
   * Creates partner_billings records from vendor_invoices
   * Preserves payment status during updates
   * Implemented in create_partner_billing() function

3. **Audit Logging**
   * Records all markup percentage changes in markup_changes_log
   * Captures old/new values, timestamp, and user

4. **Financial Reporting**
   * get_partner_financial_summary() function for partner financials
   * get_site_financial_summary() function for site financials
   * outstanding_partner_billings view for actionable items

## 4. Implementation Details

### 4.1 Database Connection
The Supabase PostgreSQL database is accessible at:
```
Host: db.thnwlykidzhrsagyjncc.supabase.co
Port: 5432
Database: postgres
User: postgres
```

### 4.2 Implementation Files
* **supabase_schema_fixed.sql**: Main schema with tables, relationships, indexes
* **supabase_schema_update.sql**: Business logic implementation with functions, triggers
* **supabase_sample_data_upsert.sql**: Sample data with ON CONFLICT handling
* **execute_psql.sh**: Direct connection script for deployment

### 4.3 Key Features
* UUID primary keys for all tables
* Generated columns for computed fields (full_name, full_site_address)
* Strategic indexing for performance optimization
* CHECK constraints for data validation
* Consistent naming conventions
* Comprehensive audit capabilities

## 5. Next Steps for Integration

### 5.1 Backend Integration
* Develop Flask backend to interact with Supabase
* Implement psycopg2 client for PostgreSQL connection
* Connect Telegram bot for field operations
* Integrate with Todoist for task management

### 5.2 Security Implementation
* Configure Row-Level Security policies
* Set up application roles for user access
* Implement authentication flow with Supabase Auth

### 5.3 Performance Monitoring
* Monitor query performance
* Adjust indexes as needed based on usage patterns
* Implement scheduled maintenance procedures