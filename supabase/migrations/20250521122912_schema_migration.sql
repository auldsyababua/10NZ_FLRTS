-- 10NetZero-FLRTS Supabase PostgreSQL Schema
-- Version: 1.0
-- Date: May 20, 2025

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- MASTER DATA TABLES
-- ===========================================

-- Sites table
CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_name VARCHAR(255) NOT NULL UNIQUE,
    site_address_street VARCHAR(255),
    site_address_city VARCHAR(255),
    site_address_state VARCHAR(255),
    site_address_zip VARCHAR(50),
    site_latitude DECIMAL(10, 7),
    site_longitude DECIMAL(10, 7),
    site_status VARCHAR(50) CHECK (site_status IN ('Commissioning', 'Running', 'In Maintenance', 'Contracted', 'Planned', 'Decommissioned')),
    operator_id UUID REFERENCES operators(id),
    sop_document_link VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    initial_site_setup_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    full_site_address TEXT GENERATED ALWAYS AS (
        COALESCE(site_address_street, '') || ', ' || 
        COALESCE(site_address_city, '') || ', ' || 
        COALESCE(site_address_state, '') || ' ' || 
        COALESCE(site_address_zip, '')
    ) STORED
);

-- Create index on site name for faster lookups
CREATE INDEX idx_sites_site_name ON sites(site_name);
CREATE INDEX idx_sites_location ON sites(site_latitude, site_longitude);

-- Site Aliases table
CREATE TABLE site_aliases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    alias_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(site_id, alias_name)
);

CREATE INDEX idx_site_aliases_name ON site_aliases(alias_name);

-- Partners table
CREATE TABLE partners (
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

CREATE INDEX idx_partners_name ON partners(partner_name);

-- Vendors table
CREATE TABLE vendors (
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

CREATE INDEX idx_vendors_name ON vendors(vendor_name);

-- Personnel table
CREATE TABLE personnel (
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

CREATE INDEX idx_personnel_email ON personnel(email);
CREATE INDEX idx_personnel_name ON personnel(last_name, first_name);

-- Operators table
CREATE TABLE operators (
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

-- FLRTS Users table
CREATE TABLE flrts_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id_display VARCHAR(50) NOT NULL UNIQUE,
    personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE RESTRICT,
    telegram_id VARCHAR(255),
    telegram_username VARCHAR(255),
    noloco_user_email VARCHAR(255),
    user_role_flrts VARCHAR(50) NOT NULL CHECK (user_role_flrts IN ('Administrator', 'Site Manager', 'Field Technician', 'View Only', 'Data Analyst')),
    last_login_flrts TIMESTAMPTZ,
    is_active_flrts_user BOOLEAN DEFAULT TRUE,
    preferences_flrts JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(personnel_id)
);

CREATE INDEX idx_flrts_users_telegram ON flrts_users(telegram_id);

-- ===========================================
-- RELATIONSHIP TABLES
-- ===========================================

-- Site Partner Assignments (junction table)
CREATE TABLE site_partner_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id_display VARCHAR(50) NOT NULL UNIQUE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    role_of_partner_at_site TEXT,
    markup_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0,
    assignment_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(site_id, partner_id)
);

CREATE INDEX idx_site_partner_site ON site_partner_assignments(site_id);
CREATE INDEX idx_site_partner_partner ON site_partner_assignments(partner_id);

-- Site Vendor Assignments (junction table)
CREATE TABLE site_vendor_assignments (
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

CREATE INDEX idx_site_vendor_site ON site_vendor_assignments(site_id);
CREATE INDEX idx_site_vendor_vendor ON site_vendor_assignments(vendor_id);

-- ===========================================
-- FINANCIAL TABLES
-- ===========================================

-- Vendor Invoices table
CREATE TABLE vendor_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_invoice_id_display VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Draft', 'Received', 'Processing', 'Approved', 'Paid', 'Rejected')),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    site_id UUID NOT NULL REFERENCES sites(id),
    invoice_date DATE NOT NULL,
    invoice_number VARCHAR(255),
    original_amount DECIMAL(12, 2) NOT NULL,
    markup_percentage DECIMAL(5, 2),
    markup_amount DECIMAL(12, 2),
    final_amount DECIMAL(12, 2),
    partner_id UUID REFERENCES partners(id),
    attachment_url VARCHAR(1024),
    due_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vendor_invoices_site ON vendor_invoices(site_id);
CREATE INDEX idx_vendor_invoices_vendor ON vendor_invoices(vendor_id);
CREATE INDEX idx_vendor_invoices_date ON vendor_invoices(invoice_date);

-- Partner Billings table
CREATE TABLE partner_billings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_billing_id_display VARCHAR(50) NOT NULL UNIQUE,
    partner_id UUID NOT NULL REFERENCES partners(id),
    vendor_invoice_id UUID NOT NULL REFERENCES vendor_invoices(id),
    billing_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Draft', 'Pending', 'Sent', 'Paid', 'Overdue', 'Disputed')),
    original_amount DECIMAL(12, 2) NOT NULL,
    markup_amount DECIMAL(12, 2) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    payment_due_date DATE,
    payment_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(vendor_invoice_id)
);

CREATE INDEX idx_partner_billings_partner ON partner_billings(partner_id);
CREATE INDEX idx_partner_billings_invoice ON partner_billings(vendor_invoice_id);
CREATE INDEX idx_partner_billings_date ON partner_billings(billing_date);

-- ===========================================
-- EQUIPMENT TABLES
-- ===========================================

-- Equipment table
CREATE TABLE equipment (
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
    purchase_price DECIMAL(12, 2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_equipment_site ON equipment(site_location_id);
CREATE INDEX idx_equipment_vendor ON equipment(vendor_id);

-- ASICs table
CREATE TABLE asics (
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
    nominal_hashrate_th DECIMAL(12, 2),
    purchase_price DECIMAL(12, 2),
    firmware_version VARCHAR(255),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_asics_site ON asics(site_location_id);
CREATE INDEX idx_asics_vendor ON asics(vendor_id);

-- Licenses & Agreements table
CREATE TABLE licenses_agreements (
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

-- Junction table for licenses_agreements to sites (many-to-many)
CREATE TABLE licenses_agreements_sites (
    agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    PRIMARY KEY (agreement_id, site_id)
);

-- Junction table for licenses_agreements to partners (many-to-many)
CREATE TABLE licenses_agreements_partners (
    agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    PRIMARY KEY (agreement_id, partner_id)
);

-- Junction table for licenses_agreements to vendors (many-to-many)
CREATE TABLE licenses_agreements_vendors (
    agreement_id UUID NOT NULL REFERENCES licenses_agreements(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    PRIMARY KEY (agreement_id, vendor_id)
);

-- ===========================================
-- FLRTS OPERATIONAL TABLES
-- ===========================================

-- Field Reports table
CREATE TABLE field_reports (
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

CREATE INDEX idx_field_reports_site ON field_reports(site_id);
CREATE INDEX idx_field_reports_date ON field_reports(report_date);
CREATE INDEX idx_field_reports_status ON field_reports(report_status);

-- Field Report Edits table (for audit trail)
CREATE TABLE field_report_edits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_field_report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    author_user_id UUID NOT NULL REFERENCES flrts_users(id),
    edit_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    edit_text_full_version TEXT NOT NULL,
    edit_summary_user_provided VARCHAR(255),
    version_number_calculated INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_field_report_edits_report ON field_report_edits(parent_field_report_id);

-- Junction table for field_reports to equipment (many-to-many)
CREATE TABLE field_reports_equipment (
    report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    PRIMARY KEY (report_id, equipment_id)
);

-- Junction table for field_reports to asics (many-to-many)
CREATE TABLE field_reports_asics (
    report_id UUID NOT NULL REFERENCES field_reports(id) ON DELETE CASCADE,
    asic_id UUID NOT NULL REFERENCES asics(id) ON DELETE CASCADE,
    PRIMARY KEY (report_id, asic_id)
);

-- Lists table
CREATE TABLE lists (
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

CREATE INDEX idx_lists_site ON lists(site_id);
CREATE INDEX idx_lists_type ON lists(list_type);

-- List Items table
CREATE TABLE list_items (
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

CREATE INDEX idx_list_items_list ON list_items(parent_list_id);
CREATE INDEX idx_list_items_completion ON list_items(parent_list_id, is_complete_or_checked);

-- Tasks table
CREATE TABLE tasks (
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

CREATE INDEX idx_tasks_assigned ON tasks(assigned_to_user_id);
CREATE INDEX idx_tasks_site ON tasks(site_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_parent ON tasks(parent_task_id);

-- Reminders table
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reminder_id_display VARCHAR(50) NOT NULL UNIQUE,
    reminder_title VARCHAR(255) NOT NULL,
    reminder_date_time TIMESTAMPTZ NOT NULL,
    user_to_remind_id UUID NOT NULL REFERENCES flrts_users(id),
    related_task_id UUID REFERENCES tasks(id),
    related_field_report_id UUID REFERENCES field_reports(id),
    related_site_id UUID REFERENCES sites(id),
    status VARCHAR(50) NOT NULL CHECK (status IN ('Scheduled', 'Sent', 'Dismissed', 'Completed', 'Error')) DEFAULT 'Scheduled',
    notification_channels VARCHAR(255)[], -- Array of channel names: 'Telegram', 'Email', 'In-App (Noloco)'
    todoist_reminder_id VARCHAR(255),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule VARCHAR(255),
    created_by_user_id UUID REFERENCES flrts_users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reminders_user ON reminders(user_to_remind_id);
CREATE INDEX idx_reminders_datetime ON reminders(reminder_date_time);
CREATE INDEX idx_reminders_status ON reminders(status);

-- Notifications Log table
CREATE TABLE notifications_log (
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

CREATE INDEX idx_notifications_recipient ON notifications_log(recipient_user_id);
CREATE INDEX idx_notifications_timestamp ON notifications_log(timestamp_sent);

-- ===========================================
-- VIEWS
-- ===========================================

-- Site Partner Information (with markup %)
CREATE VIEW site_partner_view AS
SELECT 
    s.id AS site_id, 
    s.site_name, 
    p.id AS partner_id, 
    p.partner_name, 
    spa.markup_percentage, 
    spa.role_of_partner_at_site,
    spa.assignment_active
FROM 
    sites s
JOIN 
    site_partner_assignments spa ON s.id = spa.site_id
JOIN 
    partners p ON p.id = spa.partner_id
WHERE 
    s.is_active = TRUE AND p.is_active = TRUE AND spa.assignment_active = TRUE;

-- Vendor Invoice Summary (with markup info)
CREATE VIEW vendor_invoice_summary AS
SELECT 
    vi.id AS invoice_id,
    vi.vendor_invoice_id_display,
    vi.invoice_date,
    vi.status,
    v.vendor_name,
    s.site_name,
    p.partner_name,
    vi.original_amount,
    vi.markup_percentage,
    vi.markup_amount,
    vi.final_amount,
    pb.status AS billing_status,
    vi.due_date
FROM 
    vendor_invoices vi
JOIN 
    vendors v ON vi.vendor_id = v.id
JOIN 
    sites s ON vi.site_id = s.id
LEFT JOIN 
    partners p ON vi.partner_id = p.id
LEFT JOIN 
    partner_billings pb ON vi.id = pb.vendor_invoice_id;

-- Site Financial Summary
CREATE VIEW site_financial_summary AS
SELECT 
    s.id AS site_id,
    s.site_name,
    COUNT(vi.id) AS total_invoices,
    SUM(vi.original_amount) AS total_original_amount,
    SUM(vi.markup_amount) AS total_markup_amount,
    SUM(vi.final_amount) AS total_final_amount,
    MAX(vi.invoice_date) AS latest_invoice_date
FROM 
    sites s
LEFT JOIN 
    vendor_invoices vi ON s.id = vi.site_id
GROUP BY 
    s.id, s.site_name;

-- Partner Financial Summary
CREATE VIEW partner_financial_summary AS
SELECT 
    p.id AS partner_id,
    p.partner_name,
    COUNT(pb.id) AS total_billings,
    SUM(pb.original_amount) AS total_original_amount,
    SUM(pb.markup_amount) AS total_markup_amount,
    SUM(pb.total_amount) AS total_billed_amount,
    COUNT(CASE WHEN pb.status = 'Paid' THEN 1 END) AS total_paid_billings,
    SUM(CASE WHEN pb.status = 'Paid' THEN pb.total_amount ELSE 0 END) AS total_paid_amount,
    COUNT(CASE WHEN pb.status = 'Pending' OR pb.status = 'Sent' OR pb.status = 'Overdue' THEN 1 END) AS total_outstanding_billings,
    SUM(CASE WHEN pb.status = 'Pending' OR pb.status = 'Sent' OR pb.status = 'Overdue' THEN pb.total_amount ELSE 0 END) AS total_outstanding_amount
FROM 
    partners p
LEFT JOIN 
    partner_billings pb ON p.id = pb.partner_id
GROUP BY 
    p.id, p.partner_name;

-- Active Tasks By Site
CREATE VIEW active_tasks_by_site AS
SELECT 
    s.id AS site_id,
    s.site_name,
    COUNT(t.id) AS total_tasks,
    COUNT(CASE WHEN t.status = 'To Do' THEN 1 END) AS to_do_count,
    COUNT(CASE WHEN t.status = 'In Progress' THEN 1 END) AS in_progress_count,
    COUNT(CASE WHEN t.status = 'Blocked' THEN 1 END) AS blocked_count,
    COUNT(CASE WHEN t.due_date < CURRENT_DATE AND t.status != 'Completed' AND t.status != 'Cancelled' THEN 1 END) AS overdue_count
FROM 
    sites s
LEFT JOIN 
    tasks t ON s.id = t.site_id
WHERE 
    t.status != 'Completed' AND t.status != 'Cancelled'
GROUP BY 
    s.id, s.site_name;

-- ===========================================
-- FUNCTIONS AND TRIGGERS FOR MARKUP MANAGEMENT
-- ===========================================

-- Helper function to get site-partner markup percentage
CREATE OR REPLACE FUNCTION get_site_partner_markup(site_uuid UUID, partner_uuid UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    markup_pct DECIMAL(5,2);
BEGIN
    SELECT markup_percentage INTO markup_pct
    FROM site_partner_assignments
    WHERE site_id = site_uuid 
    AND partner_id = partner_uuid
    AND assignment_active = TRUE;
    
    RETURN COALESCE(markup_pct, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate invoice markup
CREATE OR REPLACE FUNCTION calculate_invoice_markup(invoice_uuid UUID)
RETURNS VOID AS $$
DECLARE
    site_uuid UUID;
    partner_uuid UUID;
    markup_pct DECIMAL(5,2);
    original_amount DECIMAL(12,2);
    markup_amount DECIMAL(12,2);
    final_amount DECIMAL(12,2);
BEGIN
    -- Get invoice details
    SELECT site_id, partner_id, original_amount 
    INTO site_uuid, partner_uuid, original_amount
    FROM vendor_invoices
    WHERE id = invoice_uuid;
    
    -- If partner is not set, find the partner based on site
    IF partner_uuid IS NULL THEN
        SELECT partner_id INTO partner_uuid
        FROM site_partner_assignments
        WHERE site_id = site_uuid
        AND assignment_active = TRUE
        LIMIT 1;
        
        -- Update the partner_id in vendor_invoices if found
        IF partner_uuid IS NOT NULL THEN
            UPDATE vendor_invoices
            SET partner_id = partner_uuid
            WHERE id = invoice_uuid;
        END IF;
    END IF;
    
    -- Calculate markup if partner exists
    IF partner_uuid IS NOT NULL THEN
        -- Get markup percentage
        markup_pct := get_site_partner_markup(site_uuid, partner_uuid);
        
        -- Calculate markup amount and final amount
        markup_amount := ROUND(original_amount * (markup_pct / 100), 2);
        final_amount := original_amount + markup_amount;
        
        -- Update the invoice with markup information
        UPDATE vendor_invoices
        SET markup_percentage = markup_pct,
            markup_amount = markup_amount,
            final_amount = final_amount
        WHERE id = invoice_uuid;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to create partner billing from invoice
CREATE OR REPLACE FUNCTION create_partner_billing(invoice_uuid UUID)
RETURNS VOID AS $$
DECLARE
    invoice_record RECORD;
    billing_id_display VARCHAR(50);
    existing_billing_count INTEGER;
BEGIN
    -- Check if billing already exists for this invoice
    SELECT COUNT(*) INTO existing_billing_count
    FROM partner_billings
    WHERE vendor_invoice_id = invoice_uuid;
    
    IF existing_billing_count > 0 THEN
        -- Billing already exists, update it instead
        UPDATE partner_billings
        SET partner_id = vi.partner_id,
            billing_date = CURRENT_DATE,
            status = 'Pending',
            original_amount = vi.original_amount,
            markup_amount = COALESCE(vi.markup_amount, 0),
            total_amount = COALESCE(vi.final_amount, vi.original_amount),
            payment_due_date = vi.due_date,
            updated_at = NOW()
        FROM vendor_invoices vi
        WHERE partner_billings.vendor_invoice_id = invoice_uuid
        AND vi.id = invoice_uuid;
    ELSE
        -- Get invoice details
        SELECT * INTO invoice_record
        FROM vendor_invoices
        WHERE id = invoice_uuid;
        
        -- Only create billing if partner is set and markup is calculated
        IF invoice_record.partner_id IS NOT NULL THEN
            -- Generate billing_id_display
            billing_id_display := 'PB-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                                 LPAD(CAST((SELECT COUNT(*) + 1 FROM partner_billings) AS TEXT), 3, '0');
            
            -- Create new partner billing record
            INSERT INTO partner_billings (
                partner_billing_id_display,
                partner_id,
                vendor_invoice_id,
                billing_date,
                status,
                original_amount,
                markup_amount,
                total_amount,
                payment_due_date
            ) VALUES (
                billing_id_display,
                invoice_record.partner_id,
                invoice_uuid,
                CURRENT_DATE,
                'Pending',
                invoice_record.original_amount,
                COALESCE(invoice_record.markup_amount, 0),
                COALESCE(invoice_record.final_amount, invoice_record.original_amount),
                invoice_record.due_date
            );
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for vendor_invoices table
CREATE OR REPLACE FUNCTION process_vendor_invoice()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate markup
    PERFORM calculate_invoice_markup(NEW.id);
    
    -- Create partner billing if all required data is present
    IF NEW.partner_id IS NOT NULL AND NEW.markup_amount IS NOT NULL THEN
        PERFORM create_partner_billing(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for new vendor invoices
CREATE TRIGGER after_vendor_invoice_insert
AFTER INSERT ON vendor_invoices
FOR EACH ROW
EXECUTE FUNCTION process_vendor_invoice();

-- Trigger for updated vendor invoices
CREATE TRIGGER after_vendor_invoice_update
AFTER UPDATE ON vendor_invoices
FOR EACH ROW
WHEN (OLD.original_amount IS DISTINCT FROM NEW.original_amount OR 
      OLD.site_id IS DISTINCT FROM NEW.site_id OR
      OLD.partner_id IS DISTINCT FROM NEW.partner_id)
EXECUTE FUNCTION process_vendor_invoice();

-- Trigger function for site_partner_assignments table
CREATE OR REPLACE FUNCTION update_invoices_after_assignment_change()
RETURNS TRIGGER AS $$
DECLARE
    invoice_record RECORD;
BEGIN
    -- If markup percentage changed, update related invoices
    IF OLD.markup_percentage IS DISTINCT FROM NEW.markup_percentage THEN
        FOR invoice_record IN
            SELECT id
            FROM vendor_invoices
            WHERE site_id = NEW.site_id
            AND partner_id = NEW.partner_id
        LOOP
            -- Recalculate markup and update billing
            PERFORM calculate_invoice_markup(invoice_record.id);
            PERFORM create_partner_billing(invoice_record.id);
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updated site-partner assignments
CREATE TRIGGER after_site_partner_assignment_update
AFTER UPDATE ON site_partner_assignments
FOR EACH ROW
EXECUTE FUNCTION update_invoices_after_assignment_change();

-- ===========================================
-- ROW LEVEL SECURITY POLICIES
-- ===========================================

-- Enable RLS on tables
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_billings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_reports ENABLE ROW LEVEL SECURITY;

-- Create app roles
CREATE ROLE app_admin;
CREATE ROLE app_site_manager;
CREATE ROLE app_field_technician;
CREATE ROLE app_finance;
CREATE ROLE app_viewer;

-- Example policies (modify based on your specific requirements)
-- Sites policy
CREATE POLICY sites_all_access ON sites 
    FOR ALL 
    TO app_admin
    USING (true);

CREATE POLICY sites_view_access ON sites 
    FOR SELECT 
    TO app_site_manager, app_field_technician, app_finance, app_viewer
    USING (true);

CREATE POLICY sites_modify_access ON sites 
    FOR UPDATE 
    TO app_site_manager
    USING (true);

-- Vendor Invoices policy
CREATE POLICY invoices_all_access ON vendor_invoices 
    FOR ALL 
    TO app_admin, app_finance
    USING (true);

CREATE POLICY invoices_view_access ON vendor_invoices 
    FOR SELECT 
    TO app_site_manager, app_viewer
    USING (true);

CREATE POLICY invoices_site_access ON vendor_invoices 
    FOR SELECT 
    TO app_field_technician
    USING (EXISTS (
        SELECT 1 FROM flrts_users fu 
        WHERE fu.id = auth.uid() 
        AND fu.personnel_id IN (
            SELECT personnel_id FROM personnel WHERE primary_site_id = vendor_invoices.site_id
        )
    ));

-- Field Reports policy
CREATE POLICY reports_all_access ON field_reports 
    FOR ALL 
    TO app_admin
    USING (true);

CREATE POLICY reports_view_access ON field_reports 
    FOR SELECT 
    TO app_site_manager, app_viewer
    USING (true);

CREATE POLICY reports_create_access ON field_reports 
    FOR INSERT 
    TO app_field_technician
    WITH CHECK (submitted_by_user_id = auth.uid());

CREATE POLICY reports_update_own_access ON field_reports 
    FOR UPDATE 
    TO app_field_technician
    USING (submitted_by_user_id = auth.uid());

-- ===========================================
-- INITIAL DATA MIGRATION HELPER FUNCTIONS
-- ===========================================

-- Function to generate a display ID with padding
CREATE OR REPLACE FUNCTION generate_display_id(prefix TEXT, id INTEGER)
RETURNS TEXT AS $$
BEGIN
    RETURN prefix || LPAD(id::TEXT, 3, '0');
END;
$$ LANGUAGE plpgsql;

-- Example function to import sites from CSV
CREATE OR REPLACE FUNCTION import_sites_from_csv(csv_path TEXT)
RETURNS INTEGER AS $$
DECLARE
    imported_count INTEGER := 0;
BEGIN
    -- Code to import data would go here
    -- This is a placeholder - actual implementation would use pg_read_file or similar
    
    RETURN imported_count;
END;
$$ LANGUAGE plpgsql;

-- Schema updates


-- ==========================================
-- 10NetZero-FLRTS: Supabase Schema Update
-- ==========================================
-- Version: 1.0
-- Date: May 21, 2025
-- Description: Update script to align the database schema with specifications

-- First, create the markup_changes_log table if it doesn't exist
CREATE TABLE IF NOT EXISTS markup_changes_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id),
    partner_id UUID NOT NULL REFERENCES partners(id),
    old_markup_percentage DECIMAL(5,2),
    new_markup_percentage DECIMAL(5,2),
    changed_by UUID,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_markup_changes_site_partner ON markup_changes_log(site_id, partner_id);
CREATE INDEX IF NOT EXISTS idx_markup_changes_timestamp ON markup_changes_log(changed_at);

-- Update the trigger function for site_partner_assignments to include audit logging
CREATE OR REPLACE FUNCTION update_invoices_after_assignment_change()
RETURNS TRIGGER AS $$
DECLARE
    invoice_record RECORD;
BEGIN
    -- If markup percentage changed, update related invoices
    IF OLD.markup_percentage IS DISTINCT FROM NEW.markup_percentage THEN
        -- Log the change for auditing purposes
        INSERT INTO markup_changes_log (
            site_id,
            partner_id,
            old_markup_percentage,
            new_markup_percentage,
            changed_by
        ) VALUES (
            NEW.site_id,
            NEW.partner_id,
            OLD.markup_percentage,
            NEW.markup_percentage,
            auth.uid()
        );
        
        -- Update all invoices affected by this markup change
        FOR invoice_record IN
            SELECT id
            FROM vendor_invoices
            WHERE site_id = NEW.site_id
            AND partner_id = NEW.partner_id
            -- Only update non-finalized invoices
            AND status NOT IN ('Paid', 'Rejected')
        LOOP
            -- Recalculate markup and update billing
            PERFORM calculate_invoice_markup(invoice_record.id);
            PERFORM create_partner_billing(invoice_record.id);
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update the function to create partner billing from invoice to handle paid invoices
CREATE OR REPLACE FUNCTION create_partner_billing(invoice_uuid UUID)
RETURNS VOID AS $$
DECLARE
    invoice_record RECORD;
    billing_id_display VARCHAR(50);
    existing_billing_count INTEGER;
BEGIN
    -- Check if billing already exists for this invoice
    SELECT COUNT(*) INTO existing_billing_count
    FROM partner_billings
    WHERE vendor_invoice_id = invoice_uuid;
    
    IF existing_billing_count > 0 THEN
        -- Billing already exists, update it instead
        UPDATE partner_billings
        SET partner_id = vi.partner_id,
            billing_date = CURRENT_DATE,
            status = 
                CASE 
                    WHEN partner_billings.status = 'Paid' THEN 'Paid' -- Don't change paid status
                    ELSE 'Pending' -- Reset to pending if it wasn't paid
                END,
            original_amount = vi.original_amount,
            markup_amount = COALESCE(vi.markup_amount, 0),
            total_amount = COALESCE(vi.final_amount, vi.original_amount),
            payment_due_date = vi.due_date,
            updated_at = NOW()
        FROM vendor_invoices vi
        WHERE partner_billings.vendor_invoice_id = invoice_uuid
        AND vi.id = invoice_uuid;
    ELSE
        -- Get invoice details
        SELECT * INTO invoice_record
        FROM vendor_invoices
        WHERE id = invoice_uuid;
        
        -- Only create billing if partner is set and markup is calculated
        IF invoice_record.partner_id IS NOT NULL THEN
            -- Generate billing_id_display
            billing_id_display := 'PB-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                                 LPAD(CAST((SELECT COUNT(*) + 1 FROM partner_billings) AS TEXT), 3, '0');
            
            -- Create new partner billing record
            INSERT INTO partner_billings (
                partner_billing_id_display,
                partner_id,
                vendor_invoice_id,
                billing_date,
                status,
                original_amount,
                markup_amount,
                total_amount,
                payment_due_date
            ) VALUES (
                billing_id_display,
                invoice_record.partner_id,
                invoice_uuid,
                CURRENT_DATE,
                'Pending',
                invoice_record.original_amount,
                COALESCE(invoice_record.markup_amount, 0),
                COALESCE(invoice_record.final_amount, invoice_record.original_amount),
                invoice_record.due_date
            );
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Add the function to recalculate all markup amounts
CREATE OR REPLACE FUNCTION recalculate_all_markups()
RETURNS INTEGER AS $$
DECLARE
    invoice_record RECORD;
    count_updated INTEGER := 0;
BEGIN
    FOR invoice_record IN
        SELECT id
        FROM vendor_invoices
        WHERE status NOT IN ('Paid', 'Rejected')
    LOOP
        PERFORM calculate_invoice_markup(invoice_record.id);
        PERFORM create_partner_billing(invoice_record.id);
        count_updated := count_updated + 1;
    END LOOP;
    
    RETURN count_updated;
END;
$$ LANGUAGE plpgsql;

-- Add the function to get financial summary for a partner
CREATE OR REPLACE FUNCTION get_partner_financial_summary(partner_uuid UUID)
RETURNS TABLE (
    total_invoices BIGINT,
    total_original_amount DECIMAL(12,2),
    total_markup_amount DECIMAL(12,2),
    total_final_amount DECIMAL(12,2),
    outstanding_invoices BIGINT,
    outstanding_amount DECIMAL(12,2),
    paid_invoices BIGINT,
    paid_amount DECIMAL(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(pb.id) AS total_invoices,
        SUM(pb.original_amount) AS total_original_amount,
        SUM(pb.markup_amount) AS total_markup_amount,
        SUM(pb.total_amount) AS total_final_amount,
        COUNT(CASE WHEN pb.status != 'Paid' THEN 1 END) AS outstanding_invoices,
        SUM(CASE WHEN pb.status != 'Paid' THEN pb.total_amount ELSE 0 END) AS outstanding_amount,
        COUNT(CASE WHEN pb.status = 'Paid' THEN 1 END) AS paid_invoices,
        SUM(CASE WHEN pb.status = 'Paid' THEN pb.total_amount ELSE 0 END) AS paid_amount
    FROM 
        partner_billings pb
    WHERE 
        pb.partner_id = partner_uuid;
END;
$$ LANGUAGE plpgsql;

-- Add the function to get financial summary for a site
CREATE OR REPLACE FUNCTION get_site_financial_summary(site_uuid UUID)
RETURNS TABLE (
    total_invoices BIGINT,
    total_original_amount DECIMAL(12,2),
    total_markup_amount DECIMAL(12,2),
    total_final_amount DECIMAL(12,2),
    average_markup_percentage DECIMAL(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(vi.id) AS total_invoices,
        SUM(vi.original_amount) AS total_original_amount,
        SUM(vi.markup_amount) AS total_markup_amount,
        SUM(vi.final_amount) AS total_final_amount,
        CASE 
            WHEN SUM(vi.original_amount) > 0 
            THEN ROUND(SUM(vi.markup_amount) * 100.0 / SUM(vi.original_amount), 2)
            ELSE 0
        END AS average_markup_percentage
    FROM 
        vendor_invoices vi
    WHERE 
        vi.site_id = site_uuid;
END;
$$ LANGUAGE plpgsql;

-- Create view for outstanding billings that need follow-up
CREATE OR REPLACE VIEW outstanding_partner_billings AS
SELECT 
    pb.id,
    pb.partner_billing_id_display,
    p.partner_name,
    s.site_name,
    vi.vendor_invoice_id_display AS vendor_invoice_number,
    vi.invoice_date,
    pb.status,
    pb.total_amount,
    pb.payment_due_date,
    CASE 
        WHEN pb.payment_due_date < CURRENT_DATE AND pb.status IN ('Pending', 'Sent') 
        THEN TRUE
        ELSE FALSE
    END AS is_overdue,
    CASE 
        WHEN pb.payment_due_date < CURRENT_DATE AND pb.status IN ('Pending', 'Sent')
        THEN CURRENT_DATE - pb.payment_due_date
        ELSE 0
    END AS days_overdue
FROM 
    partner_billings pb
JOIN 
    partners p ON pb.partner_id = p.id
JOIN 
    vendor_invoices vi ON pb.vendor_invoice_id = vi.id
JOIN 
    sites s ON vi.site_id = s.id
WHERE 
    pb.status IN ('Pending', 'Sent', 'Overdue')
ORDER BY 
    is_overdue DESC, days_overdue DESC, pb.payment_due_date;

-- Sample data


-- ==========================================
-- 10NetZero-FLRTS: Sample Data for Testing
-- ==========================================
-- Version: 1.0
-- Date: May 21, 2025
-- Description: Sample data to test the 10NetZero-FLRTS schema

-- ===================
-- Sample Operators
-- ===================
INSERT INTO operators (operator_id_display, operator_name, operator_type)
VALUES 
('OP001', '10NetZero Operations', 'Internal (10NetZero)'),
('OP002', 'GreenMine Management', 'Third-Party');

-- ===================
-- Sample Sites
-- ===================
INSERT INTO sites (site_id_display, site_name, site_address_street, site_address_city, site_address_state, site_address_zip, site_latitude, site_longitude, site_status, operator_id)
VALUES 
('S001', 'North Austin Facility', '123 Tech Ridge Blvd', 'Austin', 'TX', '78758', 30.4133, -97.6667, 'Running', (SELECT id FROM operators WHERE operator_id_display = 'OP001')),
('S002', 'West Houston Mining Center', '456 Energy Drive', 'Houston', 'TX', '77082', 29.7604, -95.3698, 'Commissioning', (SELECT id FROM operators WHERE operator_id_display = 'OP002')),
('S003', 'Phoenix Expansion Site', '789 Desert Way', 'Phoenix', 'AZ', '85001', 33.4484, -112.0740, 'Contracted', (SELECT id FROM operators WHERE operator_id_display = 'OP001'));

-- ===================
-- Sample Site Aliases
-- ===================
INSERT INTO site_aliases (site_id, alias_name)
VALUES 
((SELECT id FROM sites WHERE site_id_display = 'S001'), 'NAF'),
((SELECT id FROM sites WHERE site_id_display = 'S001'), 'Austin-1'),
((SELECT id FROM sites WHERE site_id_display = 'S002'), 'Houston-West');

-- ===================
-- Sample Partners
-- ===================
INSERT INTO partners (partner_id_display, partner_name, partner_type, primary_contact_name, primary_contact_email, is_active)
VALUES 
('P001', 'GreenEnergy Capital', 'Investor', 'Sarah Johnson', 'sarah@greenenergy.example.com', TRUE),
('P002', 'TechFund Ventures', 'Investor', 'Michael Chen', 'mchen@techfund.example.com', TRUE),
('P003', 'CleanPower Co-op', 'Community', 'David Williams', 'david@cleanpower.example.com', TRUE);

-- ===================
-- Sample Vendors
-- ===================
INSERT INTO vendors (vendor_id_display, vendor_name, vendor_category, primary_contact_name, preferred_vendor, is_active)
VALUES 
('V001', 'MiningTech Equipment', 'Hardware', 'Robert Smith', TRUE, TRUE),
('V002', 'CoolSystems Inc', 'Cooling', 'Jennifer Brown', TRUE, TRUE),
('V003', 'PowerGrid Solutions', 'Power Supply', 'Thomas Wilson', FALSE, TRUE),
('V004', 'SecureNet Systems', 'Security', 'Lisa Garcia', FALSE, TRUE);

-- ===================
-- Sample Personnel
-- ===================
INSERT INTO personnel (personnel_id_display, first_name, last_name, email, phone_number, job_title, personnel_type, primary_site_id)
VALUES 
('P001', 'John', 'Doe', 'john.doe@10netzero.example.com', '512-555-1234', 'Site Manager', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S001')),
('P002', 'Jane', 'Smith', 'jane.smith@10netzero.example.com', '512-555-5678', 'Field Technician', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S001')),
('P003', 'Alex', 'Johnson', 'alex.johnson@10netzero.example.com', '713-555-9012', 'Site Manager', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S002')),
('P004', 'Maria', 'Rodriguez', 'maria.rodriguez@consultant.example.com', '602-555-3456', 'HVAC Specialist', 'Contractor', (SELECT id FROM sites WHERE site_id_display = 'S003'));

-- ===================
-- Sample FLRTS Users
-- ===================
INSERT INTO flrts_users (user_id_display, personnel_id, telegram_username, noloco_user_email, user_role_flrts, is_active_flrts_user)
VALUES 
('U001', (SELECT id FROM personnel WHERE personnel_id_display = 'P001'), 'johndoe_10nz', 'john.doe@10netzero.example.com', 'Site Manager', TRUE),
('U002', (SELECT id FROM personnel WHERE personnel_id_display = 'P002'), 'janesmith_10nz', 'jane.smith@10netzero.example.com', 'Field Technician', TRUE),
('U003', (SELECT id FROM personnel WHERE personnel_id_display = 'P003'), 'alexj_10nz', 'alex.johnson@10netzero.example.com', 'Site Manager', TRUE),
('U004', (SELECT id FROM personnel WHERE personnel_id_display = 'P004'), NULL, 'maria.rodriguez@consultant.example.com', 'Field Technician', TRUE);

-- ===================
-- Sample Site-Partner Assignments
-- ===================
INSERT INTO site_partner_assignments (assignment_id_display, site_id, partner_id, role_of_partner_at_site, markup_percentage)
VALUES 
('SPA001', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM partners WHERE partner_id_display = 'P001'), 'Primary Investor', 15.00),
('SPA002', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM partners WHERE partner_id_display = 'P002'), 'Primary Investor', 12.50),
('SPA003', (SELECT id FROM sites WHERE site_id_display = 'S003'), (SELECT id FROM partners WHERE partner_id_display = 'P003'), 'Community Partnership', 7.50),
('SPA004', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM partners WHERE partner_id_display = 'P003'), 'Secondary Partner', 5.00);

-- ===================
-- Sample Site-Vendor Assignments
-- ===================
INSERT INTO site_vendor_assignments (assignment_id_display, site_id, vendor_id, services_products_provided_at_site)
VALUES 
('SVA001', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), 'ASIC hardware and maintenance'),
('SVA002', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V002'), 'Cooling systems and maintenance'),
('SVA003', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), 'ASIC hardware'),
('SVA004', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), 'Power infrastructure'),
('SVA005', (SELECT id FROM sites WHERE site_id_display = 'S003'), (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), 'Security systems installation');

-- ===================
-- Sample Vendor Invoices
-- ===================
INSERT INTO vendor_invoices (vendor_invoice_id_display, status, vendor_id, site_id, invoice_date, invoice_number, original_amount, due_date)
VALUES 
('VI001', 'Received', (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-04-15', 'MT-2025-042', 45000.00, '2025-05-15'),
('VI002', 'Approved', (SELECT id FROM vendors WHERE vendor_id_display = 'V002'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-04-20', 'CS-10458', 12500.00, '2025-05-20'),
('VI003', 'Processing', (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-04-25', 'MT-2025-051', 75000.00, '2025-05-25'),
('VI004', 'Draft', (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-05-01', 'PG-2025-15', 32000.00, '2025-06-01'),
('VI005', 'Paid', (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), (SELECT id FROM sites WHERE site_id_display = 'S003'), '2025-03-10', 'SN-2025-022', 18500.00, '2025-04-10');

-- Update the partner_id for invoices (the trigger will calculate markup)
UPDATE vendor_invoices 
SET partner_id = (
    SELECT partner_id FROM site_partner_assignments 
    WHERE site_id = vendor_invoices.site_id 
    AND role_of_partner_at_site LIKE '%Primary%'
    LIMIT 1
)
WHERE vendor_invoice_id_display IN ('VI001', 'VI002', 'VI003', 'VI004');

UPDATE vendor_invoices 
SET partner_id = (
    SELECT partner_id FROM site_partner_assignments 
    WHERE site_id = vendor_invoices.site_id 
    LIMIT 1
)
WHERE vendor_invoice_id_display = 'VI005';

-- ===================
-- Sample Equipment
-- ===================
INSERT INTO equipment (equipment_id_display, equipment_name, equipment_type, site_location_id, vendor_id, date_purchased, status)
VALUES 
('EQ001', 'Industrial Network Switch 48-port', 'Networking', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'Operational'),
('EQ002', 'Backup Generator 50kW', 'Power Supply', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), '2025-01-20', 'Operational'),
('EQ003', 'Security Camera System', 'Security', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), '2025-02-10', 'Operational');

-- ===================
-- Sample ASICs
-- ===================
INSERT INTO asics (asic_id_display, asic_name_model, site_location_id, vendor_id, date_purchased, serial_number, status, nominal_hashrate_th)
VALUES 
('ASIC001', 'MiningMaster Pro X1', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'MMX1-2025-001', 'Operational/Mining', 110.5),
('ASIC002', 'MiningMaster Pro X1', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'MMX1-2025-002', 'Operational/Mining', 110.5),
('ASIC003', 'MiningMaster Pro X2', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-03-01', 'MMX2-2025-001', 'Idle', 125.0);

-- ===================
-- Sample Field Reports
-- ===================
INSERT INTO field_reports (report_id_display, site_id, report_date, submitted_by_user_id, report_type, report_title_summary, report_content_full, report_status)
VALUES 
('FR001', (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-05-01', (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), 'Daily Operational Summary', 'Daily checks complete - all systems normal', 'Completed daily checklist for North Austin Facility. All systems operational. Temperature ranges normal. No incidents to report.', 'Submitted'),
('FR002', (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-05-05', (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), 'Incident Report', 'Brief power fluctuation at 14:30', 'Experienced power fluctuation at approximately 14:30. Lasted about 3 seconds. All ASICs rebooted successfully. No permanent issues detected. Local utility company contacted to inquire about grid status.', 'Under Review'),
('FR003', (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-05-10', (SELECT id FROM flrts_users WHERE user_id_display = 'U003'), 'Maintenance Log', 'Cooling system maintenance performed', 'Scheduled maintenance performed on cooling systems. Replaced filters, cleaned heat exchangers, checked refrigerant levels. All systems operating within normal parameters.', 'Actioned');

-- ===================
-- Sample Lists
-- ===================
INSERT INTO lists (list_id_display, list_name, list_type, site_id, owner_user_id, status)
VALUES 
('LST001', 'Daily Operational Checklist', 'Master Task List (Template)', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM flrts_users WHERE user_id_display = 'U001'), 'Active'),
('LST002', 'Facility Tool Inventory', 'Tools Inventory', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), 'Active'),
('LST003', 'Commissioning Tasks', 'Master Task List (Template)', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM flrts_users WHERE user_id_display = 'U003'), 'Active');

-- ===================
-- Sample List Items
-- ===================
INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
VALUES 
('LI001', (SELECT id FROM lists WHERE list_id_display = 'LST001'), 'Check ambient temperature', 'Ensure temperature is between 65-85°F', 1, TRUE),
('LI002', (SELECT id FROM lists WHERE list_id_display = 'LST001'), 'Verify all ASICs running', 'Check dashboards and physical indicators', 2, TRUE),
('LI003', (SELECT id FROM lists WHERE list_id_display = 'LST001'), 'Inspect cooling systems', 'Check for leaks or unusual noises', 3, TRUE),
('LI004', (SELECT id FROM lists WHERE list_id_display = 'LST002'), 'Network cable tester', 'Located in storage cabinet A', 1, TRUE),
('LI005', (SELECT id FROM lists WHERE list_id_display = 'LST002'), 'Thermal imaging camera', 'Located in office desk drawer', 2, TRUE);

-- ===================
-- Sample Tasks
-- ===================
INSERT INTO tasks (task_id_display, task_title, task_description_detailed, assigned_to_user_id, site_id, due_date, priority, status)
VALUES 
('TSK001', 'Replace ASIC001 power supply', 'Power supply showing intermittent failures. Replacement parts in storage room B.', (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-05-25', 'Medium', 'To Do'),
('TSK002', 'Calibrate temperature sensors', 'Monthly calibration of temperature sensors throughout facility.', (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-05-20', 'Low', 'In Progress'),
('TSK003', 'Set up new security cameras', 'Install 4 new security cameras at designated locations. See site map for details.', (SELECT id FROM flrts_users WHERE user_id_display = 'U003'), (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-06-01', 'High', 'To Do');

-- ===================
-- Sample Reminders
-- ===================
INSERT INTO reminders (reminder_id_display, reminder_title, reminder_date_time, user_to_remind_id, related_task_id, status)
VALUES 
('REM001', 'Complete temperature sensor calibration', '2025-05-20 09:00:00-05:00', (SELECT id FROM flrts_users WHERE user_id_display = 'U002'), (SELECT id FROM tasks WHERE task_id_display = 'TSK002'), 'Scheduled'),
('REM002', 'Order replacement power supplies', '2025-05-22 10:00:00-05:00', (SELECT id FROM flrts_users WHERE user_id_display = 'U001'), NULL, 'Scheduled'),
('REM003', 'Submit weekly site report', '2025-05-17 16:00:00-05:00', (SELECT id FROM flrts_users WHERE user_id_display = 'U003'), NULL, 'Scheduled');