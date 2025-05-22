# Appendix A: Supabase Database Schema Definition

Version: 1.0
Date: May 20, 2025

This document provides a detailed reference for the Supabase PostgreSQL database schema used by the 10NetZero-FLRTS system. The previous Noloco Tables structure has been migrated to a robust relational database model in Supabase PostgreSQL.

## Database Organization

The database is organized into several logical groups of tables:

1. **Master Data Tables**: Core business entities
2. **Relationship Tables**: Junction tables for many-to-many relationships
3. **Financial Tables**: Invoices, billings, and financial transactions
4. **Equipment Tables**: Physical assets and their management
5. **FLRTS Operational Tables**: Field reports, lists, tasks, and reminders
6. **Audit Tables**: Change tracking and notification logs

## Table Structure and Relationships

### Master Data Tables

#### sites

Primary table for operational locations.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| site_id_display | VARCHAR(50) | Human-readable ID (e.g., "S001") | NOT NULL, UNIQUE |
| site_name | VARCHAR(255) | Common name for the site | NOT NULL, UNIQUE |
| site_address_street | VARCHAR(255) | Street address | |
| site_address_city | VARCHAR(255) | City | |
| site_address_state | VARCHAR(255) | State/province | |
| site_address_zip | VARCHAR(50) | Postal/zip code | |
| site_latitude | DECIMAL(10,7) | Latitude in decimal degrees | |
| site_longitude | DECIMAL(10,7) | Longitude in decimal degrees | |
| site_status | VARCHAR(50) | Current operational status | CHECK (site_status IN ('Commissioning', 'Running', 'In Maintenance', 'Contracted', 'Planned', 'Decommissioned')) |
| operator_id | UUID | Reference to operators table | FK → operators(id) |
| sop_document_link | VARCHAR(1024) | URL to SOP document in Google Drive | |
| is_active | BOOLEAN | Whether record is currently active | DEFAULT TRUE |
| initial_site_setup_completed | BOOLEAN | Whether automated setup has run | DEFAULT FALSE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |
| full_site_address | TEXT | Concatenated address (generated) | GENERATED ALWAYS AS (...) STORED |

**Indexes**:
- idx_sites_site_name (site_name)
- idx_sites_location (site_latitude, site_longitude)

#### site_aliases

Alternative names for sites.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| site_id | UUID | Reference to sites table | NOT NULL, FK → sites(id) ON DELETE CASCADE |
| alias_name | VARCHAR(255) | Alternative name for the site | NOT NULL |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_site_aliases_name (alias_name)
- UNIQUE(site_id, alias_name)

#### partners

External partner organizations.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| partner_id_display | VARCHAR(50) | Human-readable ID (e.g., "P001") | NOT NULL, UNIQUE |
| partner_name | VARCHAR(255) | Name of the partner organization | NOT NULL, UNIQUE |
| partner_type | VARCHAR(50) | Category of partner | CHECK (partner_type IN ('Investor', 'Service Provider', 'Technology Provider', 'Community', 'Government', 'Other')) |
| primary_contact_name | VARCHAR(255) | Main contact person name | |
| primary_contact_email | VARCHAR(255) | Main contact email | |
| primary_contact_phone | VARCHAR(50) | Main contact phone number | |
| website | VARCHAR(1024) | Partner's website URL | |
| is_active | BOOLEAN | Whether record is currently active | DEFAULT TRUE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_partners_name (partner_name)

#### vendors

Supplier organizations.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| vendor_id_display | VARCHAR(50) | Human-readable ID (e.g., "V001") | NOT NULL, UNIQUE |
| vendor_name | VARCHAR(255) | Name of the vendor | NOT NULL, UNIQUE |
| vendor_category | VARCHAR(50) | Type of products/services provided | CHECK (vendor_category IN ('Hardware', 'Software', 'Consumables', 'Services', 'Logistics', 'Other')) |
| primary_contact_name | VARCHAR(255) | Main contact person name | |
| primary_contact_email | VARCHAR(255) | Main contact email | |
| primary_contact_phone | VARCHAR(50) | Main contact phone number | |
| website | VARCHAR(1024) | Vendor's website URL | |
| preferred_vendor | BOOLEAN | Whether vendor is preferred | DEFAULT FALSE |
| is_active | BOOLEAN | Whether record is currently active | DEFAULT TRUE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_vendors_name (vendor_name)

#### personnel

Employees and contractors.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| personnel_id_display | VARCHAR(50) | Human-readable ID (e.g., "P001") | NOT NULL, UNIQUE |
| first_name | VARCHAR(255) | First name | NOT NULL |
| last_name | VARCHAR(255) | Last name | NOT NULL |
| email | VARCHAR(255) | Email address | NOT NULL, UNIQUE |
| phone_number | VARCHAR(50) | Phone number | |
| job_title | VARCHAR(255) | Official role or title | |
| personnel_type | VARCHAR(50) | Category of personnel | NOT NULL, CHECK (personnel_type IN ('Employee', 'Contractor', 'Intern', 'Advisor')) |
| primary_site_id | UUID | Main site assignment | FK → sites(id) |
| is_active | BOOLEAN | Whether record is currently active | DEFAULT TRUE |
| emergency_contact_name | VARCHAR(255) | Emergency contact name | |
| emergency_contact_phone | VARCHAR(50) | Emergency contact phone | |
| profile_photo_url | VARCHAR(1024) | URL to profile photo | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |
| full_name | TEXT | Concatenated name (generated) | GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED |

**Indexes**:
- idx_personnel_email (email)
- idx_personnel_name (last_name, first_name)

#### operators

Entities operating sites.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| operator_id_display | VARCHAR(50) | Human-readable ID (e.g., "OP001") | NOT NULL, UNIQUE |
| operator_name | VARCHAR(255) | Name of the operating entity | NOT NULL, UNIQUE |
| operator_type | VARCHAR(50) | Type of operator | NOT NULL, CHECK (operator_type IN ('Internal (10NetZero)', 'Third-Party')) |
| primary_contact_name | VARCHAR(255) | Main contact person name | |
| primary_contact_email | VARCHAR(255) | Main contact email | |
| primary_contact_phone | VARCHAR(50) | Main contact phone number | |
| is_active | BOOLEAN | Whether record is currently active | DEFAULT TRUE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

#### flrts_users

System users with authentication.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| user_id_display | VARCHAR(50) | Human-readable ID (e.g., "U001") | NOT NULL, UNIQUE |
| personnel_id | UUID | Link to personnel record | NOT NULL, FK → personnel(id), UNIQUE |
| telegram_id | VARCHAR(255) | User's Telegram ID | |
| telegram_username | VARCHAR(255) | User's Telegram username | |
| noloco_user_email | VARCHAR(255) | Email for Noloco web app | |
| user_role_flrts | VARCHAR(50) | Role in the FLRTS system | NOT NULL, CHECK (user_role_flrts IN ('Administrator', 'Site Manager', 'Field Technician', 'View Only', 'Data Analyst')) |
| last_login_flrts | TIMESTAMPTZ | Last login timestamp | |
| is_active_flrts_user | BOOLEAN | Whether user account is active | DEFAULT TRUE |
| preferences_flrts | JSONB | User preferences (JSON) | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_flrts_users_telegram (telegram_id)

### Relationship Tables

#### site_partner_assignments

Junction table connecting sites to partners with markup percentages.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| assignment_id_display | VARCHAR(50) | Human-readable ID (e.g., "SPA001") | NOT NULL, UNIQUE |
| site_id | UUID | Reference to sites table | NOT NULL, FK → sites(id) ON DELETE CASCADE |
| partner_id | UUID | Reference to partners table | NOT NULL, FK → partners(id) ON DELETE CASCADE |
| role_of_partner_at_site | TEXT | Description of the relationship | |
| markup_percentage | DECIMAL(5,2) | Markup % for invoices | NOT NULL, DEFAULT 0 |
| assignment_active | BOOLEAN | Whether assignment is active | DEFAULT TRUE |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_site_partner_site (site_id)
- idx_site_partner_partner (partner_id)
- UNIQUE(site_id, partner_id)

#### site_vendor_assignments

Junction table connecting sites to vendors.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| assignment_id_display | VARCHAR(50) | Human-readable ID (e.g., "SVA001") | NOT NULL, UNIQUE |
| site_id | UUID | Reference to sites table | NOT NULL, FK → sites(id) ON DELETE CASCADE |
| vendor_id | UUID | Reference to vendors table | NOT NULL, FK → vendors(id) ON DELETE CASCADE |
| services_products_provided_at_site | TEXT | Description of provided services | |
| assignment_active | BOOLEAN | Whether assignment is active | DEFAULT TRUE |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_site_vendor_site (site_id)
- idx_site_vendor_vendor (vendor_id)
- UNIQUE(site_id, vendor_id)

### Financial Tables

#### vendor_invoices

Invoices from vendors.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| vendor_invoice_id_display | VARCHAR(50) | Human-readable ID (e.g., "VI001") | NOT NULL, UNIQUE |
| status | VARCHAR(50) | Current status of invoice | NOT NULL, CHECK (status IN ('Draft', 'Received', 'Processing', 'Approved', 'Paid', 'Rejected')) |
| vendor_id | UUID | Reference to vendors table | NOT NULL, FK → vendors(id) |
| site_id | UUID | Reference to sites table | NOT NULL, FK → sites(id) |
| invoice_date | DATE | Date of invoice | NOT NULL |
| invoice_number | VARCHAR(255) | Vendor's invoice number | |
| original_amount | DECIMAL(12,2) | Original invoice amount | NOT NULL |
| markup_percentage | DECIMAL(5,2) | Applied markup percentage | |
| markup_amount | DECIMAL(12,2) | Calculated markup amount | |
| final_amount | DECIMAL(12,2) | Total with markup | |
| partner_id | UUID | Reference to partners table | FK → partners(id) |
| attachment_url | VARCHAR(1024) | URL to invoice file | |
| due_date | DATE | Payment due date | |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_vendor_invoices_site (site_id)
- idx_vendor_invoices_vendor (vendor_id)
- idx_vendor_invoices_date (invoice_date)

#### partner_billings

Bills to partners.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| partner_billing_id_display | VARCHAR(50) | Human-readable ID (e.g., "PB001") | NOT NULL, UNIQUE |
| partner_id | UUID | Reference to partners table | NOT NULL, FK → partners(id) |
| vendor_invoice_id | UUID | Reference to vendor_invoices table | NOT NULL, FK → vendor_invoices(id), UNIQUE |
| billing_date | DATE | Date of billing | NOT NULL |
| status | VARCHAR(50) | Current status of billing | NOT NULL, CHECK (status IN ('Draft', 'Pending', 'Sent', 'Paid', 'Overdue', 'Disputed')) |
| original_amount | DECIMAL(12,2) | Original invoice amount | NOT NULL |
| markup_amount | DECIMAL(12,2) | Markup amount | NOT NULL |
| total_amount | DECIMAL(12,2) | Total billing amount | NOT NULL |
| payment_due_date | DATE | Date payment is due | |
| payment_date | DATE | Date payment was received | |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_partner_billings_partner (partner_id)
- idx_partner_billings_invoice (vendor_invoice_id)
- idx_partner_billings_date (billing_date)

### Equipment Tables

#### equipment

Non-ASIC hardware inventory.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| equipment_id_display | VARCHAR(50) | Human-readable ID (e.g., "EQ001") | NOT NULL, UNIQUE |
| equipment_name | VARCHAR(255) | Name/description of equipment | NOT NULL |
| equipment_type | VARCHAR(50) | Category of equipment | NOT NULL, CHECK (equipment_type IN ('Networking', 'Power Supply', 'Cooling', 'Security', 'Tools', 'Computing (Non-ASIC)', 'Safety Gear', 'Furniture', 'Other')) |
| site_location_id | UUID | Reference to sites table | FK → sites(id) |
| vendor_id | UUID | Reference to vendors table | FK → vendors(id) |
| date_purchased | DATE | Purchase date | |
| warranty_expiry_date | DATE | Warranty expiration | |
| serial_number | VARCHAR(255) | Manufacturer's serial number | |
| status | VARCHAR(50) | Current equipment status | CHECK (status IN ('Operational', 'In Repair', 'Awaiting Deployment', 'Retired', 'Missing')) |
| last_maintenance_date | DATE | Last maintenance date | |
| next_maintenance_date | DATE | Next scheduled maintenance | |
| purchase_price | DECIMAL(12,2) | Original purchase price | |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_equipment_site (site_location_id)
- idx_equipment_vendor (vendor_id)

#### asics

ASIC mining hardware inventory.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| asic_id_display | VARCHAR(50) | Human-readable ID (e.g., "ASIC001") | NOT NULL, UNIQUE |
| asic_name_model | VARCHAR(255) | Model name/number | NOT NULL |
| site_location_id | UUID | Reference to sites table | FK → sites(id) |
| vendor_id | UUID | Reference to vendors table | FK → vendors(id) |
| date_purchased | DATE | Purchase date | |
| warranty_expiry_date | DATE | Warranty expiration | |
| serial_number | VARCHAR(255) | Manufacturer's serial number | |
| mac_address | VARCHAR(255) | Network MAC address | |
| ip_address_static | VARCHAR(255) | Static IP address (if assigned) | |
| status | VARCHAR(50) | Current ASIC status | CHECK (status IN ('Operational/Mining', 'Idle', 'In Repair', 'Awaiting Deployment', 'Retired', 'Missing')) |
| nominal_hashrate_th | DECIMAL(12,2) | Rated hashrate in TH/s | |
| purchase_price | DECIMAL(12,2) | Original purchase price | |
| firmware_version | VARCHAR(255) | Current firmware version | |
| last_maintenance_date | DATE | Last maintenance date | |
| next_maintenance_date | DATE | Next scheduled maintenance | |
| notes | TEXT | Additional notes | |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_asics_site (site_location_id)
- idx_asics_vendor (vendor_id)

#### licenses_agreements

Contracts, permits, and legal documents.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| agreement_id_display | VARCHAR(50) | Human-readable ID (e.g., "LA001") | NOT NULL, UNIQUE |
| agreement_name | VARCHAR(255) | Name of the agreement | NOT NULL |
| agreement_type | VARCHAR(50) | Type of agreement | NOT NULL, CHECK (agreement_type IN ('Lease', 'Service Contract', 'License', 'Permit', 'NDA', 'Partnership Agreement', 'Insurance Policy', 'Other')) |
| counterparty_name | VARCHAR(255) | External party to agreement | |
| effective_date | DATE | Start date | |
| expiry_date | DATE | End date | |
| renewal_date | DATE | Date for renewal review | |
| status | VARCHAR(50) | Current status | CHECK (status IN ('Active', 'Expired', 'Terminated', 'Pending Signature', 'Under Review')) |
| key_terms_summary | TEXT | Summary of key terms | |
| document_link_external | VARCHAR(1024) | URL to document | |
| responsible_internal_user_id | UUID | User responsible for agreement | FK → flrts_users(id) |
| is_active | BOOLEAN | Whether agreement is active | DEFAULT TRUE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

Junction tables for licenses_agreements relationships:
- **licenses_agreements_sites**: For many-to-many relationship with sites
- **licenses_agreements_partners**: For many-to-many relationship with partners
- **licenses_agreements_vendors**: For many-to-many relationship with vendors

### FLRTS Operational Tables

#### field_reports

Observations and reports from field technicians.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| report_id_display | VARCHAR(50) | Human-readable ID (e.g., "FR001") | NOT NULL, UNIQUE |
| site_id | UUID | Reference to sites table | NOT NULL, FK → sites(id) |
| report_date | DATE | Date of report | NOT NULL |
| submitted_by_user_id | UUID | User who submitted report | NOT NULL, FK → flrts_users(id) |
| submission_timestamp | TIMESTAMPTZ | Submission time | NOT NULL, DEFAULT NOW() |
| report_type | VARCHAR(50) | Category of report | NOT NULL, CHECK (report_type IN ('Daily Operational Summary', 'Incident Report', 'Maintenance Log', 'Safety Observation', 'Equipment Check', 'Security Update', 'Visitor Log', 'Other')) |
| report_title_summary | VARCHAR(255) | Brief summary | NOT NULL |
| report_content_full | TEXT | Full report text | NOT NULL |
| report_status | VARCHAR(50) | Current status | NOT NULL, CHECK (report_status IN ('Draft', 'Submitted', 'Under Review', 'Actioned', 'Archived', 'Requires Follow-up')) |
| last_modified_timestamp | TIMESTAMPTZ | Last update time | DEFAULT NOW() |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_field_reports_site (site_id)
- idx_field_reports_date (report_date)
- idx_field_reports_status (report_status)

Junction tables for field_reports relationships:
- **field_reports_equipment**: For many-to-many relationship with equipment
- **field_reports_asics**: For many-to-many relationship with ASICs

#### field_report_edits

Audit trail of field report changes.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| parent_field_report_id | UUID | Reference to field_reports table | NOT NULL, FK → field_reports(id) ON DELETE CASCADE |
| author_user_id | UUID | User who made the edit | NOT NULL, FK → flrts_users(id) |
| edit_timestamp | TIMESTAMPTZ | Edit time | NOT NULL, DEFAULT NOW() |
| edit_text_full_version | TEXT | Full report content after edit | NOT NULL |
| edit_summary_user_provided | VARCHAR(255) | User's summary of changes | |
| version_number_calculated | INTEGER | Version number | NOT NULL |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |

**Indexes**:
- idx_field_report_edits_report (parent_field_report_id)

#### lists

Generic container for various operational lists.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| list_id_display | VARCHAR(50) | Human-readable ID (e.g., "LST001") | NOT NULL, UNIQUE |
| list_name | VARCHAR(255) | Name of the list | NOT NULL |
| list_type | VARCHAR(50) | Type of list | NOT NULL, CHECK (list_type IN ('Tools Inventory', 'Shopping List', 'Master Task List (Template)', 'Safety Checklist', 'Maintenance Procedure', 'Contact List', 'Other')) |
| site_id | UUID | Reference to sites table | FK → sites(id) |
| description | TEXT | Description of list purpose | |
| owner_user_id | UUID | User responsible for list | FK → flrts_users(id) |
| status | VARCHAR(50) | Current status of list | NOT NULL, CHECK (status IN ('Active', 'Archived', 'Draft', 'In Review')) |
| is_master_sop_list | BOOLEAN | Is this a SOP master list | DEFAULT FALSE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_lists_site (site_id)
- idx_lists_type (list_type)

#### list_items

Items within a list.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| list_item_id_display | VARCHAR(50) | Human-readable ID (e.g., "LI001") | NOT NULL, UNIQUE |
| parent_list_id | UUID | Reference to lists table | NOT NULL, FK → lists(id) ON DELETE CASCADE |
| item_name_primary_text | VARCHAR(255) | Main item text | NOT NULL |
| item_detail_1_text | VARCHAR(255) | Additional detail 1 | |
| item_detail_2_text | VARCHAR(255) | Additional detail 2 | |
| item_detail_3_longtext | TEXT | Long-form details | |
| item_detail_boolean_1 | BOOLEAN | Boolean flag | |
| item_detail_date_1 | DATE | Date field | |
| item_detail_user_link_1 | UUID | Reference to flrts_users table | FK → flrts_users(id) |
| item_order | INTEGER | Sort order within list | |
| is_complete_or_checked | BOOLEAN | Is item complete/checked | DEFAULT FALSE |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_list_items_list (parent_list_id)
- idx_list_items_completion (parent_list_id, is_complete_or_checked)

#### tasks

Actionable items with assignments.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| task_id_display | VARCHAR(50) | Human-readable ID (e.g., "TSK001") | NOT NULL, UNIQUE |
| task_title | VARCHAR(255) | Task title/description | NOT NULL |
| task_description_detailed | TEXT | Detailed description | |
| assigned_to_user_id | UUID | User task is assigned to | FK → flrts_users(id) |
| site_id | UUID | Reference to sites table | FK → sites(id) |
| related_field_report_id | UUID | Reference to field_reports table | FK → field_reports(id) |
| due_date | DATE | Task due date | |
| priority | VARCHAR(50) | Priority level | CHECK (priority IN ('High', 'Medium', 'Low')) |
| status | VARCHAR(50) | Current status | NOT NULL, CHECK (status IN ('To Do', 'In Progress', 'Completed', 'Blocked', 'Cancelled')), DEFAULT 'To Do' |
| completion_date | TIMESTAMPTZ | When task was completed | |
| todoist_task_id | VARCHAR(255) | ID in Todoist if synced | |
| parent_task_id | UUID | Reference to parent task | FK → tasks(id) |
| created_by_user_id | UUID | User who created the task | FK → flrts_users(id) |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_tasks_assigned (assigned_to_user_id)
- idx_tasks_site (site_id)
- idx_tasks_status (status)
- idx_tasks_due_date (due_date)
- idx_tasks_parent (parent_task_id)

#### reminders

Time-based notifications.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| reminder_id_display | VARCHAR(50) | Human-readable ID (e.g., "REM001") | NOT NULL, UNIQUE |
| reminder_title | VARCHAR(255) | Reminder description | NOT NULL |
| reminder_date_time | TIMESTAMPTZ | Date and time of reminder | NOT NULL |
| user_to_remind_id | UUID | User to be reminded | NOT NULL, FK → flrts_users(id) |
| related_task_id | UUID | Reference to tasks table | FK → tasks(id) |
| related_field_report_id | UUID | Reference to field_reports table | FK → field_reports(id) |
| related_site_id | UUID | Reference to sites table | FK → sites(id) |
| status | VARCHAR(50) | Current status | NOT NULL, CHECK (status IN ('Scheduled', 'Sent', 'Dismissed', 'Completed', 'Error')), DEFAULT 'Scheduled' |
| notification_channels | VARCHAR(255)[] | Array of channel names | |
| todoist_reminder_id | VARCHAR(255) | ID in Todoist if synced | |
| is_recurring | BOOLEAN | Is this a recurring reminder | DEFAULT FALSE |
| recurrence_rule | VARCHAR(255) | iCalendar-format recurrence | |
| created_by_user_id | UUID | User who created reminder | FK → flrts_users(id) |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | Last update timestamp | DEFAULT NOW() |

**Indexes**:
- idx_reminders_user (user_to_remind_id)
- idx_reminders_datetime (reminder_date_time)
- idx_reminders_status (status)

#### notifications_log

Records of notifications sent.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Primary key | PK, DEFAULT uuid_generate_v4() |
| timestamp_sent | TIMESTAMPTZ | When notification was sent | NOT NULL |
| recipient_user_id | UUID | User who received notification | NOT NULL, FK → flrts_users(id) |
| channel | VARCHAR(50) | Delivery channel | NOT NULL, CHECK (channel IN ('Telegram', 'Email', 'In-App (Noloco)', 'SMS', 'Other')) |
| notification_type | VARCHAR(50) | Type of notification | NOT NULL, CHECK (notification_type IN ('Task Reminder', 'New Task Assigned', 'Report Submitted', 'Report Actioned', 'System Alert', 'Mention', 'Scheduled Digest', 'Other')) |
| subject_or_title | VARCHAR(255) | Subject line or title | |
| message_content | TEXT | Full message content | NOT NULL |
| status | VARCHAR(50) | Delivery status | NOT NULL, CHECK (status IN ('Sent', 'Delivered', 'Failed', 'Read', 'Acknowledged')) |
| related_record_type | VARCHAR(50) | Type of related record | |
| related_record_id_display | VARCHAR(50) | Display ID of related record | |
| related_task_id | UUID | Reference to tasks table | FK → tasks(id) |
| related_field_report_id | UUID | Reference to field_reports table | FK → field_reports(id) |
| created_at | TIMESTAMPTZ | Creation timestamp | DEFAULT NOW() |

**Indexes**:
- idx_notifications_recipient (recipient_user_id)
- idx_notifications_timestamp (timestamp_sent)

## Database Views

The schema includes several predefined views for common queries:

1. **site_partner_view**: Shows sites and their associated partners with markup percentages
2. **vendor_invoice_summary**: Summary of vendor invoices with site, partner, and billing status
3. **site_financial_summary**: Aggregated financial data by site
4. **partner_financial_summary**: Aggregated financial data by partner
5. **active_tasks_by_site**: Active task counts and statuses by site
6. **outstanding_partner_billings**: Partner billings that need attention or follow-up

## Markup Manager Implementation

The Markup Manager business logic is implemented through PostgreSQL functions and triggers:

### Key Functions

1. **get_site_partner_markup(site_uuid, partner_uuid)**: Retrieves the markup percentage from the site-partner assignment
2. **calculate_invoice_markup(invoice_uuid)**: Calculates markup based on the site-partner relationship
3. **create_partner_billing(invoice_uuid)**: Creates or updates a partner billing record from an invoice
4. **recalculate_all_markups()**: Utility function to recalculate all markups (useful during migrations)
5. **get_partner_financial_summary(partner_uuid)**: Returns financial metrics for a specific partner
6. **get_site_financial_summary(site_uuid)**: Returns financial metrics for a specific site

### Key Triggers

1. **after_vendor_invoice_insert**: Automatically processes new vendor invoices
2. **after_vendor_invoice_update**: Updates markup calculations when an invoice changes
3. **after_site_partner_assignment_update**: Updates related invoices when markup percentages change

## Security Implementation

Row-Level Security (RLS) is implemented with policies for key tables:

### Application Roles

1. **app_admin**: Full access to all tables
2. **app_site_manager**: Full access to sites they manage, view access to others
3. **app_field_technician**: Create/read access to records for their assigned sites
4. **app_finance**: Full access to financial tables, view access to others
5. **app_viewer**: Read-only access to most tables

Example policies control access based on user roles, site assignments, and record ownership.

## Audit and Change Tracking

1. **field_report_edits**: Tracks all changes to field reports
2. **markup_changes_log**: Records changes to markup percentages
3. **timestamps**: All tables include created_at and updated_at fields