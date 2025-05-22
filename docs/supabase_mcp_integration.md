# Supabase MCP Integration Plan

Version: 1.0
Date: May 20, 2025

This document outlines the implementation plan for integrating Supabase with the Model Context Protocol (MCP) for the 10NetZero-FLRTS system.

## 1. Overview

The Model Context Protocol (MCP) provides a standardized way for AI models to interact with external services. Implementing a Supabase MCP will allow AI tools like Claude to directly interact with the 10NetZero-FLRTS database, providing capabilities for data retrieval, analysis, and updates.

## 2. Benefits of Supabase MCP Integration

1. **Direct Database Access**: Allow AI to query and manipulate data directly in Supabase
2. **Secure Interactions**: Implement proper authentication and authorization for all database operations
3. **Structured Data Exchange**: Standardize data formats for AI communication
4. **Complex Operations**: Enable AI to perform complex database operations that might be difficult with other interfaces
5. **Real-time Analysis**: Support for ad-hoc data analysis and reporting

## 3. MCP Architecture

The Supabase MCP will consist of the following components:

```
┌─────────────┐      ┌───────────────┐      ┌─────────────────┐
│             │      │               │      │                 │
│  AI Model   │─────▶│   MCP Server  │─────▶│    Supabase     │
│  (Claude)   │      │               │      │   PostgreSQL    │
│             │      │               │      │                 │
└─────────────┘      └───────────────┘      └─────────────────┘
                            ▲
                            │
                     ┌──────┴──────┐
                     │             │
                     │  MCP Auth   │
                     │  Service    │
                     │             │
                     └─────────────┘
```

### 3.1 Components

1. **MCP Server**: A REST API server that implements the MCP specification
2. **MCP Auth Service**: Handles authentication and authorization for MCP requests
3. **Supabase Client**: Connects to Supabase and executes database operations
4. **MCP Schemas**: Defines the data structures and operations available to AI models

## 4. Core MCP Functionalities

### 4.1 Basic CRUD Operations

1. **Create Operations**:
   - Create new site
   - Create new partner
   - Create new vendor
   - Create new vendor invoice
   - Create new field report

2. **Read Operations**:
   - Get site details
   - List sites with filtering options
   - Get partner details
   - List partners with filtering options
   - Get vendor invoice details
   - List vendor invoices with filtering options
   - Get field report details
   - List field reports with filtering options

3. **Update Operations**:
   - Update site information
   - Update partner information
   - Update vendor information
   - Update vendor invoice status
   - Update field report content

4. **Delete Operations**:
   - Archive/deactivate site
   - Archive/deactivate partner
   - Archive/deactivate vendor
   - Delete draft vendor invoice
   - Archive field report

### 4.2 Advanced Operations

1. **Financial Operations**:
   - Calculate site financial summary
   - Generate partner financial report
   - Recalculate invoice markups
   - Update site-partner markup percentage

2. **Reporting Operations**:
   - Generate site status report
   - Generate open tasks report
   - Generate outstanding invoices report
   - Generate partner billing status report

3. **Search Operations**:
   - Full-text search across field reports
   - Search sites by location
   - Search for invoices by criteria
   - Search for tasks by status and assignee

## 5. MCP Implementation Steps

### 5.1 Setup and Configuration

1. **Install MCP Controller**:
   ```bash
   npm install @anthropic-ai/mcp-controller
   ```

2. **Configure MCP Environment**:
   - Set up authentication keys
   - Configure controller settings

3. **Create Supabase MCP Configuration**:
   ```json
   {
     "name": "supabase",
     "displayName": "Supabase Database",
     "version": "1.0.0",
     "description": "Access and manipulate data in the 10NetZero-FLRTS Supabase database",
     "authentication": {
       "type": "apiKey",
       "keyName": "SUPABASE_SERVICE_KEY"
     },
     "schemas": {
       "site": {...},
       "partner": {...},
       "vendor": {...},
       "vendorInvoice": {...},
       "fieldReport": {...},
       ...
     }
   }
   ```

### 5.2 Implement Core API Handlers

1. **Site Handlers**:
   ```javascript
   // Example handler for getSite
   async function getSite(ctx) {
     const { siteId } = ctx.params;
     const { data, error } = await supabase
       .from('sites')
       .select('*')
       .eq('id', siteId)
       .single();
     
     if (error) throw new Error(error.message);
     return data;
   }
   ```

2. **Partner Handlers**:
   ```javascript
   // Example handler for listPartners
   async function listPartners(ctx) {
     const { limit, offset, isActive } = ctx.params;
     
     let query = supabase
       .from('partners')
       .select('*');
     
     if (isActive !== undefined) {
       query = query.eq('is_active', isActive);
     }
     
     const { data, error } = await query
       .limit(limit || 50)
       .offset(offset || 0);
     
     if (error) throw new Error(error.message);
     return data;
   }
   ```

3. **Vendor Invoice Handlers**:
   ```javascript
   // Example handler for createVendorInvoice
   async function createVendorInvoice(ctx) {
     const { 
       vendor_id, 
       site_id, 
       invoice_date, 
       original_amount,
       status,
       invoice_number,
       due_date
     } = ctx.params;
     
     // Generate display ID
     const displayId = await generateDisplayId('VI');
     
     const { data, error } = await supabase
       .from('vendor_invoices')
       .insert({
         vendor_invoice_id_display: displayId,
         vendor_id,
         site_id,
         invoice_date,
         original_amount,
         status: status || 'Draft',
         invoice_number,
         due_date
       })
       .select()
       .single();
     
     if (error) throw new Error(error.message);
     return data;
   }
   ```

### 5.3 Implement Advanced Functions

1. **Financial Reports**:
   ```javascript
   // Example handler for getSiteFinancialSummary
   async function getSiteFinancialSummary(ctx) {
     const { siteId } = ctx.params;
     
     // Call the PostgreSQL function
     const { data, error } = await supabase
       .rpc('get_site_financial_summary', { site_uuid: siteId });
     
     if (error) throw new Error(error.message);
     return data;
   }
   ```

2. **Search Functionality**:
   ```javascript
   // Example handler for searchFieldReports
   async function searchFieldReports(ctx) {
     const { query, siteId, limit, offset } = ctx.params;
     
     let dbQuery = supabase
       .from('field_reports')
       .select('*')
       .textSearch('report_content_full', query, {
         type: 'websearch'
       });
     
     if (siteId) {
       dbQuery = dbQuery.eq('site_id', siteId);
     }
     
     const { data, error } = await dbQuery
       .limit(limit || 20)
       .offset(offset || 0);
     
     if (error) throw new Error(error.message);
     return data;
   }
   ```

## 6. Security Implementation

### 6.1 Authentication

1. **API Key Authentication**:
   - Use service role API key for MCP server
   - Implement secure key rotation and storage

2. **Request Verification**:
   - Verify all incoming requests with MCP controller signatures
   - Implement rate limiting and request throttling

### 6.2 Authorization

1. **Row Level Security (RLS)**:
   - Apply RLS policies for MCP access
   - Create a specific database role for MCP operations

2. **Function Permissions**:
   - Restrict access to sensitive database functions
   - Implement audit logging for all operations

### 6.3 Data Protection

1. **Input Validation**:
   - Sanitize all inputs to prevent SQL injection
   - Implement schema validation for all parameters

2. **Output Filtering**:
   - Exclude sensitive fields from responses
   - Apply data masking for certain fields (e.g., contract details)

## 7. Example MCP Calls

### 7.1 Basic Site Retrieval

```javascript
// MCP call to get a site by ID
const result = await claude.invokeFunction("mcp__supabase__getSite", {
  siteId: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
});

console.log(result);
// {
//   "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "site_id_display": "S001",
//   "site_name": "Eagle Lake",
//   "site_address_street": "123 Main St",
//   "site_address_city": "Austin",
//   "site_address_state": "TX",
//   "site_address_zip": "78701",
//   "site_latitude": 30.2672,
//   "site_longitude": -97.7431,
//   "site_status": "Running",
//   ...
// }
```

### 7.2 Create Vendor Invoice

```javascript
// MCP call to create a vendor invoice
const newInvoice = await claude.invokeFunction("mcp__supabase__createVendorInvoice", {
  vendor_id: "7b73f91e-6c8d-4921-b15e-98e937f7727c",
  site_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  invoice_date: "2025-05-20",
  original_amount: 1250.75,
  invoice_number: "INV-2025-05432",
  due_date: "2025-06-19",
  status: "Received"
});

console.log(newInvoice);
// {
//   "id": "a5d8f9e7-c6b5-4e3a-b2d1-f5c4e3b2a1d0",
//   "vendor_invoice_id_display": "VI054",
//   "vendor_id": "7b73f91e-6c8d-4921-b15e-98e937f7727c",
//   "site_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "invoice_date": "2025-05-20",
//   "original_amount": 1250.75,
//   "markup_percentage": 10.00,
//   "markup_amount": 125.08,
//   "final_amount": 1375.83,
//   ...
// }
```

### 7.3 Search Field Reports

```javascript
// MCP call to search field reports
const reports = await claude.invokeFunction("mcp__supabase__searchFieldReports", {
  query: "generator maintenance issue",
  siteId: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  limit: 5
});

console.log(reports);
// [
//   {
//     "id": "b3a2c1d0-e5f4-4a3b-9c8d-7e6f5d4c3b2a",
//     "report_id_display": "FR042",
//     "site_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//     "report_date": "2025-05-15",
//     "report_title_summary": "Generator 3 Maintenance Required",
//     "report_content_full": "During routine inspection, found Generator 3 showing signs of...",
//     ...
//   },
//   ...
// ]
```

## 8. Testing and Validation

### 8.1 Unit Testing

1. Test each MCP function individually
2. Verify proper error handling
3. Test with various input parameters

### 8.2 Integration Testing

1. Test MCP with the actual Supabase database
2. Verify data integrity after operations
3. Test security measures and authentication

### 8.3 Performance Testing

1. Measure response times for various operations
2. Test with realistic data volumes
3. Optimize query performance as needed

## 9. Deployment and Rollout

### 9.1 Development Environment

1. Set up development MCP server
2. Connect to development Supabase instance
3. Implement and test initial functions

### 9.2 Staging Environment

1. Deploy to staging environment
2. Conduct thorough testing with production-like data
3. Implement monitoring and logging

### 9.3 Production Deployment

1. Deploy to production environment
2. Implement gradual rollout of MCP functions
3. Monitor performance and security

## 10. Documentation and Support

### 10.1 Function Documentation

Provide detailed documentation for each MCP function:

```javascript
/**
 * Get site details by ID
 * 
 * @param {Object} params - Function parameters
 * @param {string} params.siteId - UUID of the site to retrieve
 * @returns {Object} Site record with all fields
 * @throws {Error} If site not found or on database error
 */
function getSite(params) {
  // Implementation
}
```

### 10.2 Usage Examples

Provide sample code for common operations:

```javascript
// Example: Retrieving a site and its related partner assignments
async function getSiteWithPartners() {
  // Get site details
  const site = await claude.invokeFunction("mcp__supabase__getSite", {
    siteId: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  });
  
  // Get partner assignments for this site
  const partnerAssignments = await claude.invokeFunction("mcp__supabase__listSitePartnerAssignments", {
    siteId: site.id
  });
  
  return {
    site,
    partnerAssignments
  };
}
```

## 11. Conclusion

The Supabase MCP integration will provide powerful data access and manipulation capabilities for the 10NetZero-FLRTS system. By implementing a robust MCP with proper security measures, you'll enable AI-powered workflows that can significantly enhance productivity and insight generation.

The implementation should be approached in phases, starting with the core CRUD operations and gradually adding more advanced functionality. With proper testing and documentation, the Supabase MCP will become a valuable tool for interacting with your data.