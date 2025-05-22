-- ==========================================
-- 10NetZero-FLRTS: Supabase Database Schema
-- ==========================================
-- Version: 1.0
-- Date: May 21, 2025
-- Description: Full database schema implementation for the 10NetZero-FLRTS system

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- MASTER DATA TABLES
-- ==========================================

-- Create operators table first (needed for foreign key in sites)
CREATE TABLE IF NOT EXISTS operators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operator_id_display VARCHAR(50) NOT NULL UNIQUE,
    operator_name VARCHAR(255) NOT NULL UNIQUE,
    operator_type VARCHAR(50) NOT NULL CHECK (operator_type IN ('Internal (10NetZero)', 'Third-Party')),
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create sites table
CREATE TABLE IF NOT EXISTS sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_name VARCHAR(255) NOT NULL UNIQUE,
    site_address_street VARCHAR(255),
    site_address_city VARCHAR(255),
    site_address_state VARCHAR(255),
    site_address_zip VARCHAR(50),
    site_latitude DECIMAL(10,7),
    site_longitude DECIMAL(10,7),
    site_status VARCHAR(50) CHECK (site_status IN ('Commissioning', 'Running', 'In Maintenance', 'Contracted', 'Planned', 'Decommissioned')),
    operator_id UUID REFERENCES operators(id),
    sop_document_link VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    initial_site_setup_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add generated column for full address
ALTER TABLE sites 
ADD COLUMN IF NOT EXISTS full_site_address TEXT GENERATED ALWAYS AS (
    COALESCE(site_address_street, '') || 
    CASE WHEN site_address_street IS NOT NULL AND site_address_city IS NOT NULL THEN ', ' ELSE '' END ||
    COALESCE(site_address_city, '') || 
    CASE WHEN site_address_city IS NOT NULL AND site_address_state IS NOT NULL THEN ', ' ELSE '' END ||
    COALESCE(site_address_state, '') ||
    CASE WHEN site_address_state IS NOT NULL AND site_address_zip IS NOT NULL THEN ' ' ELSE '' END ||
    COALESCE(site_address_zip, '')
) STORED;

-- Create site_aliases table
CREATE TABLE IF NOT EXISTS site_aliases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    alias_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(site_id, alias_name)
);

-- Create partners table
CREATE TABLE IF NOT EXISTS partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id_display VARCHAR(50) NOT NULL UNIQUE,
    partner_name VARCHAR(255) NOT NULL UNIQUE,
    partner_type VARCHAR(50) CHECK (partner_type IN ('Investor', 'Service Provider', 'Technology Provider', 'Community', 'Government', 'Other')),
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(50),
    website VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create vendors table
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id_display VARCHAR(50) NOT NULL UNIQUE,
    vendor_name VARCHAR(255) NOT NULL UNIQUE,
    vendor_category VARCHAR(50) CHECK (vendor_category IN ('Hardware', 'Software', 'Consumables', 'Services', 'Logistics', 'Other')),
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(50),
    website VARCHAR(1024),
    preferred_vendor BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create personnel table
CREATE TABLE IF NOT EXISTS personnel (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    personnel_id_display VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(50),
    job_title VARCHAR(255),
    personnel_type VARCHAR(50) NOT NULL CHECK (personnel_type IN ('Employee', 'Contractor', 'Intern', 'Advisor')),
    primary_site_id UUID REFERENCES sites(id),
    is_active BOOLEAN DEFAULT TRUE,
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(50),
    profile_photo_url VARCHAR(1024),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    full_name TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED
);

-- Create flrts_users table
CREATE TABLE IF NOT EXISTS flrts_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id_display VARCHAR(50) NOT NULL UNIQUE,
    personnel_id UUID NOT NULL REFERENCES personnel(id) UNIQUE,
    telegram_id VARCHAR(255),
    telegram_username VARCHAR(255),
    noloco_user_email VARCHAR(255),
    user_role_flrts VARCHAR(50) NOT NULL CHECK (user_role_flrts IN ('Administrator', 'Site Manager', 'Field Technician', 'View Only', 'Data Analyst')),
    last_login_flrts TIMESTAMPTZ,
    is_active_flrts_user BOOLEAN DEFAULT TRUE,
    preferences_flrts JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- RELATIONSHIP TABLES
-- ==========================================

-- Create site_partner_assignments table
CREATE TABLE IF NOT EXISTS site_partner_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    role_of_partner_at_site TEXT,
    markup_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    assignment_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(site_id, partner_id)
);

-- Create site_vendor_assignments table
CREATE TABLE IF NOT EXISTS site_vendor_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    services_products_provided_at_site TEXT,
    assignment_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(site_id, vendor_id)
);

-- ==========================================
-- FINANCIAL TABLES
-- ==========================================

-- Create vendor_invoices table
CREATE TABLE IF NOT EXISTS vendor_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_invoice_id_display VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Draft', 'Received', 'Processing', 'Approved', 'Paid', 'Rejected')),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    site_id UUID NOT NULL REFERENCES sites(id),
    invoice_date DATE NOT NULL,
    invoice_number VARCHAR(255),
    original_amount DECIMAL(12,2) NOT NULL,
    markup_percentage DECIMAL(5,2),
    markup_amount DECIMAL(12,2),
    final_amount DECIMAL(12,2),
    partner_id UUID REFERENCES partners(id),
    attachment_url VARCHAR(1024),
    due_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create partner_billings table
CREATE TABLE IF NOT EXISTS partner_billings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_billing_id_display VARCHAR(50) NOT NULL UNIQUE,
    partner_id UUID NOT NULL REFERENCES partners(id),
    vendor_invoice_id UUID NOT NULL REFERENCES vendor_invoices(id) UNIQUE,
    billing_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Draft', 'Pending', 'Sent', 'Paid', 'Overdue', 'Disputed')),
    original_amount DECIMAL(12,2) NOT NULL,
    markup_amount DECIMAL(12,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_due_date DATE,
    payment_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- EQUIPMENT TABLES
-- ==========================================

-- Create equipment table
CREATE TABLE IF NOT EXISTS equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id_display VARCHAR(50) NOT NULL UNIQUE,
    equipment_name VARCHAR(255) NOT NULL,
    equipment_type VARCHAR(50) NOT NULL CHECK (equipment_type IN ('Networking', 'Power Supply', 'Cooling', 'Security', 'Tools', 'Computing (Non-ASIC)', 'Safety Gear', 'Furniture', 'Other')),
    site_location_id UUID REFERENCES sites(id),
    vendor_id UUID REFERENCES vendors(id),
    date_purchased DATE,
    warranty_expiry_date DATE,
    serial_number VARCHAR(255),
    status VARCHAR(50) CHECK (status IN ('Operational', 'In Repair', 'Awaiting Deployment', 'Retired', 'Missing')),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    purchase_price DECIMAL(12,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create asics table
CREATE TABLE IF NOT EXISTS asics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asic_id_display VARCHAR(50) NOT NULL UNIQUE,
    asic_name_model VARCHAR(255) NOT NULL,
    site_location_id UUID REFERENCES sites(id),
    vendor_id UUID REFERENCES vendors(id),
    date_purchased DATE,
    warranty_expiry_date DATE,
    serial_number VARCHAR(255),
    mac_address VARCHAR(255),
    ip_address_static VARCHAR(255),
    status VARCHAR(50) CHECK (status IN ('Operational/Mining', 'Idle', 'In Repair', 'Awaiting Deployment', 'Retired', 'Missing')),
    nominal_hashrate_th DECIMAL(12,2),
    purchase_price DECIMAL(12,2),
    firmware_version VARCHAR(255),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create licenses_agreements table
CREATE TABLE IF NOT EXISTS licenses_agreements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agreement_id_display VARCHAR(50) NOT NULL UNIQUE,
    agreement_name VARCHAR(255) NOT NULL,
    agreement_type VARCHAR(50) NOT NULL CHECK (agreement_type IN ('Lease', 'Service Contract', 'License', 'Permit', 'NDA', 'Partnership Agreement', 'Insurance Policy', 'Other')),
    counterparty_name VARCHAR(255),
    effective_date DATE,
    expiry_date DATE,
    renewal_date DATE,
    status VARCHAR(50) CHECK (status IN ('Active', 'Expired', 'Terminated', 'Pending Signature', 'Under Review')),
    key_terms_summary TEXT,
    document_link_external VARCHAR(1024),
    responsible_internal_user_id UUID REFERENCES flrts_users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create licenses_agreements junction tables
CREATE TABLE IF NOT EXISTS licenses_agreements_sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(license_agreement_id, site_id)
);

CREATE TABLE IF NOT EXISTS licenses_agreements_partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(license_agreement_id, partner_id)
);

CREATE TABLE IF NOT EXISTS licenses_agreements_vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(license_agreement_id, vendor_id)
);

-- ==========================================
-- FLRTS OPERATIONAL TABLES
-- ==========================================

-- Create field_reports table
CREATE TABLE IF NOT EXISTS field_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_id UUID NOT NULL REFERENCES sites(id),
    report_date DATE NOT NULL,
    submitted_by_user_id UUID NOT NULL REFERENCES flrts_users(id),
    submission_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    report_type VARCHAR(50) NOT NULL CHECK (report_type IN ('Daily Operational Summary', 'Incident Report', 'Maintenance Log', 'Safety Observation', 'Equipment Check', 'Security Update', 'Visitor Log', 'Other')),
    report_title_summary VARCHAR(255) NOT NULL,
    report_content_full TEXT NOT NULL,
    report_status VARCHAR(50) NOT NULL CHECK (report_status IN ('Draft', 'Submitted', 'Under Review', 'Actioned', 'Archived', 'Requires Follow-up')),
    last_modified_timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create field_report_edits table
CREATE TABLE IF NOT EXISTS field_report_edits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_field_report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    author_user_id UUID NOT NULL REFERENCES flrts_users(id),
    edit_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    edit_text_full_version TEXT NOT NULL,
    edit_summary_user_provided VARCHAR(255),
    version_number_calculated INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create field reports junction tables
CREATE TABLE IF NOT EXISTS field_reports_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    field_report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(field_report_id, equipment_id)
);

CREATE TABLE IF NOT EXISTS field_reports_asics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    field_report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    asic_id UUID NOT NULL REFERENCES asics(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(field_report_id, asic_id)
);

-- Create lists table
CREATE TABLE IF NOT EXISTS lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    list_id_display VARCHAR(50) NOT NULL UNIQUE,
    list_name VARCHAR(255) NOT NULL,
    list_type VARCHAR(50) NOT NULL CHECK (list_type IN ('Tools Inventory', 'Shopping List', 'Master Task List (Template)', 'Safety Checklist', 'Maintenance Procedure', 'Contact List', 'Other')),
    site_id UUID REFERENCES sites(id),
    description TEXT,
    owner_user_id UUID REFERENCES flrts_users(id),
    status VARCHAR(50) NOT NULL CHECK (status IN ('Active', 'Archived', 'Draft', 'In Review')),
    is_master_sop_list BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create list_items table
CREATE TABLE IF NOT EXISTS list_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    list_item_id_display VARCHAR(50) NOT NULL UNIQUE,
    parent_list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    item_name_primary_text VARCHAR(255) NOT NULL,
    item_detail_1_text VARCHAR(255),
    item_detail_2_text VARCHAR(255),
    item_detail_3_longtext TEXT,
    item_detail_boolean_1 BOOLEAN,
    item_detail_date_1 DATE,
    item_detail_user_link_1 UUID REFERENCES flrts_users(id),
    item_order INTEGER,
    is_complete_or_checked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id_display VARCHAR(50) NOT NULL UNIQUE,
    task_title VARCHAR(255) NOT NULL,
    task_description_detailed TEXT,
    assigned_to_user_id UUID REFERENCES flrts_users(id),
    site_id UUID REFERENCES sites(id),
    related_field_report_id UUID REFERENCES field_reports(id),
    due_date DATE,
    priority VARCHAR(50) CHECK (priority IN ('High', 'Medium', 'Low')),
    status VARCHAR(50) NOT NULL CHECK (status IN ('To Do', 'In Progress', 'Completed', 'Blocked', 'Cancelled')) DEFAULT 'To Do',
    completion_date TIMESTAMPTZ,
    todoist_task_id VARCHAR(255),
    parent_task_id UUID REFERENCES tasks(id),
    created_by_user_id UUID REFERENCES flrts_users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create reminders table
CREATE TABLE IF NOT EXISTS reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reminder_id_display VARCHAR(50) NOT NULL UNIQUE,
    reminder_title VARCHAR(255) NOT NULL,
    reminder_date_time TIMESTAMPTZ NOT NULL,
    user_to_remind_id UUID NOT NULL REFERENCES flrts_users(id),
    related_task_id UUID REFERENCES tasks(id),
    related_field_report_id UUID REFERENCES field_reports(id),
    related_site_id UUID REFERENCES sites(id),
    status VARCHAR(50) NOT NULL CHECK (status IN ('Scheduled', 'Sent', 'Dismissed', 'Completed', 'Error')) DEFAULT 'Scheduled',
    notification_channels VARCHAR(255)[],
    todoist_reminder_id VARCHAR(255),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule VARCHAR(255),
    created_by_user_id UUID REFERENCES flrts_users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create notifications_log table
CREATE TABLE IF NOT EXISTS notifications_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp_sent TIMESTAMPTZ NOT NULL,
    recipient_user_id UUID NOT NULL REFERENCES flrts_users(id),
    channel VARCHAR(50) NOT NULL CHECK (channel IN ('Telegram', 'Email', 'In-App (Noloco)', 'SMS', 'Other')),
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN ('Task Reminder', 'New Task Assigned', 'Report Submitted', 'Report Actioned', 'System Alert', 'Mention', 'Scheduled Digest', 'Other')),
    subject_or_title VARCHAR(255),
    message_content TEXT NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Sent', 'Delivered', 'Failed', 'Read', 'Acknowledged')),
    related_record_type VARCHAR(50),
    related_record_id_display VARCHAR(50),
    related_task_id UUID REFERENCES tasks(id),
    related_field_report_id UUID REFERENCES field_reports(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create audit table for markup changes
CREATE TABLE IF NOT EXISTS markup_changes_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id),
    partner_id UUID NOT NULL REFERENCES partners(id),
    old_markup_percentage DECIMAL(5,2),
    new_markup_percentage DECIMAL(5,2),
    changed_by UUID,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- INDEXES
-- ==========================================

-- Add indexes for sites table
CREATE INDEX IF NOT EXISTS idx_sites_site_name ON sites(site_name);
CREATE INDEX IF NOT EXISTS idx_sites_location ON sites(site_latitude, site_longitude);
CREATE INDEX IF NOT EXISTS idx_sites_status ON sites(site_status);

-- Add indexes for site_aliases table
CREATE INDEX IF NOT EXISTS idx_site_aliases_name ON site_aliases(alias_name);

-- Add indexes for partners table
CREATE INDEX IF NOT EXISTS idx_partners_name ON partners(partner_name);
CREATE INDEX IF NOT EXISTS idx_partners_type ON partners(partner_type);

-- Add indexes for vendors table
CREATE INDEX IF NOT EXISTS idx_vendors_name ON vendors(vendor_name);
CREATE INDEX IF NOT EXISTS idx_vendors_category ON vendors(vendor_category);

-- Add indexes for personnel table
CREATE INDEX IF NOT EXISTS idx_personnel_email ON personnel(email);
CREATE INDEX IF NOT EXISTS idx_personnel_name ON personnel(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_personnel_site ON personnel(primary_site_id);

-- Add indexes for flrts_users table
CREATE INDEX IF NOT EXISTS idx_flrts_users_telegram ON flrts_users(telegram_id);
CREATE INDEX IF NOT EXISTS idx_flrts_users_role ON flrts_users(user_role_flrts);

-- Add indexes for site_partner_assignments table
CREATE INDEX IF NOT EXISTS idx_site_partner_site ON site_partner_assignments(site_id);
CREATE INDEX IF NOT EXISTS idx_site_partner_partner ON site_partner_assignments(partner_id);

-- Add indexes for site_vendor_assignments table
CREATE INDEX IF NOT EXISTS idx_site_vendor_site ON site_vendor_assignments(site_id);
CREATE INDEX IF NOT EXISTS idx_site_vendor_vendor ON site_vendor_assignments(vendor_id);

-- Add indexes for vendor_invoices table
CREATE INDEX IF NOT EXISTS idx_vendor_invoices_site ON vendor_invoices(site_id);
CREATE INDEX IF NOT EXISTS idx_vendor_invoices_vendor ON vendor_invoices(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_invoices_date ON vendor_invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_vendor_invoices_status ON vendor_invoices(status);
CREATE INDEX IF NOT EXISTS idx_vendor_invoices_partner ON vendor_invoices(partner_id);

-- Add indexes for partner_billings table
CREATE INDEX IF NOT EXISTS idx_partner_billings_partner ON partner_billings(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_billings_invoice ON partner_billings(vendor_invoice_id);
CREATE INDEX IF NOT EXISTS idx_partner_billings_date ON partner_billings(billing_date);
CREATE INDEX IF NOT EXISTS idx_partner_billings_status ON partner_billings(status);

-- Add indexes for equipment table
CREATE INDEX IF NOT EXISTS idx_equipment_site ON equipment(site_location_id);
CREATE INDEX IF NOT EXISTS idx_equipment_vendor ON equipment(vendor_id);
CREATE INDEX IF NOT EXISTS idx_equipment_status ON equipment(status);

-- Add indexes for asics table
CREATE INDEX IF NOT EXISTS idx_asics_site ON asics(site_location_id);
CREATE INDEX IF NOT EXISTS idx_asics_vendor ON asics(vendor_id);
CREATE INDEX IF NOT EXISTS idx_asics_status ON asics(status);

-- Add indexes for field_reports table
CREATE INDEX IF NOT EXISTS idx_field_reports_site ON field_reports(site_id);
CREATE INDEX IF NOT EXISTS idx_field_reports_date ON field_reports(report_date);
CREATE INDEX IF NOT EXISTS idx_field_reports_status ON field_reports(report_status);
CREATE INDEX IF NOT EXISTS idx_field_reports_type ON field_reports(report_type);
CREATE INDEX IF NOT EXISTS idx_field_reports_user ON field_reports(submitted_by_user_id);

-- Add indexes for field_report_edits table
CREATE INDEX IF NOT EXISTS idx_field_report_edits_report ON field_report_edits(parent_field_report_id);
CREATE INDEX IF NOT EXISTS idx_field_report_edits_author ON field_report_edits(author_user_id);

-- Add indexes for lists table
CREATE INDEX IF NOT EXISTS idx_lists_site ON lists(site_id);
CREATE INDEX IF NOT EXISTS idx_lists_type ON lists(list_type);
CREATE INDEX IF NOT EXISTS idx_lists_owner ON lists(owner_user_id);

-- Add indexes for list_items table
CREATE INDEX IF NOT EXISTS idx_list_items_list ON list_items(parent_list_id);
CREATE INDEX IF NOT EXISTS idx_list_items_completion ON list_items(parent_list_id, is_complete_or_checked);

-- Add indexes for tasks table
CREATE INDEX IF NOT EXISTS idx_tasks_assigned ON tasks(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_site ON tasks(site_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_task_id);
CREATE INDEX IF NOT EXISTS idx_tasks_created ON tasks(created_by_user_id);

-- Add indexes for reminders table
CREATE INDEX IF NOT EXISTS idx_reminders_user ON reminders(user_to_remind_id);
CREATE INDEX IF NOT EXISTS idx_reminders_datetime ON reminders(reminder_date_time);
CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders(status);
CREATE INDEX IF NOT EXISTS idx_reminders_task ON reminders(related_task_id);
CREATE INDEX IF NOT EXISTS idx_reminders_site ON reminders(related_site_id);

-- Add indexes for notifications_log table
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications_log(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_timestamp ON notifications_log(timestamp_sent);
CREATE INDEX IF NOT EXISTS idx_notifications_channel ON notifications_log(channel);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications_log(notification_type);
