# Noloco to Supabase Integration Guide

Version: 1.0
Date: May 20, 2025

This document outlines how to integrate Noloco (as the user interface) with Supabase PostgreSQL (as the database backend) for the 10NetZero-FLRTS system.

## Overview

Noloco is a no-code platform that allows you to build web applications without writing code. Supabase is a PostgreSQL-based backend-as-a-service platform. This integration will leverage Noloco's customizable frontend capabilities while using Supabase's robust PostgreSQL database as the Single Source of Truth (SSoT).

## Integration Architecture

```
┌─────────────┐      ┌───────────────┐      ┌─────────────────┐
│             │      │               │      │                 │
│   Noloco    │─────▶│   Supabase    │◀─────│  Flask Backend  │
│  Web App    │      │  PostgreSQL   │      │                 │
│             │      │               │      │                 │
└─────────────┘      └───────────────┘      └─────────────────┘
       ▲                     ▲                      ▲
       │                     │                      │
       │                     │                      │
       ▼                     │                      ▼
┌─────────────┐              │              ┌─────────────────┐
│             │              │              │                 │
│    Users    │              └──────────────│   Telegram Bot  │
│             │                             │                 │
└─────────────┘                             └─────────────────┘
```

- **Noloco**: Serves as the web interface for users to interact with the data
- **Supabase**: Provides the PostgreSQL database backend and API
- **Flask Backend**: Handles Telegram bot interactions and business logic
- **Users**: Access the system via Noloco's web interface
- **Telegram Bot**: Field technicians interact via Telegram, which connects to Flask

## Noloco-Supabase Connection Setup

### Step 1: Create a Supabase Project

1. Sign up for Supabase at [https://supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and API keys (anon/public key and service_role key)

### Step 2: Create Database Schema in Supabase

1. Execute the SQL scripts provided in `supabase_schema.sql` to create all tables, relationships, constraints, and indexes
2. Execute the SQL scripts in `supabase_markup_manager.sql` to implement the markup manager business logic
3. Verify that all tables, views, functions, and triggers are created correctly

### Step 3: Configure Noloco to Connect to Supabase

1. Log in to your Noloco account
2. Create a new project or use an existing one
3. Go to "Settings" > "Data Sources"
4. Add a new data source:
   - Select "PostgreSQL" or "External Database" as the source type
   - Enter your Supabase PostgreSQL connection details:
     - Host: `[your-project-id].supabase.co`
     - Port: `5432`
     - Database Name: `postgres`
     - Username: `postgres`
     - Password: `[your-database-password]`
     - SSL Mode: `require`
5. Test the connection to ensure it works

### Step 4: Configure Noloco Tables and Views

1. Once connected, Noloco will detect the tables in your Supabase database
2. For each table, configure how it appears in Noloco:
   - Set display fields (which fields to show in list views)
   - Configure field types and formatting
   - Set up relationships between tables
   - Define permissions for who can view/edit each table

### Step 5: Create Noloco Views and Forms

1. Create list views for each main table (Sites, Partners, Vendors, etc.)
2. Design detail views for individual records
3. Create forms for data entry and editing
4. Set up dashboards for key metrics and reports
5. Configure navigation and menu structure

## Integration Details

### Database Connection

Noloco offers two methods to connect to Supabase:

1. **Direct PostgreSQL Connection**: Connect directly to Supabase's PostgreSQL database
   - Pros: Full access to all database features
   - Cons: Requires proper security configuration

2. **API Connection**: Connect via Supabase's REST or GraphQL API
   - Pros: Simpler authentication, automatic Row-Level Security enforcement
   - Cons: Some limitations on complex queries

For the 10NetZero-FLRTS system, the **Direct PostgreSQL Connection** is recommended for full access to all database features, including views, functions, and triggers.

### Authentication and Authorization

There are several approaches to handling authentication:

1. **Noloco's Built-in Authentication**:
   - Users authenticate through Noloco
   - Noloco handles session management
   - Database access is via a shared database user

2. **Supabase Auth + JWT Passing**:
   - Users authenticate through Supabase Auth
   - JWT tokens are passed to Noloco
   - Supabase RLS policies enforce access control

For simplicity, the recommended approach is to use **Noloco's Built-in Authentication** for the initial implementation.

### Row-Level Security (RLS)

Implement RLS policies in Supabase to control data access at the database level:

1. Create database roles for different user types:
   - Admin
   - Site Manager
   - Field Technician
   - Finance
   - Viewer

2. Implement RLS policies for sensitive tables:
   - sites
   - vendor_invoices
   - partner_billings
   - field_reports
   - tasks

3. Configure Noloco to respect these permissions by linking Noloco user roles to database roles.

Example RLS policy implementation is included in the `supabase_schema.sql` file.

## Handling Database Functions and Triggers

Supabase PostgreSQL includes functions and triggers for business logic (particularly the Markup Manager). Ensure Noloco forms and actions respect these database-level automations:

1. **Vendor Invoice Creation**:
   - When a user creates a vendor invoice through Noloco, database triggers will automatically:
     - Calculate the markup based on site-partner relationship
     - Create associated partner billing records

2. **Site-Partner Assignment Updates**:
   - When markup percentages change, database triggers will update related invoices

3. **Partner Billing Management**:
   - Partner billings are automatically created/updated based on vendor invoices
   - Updates to invoice status can trigger updates to billing status

## Limitations and Workarounds

### 1. Complex Queries and Reporting

**Challenge**: Noloco may have limitations with very complex queries.

**Solution**: 
- Use PostgreSQL views for complex queries
- Noloco can display these views as if they were tables
- Examples: `vendor_invoice_summary`, `site_financial_summary`, `partner_financial_summary`

### 2. Custom Business Logic

**Challenge**: Some business logic may be too complex for Noloco's visual builder.

**Solution**:
- Implement complex logic directly in PostgreSQL functions and triggers (as done with the Markup Manager)
- For very complex operations, use the Flask backend with webhooks

### 3. Real-time Updates

**Challenge**: Noloco may not natively support real-time updates.

**Solution**:
- Implement periodic refresh of critical views
- Consider Supabase's Realtime feature for future enhancements

## Testing the Integration

1. **Database Connection Test**:
   - Verify Noloco can connect to Supabase
   - Check that all tables are accessible

2. **CRUD Operations Test**:
   - Create, read, update, and delete records via Noloco
   - Verify changes are reflected in Supabase

3. **Business Logic Test**:
   - Create a new vendor invoice and verify markup calculation
   - Update site-partner markup % and verify related invoices update
   - Test other database functions through the Noloco interface

4. **Performance Testing**:
   - Test with realistic data volumes
   - Measure response times for common operations
   - Optimize queries and indexes as needed

## Conclusion

The integration of Noloco and Supabase provides a robust solution for the 10NetZero-FLRTS system, combining Noloco's user-friendly interface with Supabase's powerful PostgreSQL database capabilities. This approach gives you:

1. A professional web interface without complex coding
2. Robust database features including relationships, constraints, and business logic
3. Scalability for future growth
4. Flexibility to extend with custom API development

By following this guide, you should be able to successfully connect Noloco to your Supabase PostgreSQL database and configure it to provide a seamless user experience for the 10NetZero-FLRTS system.