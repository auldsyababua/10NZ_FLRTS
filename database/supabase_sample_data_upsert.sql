-- ==========================================
-- 10NetZero-FLRTS: Sample Data for Testing with UPSERT
-- ==========================================
-- Version: 1.0
-- Date: May 21, 2025
-- Description: Sample data to test the 10NetZero-FLRTS schema using ON CONFLICT DO NOTHING

-- ===================
-- Sample Operators
-- ===================
INSERT INTO operators (operator_id_display, operator_name, operator_type)
VALUES 
('OP001', '10NetZero Operations', 'Internal (10NetZero)'),
('OP002', 'GreenMine Management', 'Third-Party')
ON CONFLICT (operator_id_display) DO NOTHING;

-- ===================
-- Sample Sites
-- ===================
INSERT INTO sites (site_id_display, site_name, site_address_street, site_address_city, site_address_state, site_address_zip, site_latitude, site_longitude, site_status, operator_id)
VALUES 
('S001', 'North Austin Facility', '123 Tech Ridge Blvd', 'Austin', 'TX', '78758', 30.4133, -97.6667, 'Running', (SELECT id FROM operators WHERE operator_id_display = 'OP001')),
('S002', 'West Houston Mining Center', '456 Energy Drive', 'Houston', 'TX', '77082', 29.7604, -95.3698, 'Commissioning', (SELECT id FROM operators WHERE operator_id_display = 'OP002')),
('S003', 'Phoenix Expansion Site', '789 Desert Way', 'Phoenix', 'AZ', '85001', 33.4484, -112.0740, 'Contracted', (SELECT id FROM operators WHERE operator_id_display = 'OP001'))
ON CONFLICT (site_id_display) DO NOTHING;

-- ===================
-- Sample Site Aliases
-- ===================
INSERT INTO site_aliases (site_id, alias_name)
SELECT id, 'NAF' FROM sites WHERE site_id_display = 'S001'
ON CONFLICT ON CONSTRAINT site_aliases_site_id_alias_name_key DO NOTHING;

INSERT INTO site_aliases (site_id, alias_name)
SELECT id, 'Austin-1' FROM sites WHERE site_id_display = 'S001'
ON CONFLICT ON CONSTRAINT site_aliases_site_id_alias_name_key DO NOTHING;

INSERT INTO site_aliases (site_id, alias_name)
SELECT id, 'Houston-West' FROM sites WHERE site_id_display = 'S002'
ON CONFLICT ON CONSTRAINT site_aliases_site_id_alias_name_key DO NOTHING;

-- ===================
-- Sample Partners
-- ===================
INSERT INTO partners (partner_id_display, partner_name, partner_type, primary_contact_name, primary_contact_email, is_active)
VALUES 
('P001', 'GreenEnergy Capital', 'Investor', 'Sarah Johnson', 'sarah@greenenergy.example.com', TRUE),
('P002', 'TechFund Ventures', 'Investor', 'Michael Chen', 'mchen@techfund.example.com', TRUE),
('P003', 'CleanPower Co-op', 'Community', 'David Williams', 'david@cleanpower.example.com', TRUE)
ON CONFLICT (partner_id_display) DO NOTHING;

-- ===================
-- Sample Vendors
-- ===================
INSERT INTO vendors (vendor_id_display, vendor_name, vendor_category, primary_contact_name, preferred_vendor, is_active)
VALUES 
('V001', 'MiningTech Equipment', 'Hardware', 'Robert Smith', TRUE, TRUE),
('V002', 'CoolSystems Inc', 'Hardware', 'Jennifer Brown', TRUE, TRUE),
('V003', 'PowerGrid Solutions', 'Services', 'Thomas Wilson', FALSE, TRUE),
('V004', 'SecureNet Systems', 'Services', 'Lisa Garcia', FALSE, TRUE)
ON CONFLICT (vendor_id_display) DO NOTHING;

-- ===================
-- Sample Personnel
-- ===================
INSERT INTO personnel (personnel_id_display, first_name, last_name, email, phone_number, job_title, personnel_type, primary_site_id)
VALUES 
('P001', 'John', 'Doe', 'john.doe@10netzero.example.com', '512-555-1234', 'Site Manager', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S001')),
('P002', 'Jane', 'Smith', 'jane.smith@10netzero.example.com', '512-555-5678', 'Field Technician', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S001')),
('P003', 'Alex', 'Johnson', 'alex.johnson@10netzero.example.com', '713-555-9012', 'Site Manager', 'Employee', (SELECT id FROM sites WHERE site_id_display = 'S002')),
('P004', 'Maria', 'Rodriguez', 'maria.rodriguez@consultant.example.com', '602-555-3456', 'HVAC Specialist', 'Contractor', (SELECT id FROM sites WHERE site_id_display = 'S003'))
ON CONFLICT (personnel_id_display) DO NOTHING;

-- ===================
-- Sample FLRTS Users
-- ===================
INSERT INTO flrts_users (user_id_display, personnel_id, telegram_username, noloco_user_email, user_role_flrts, is_active_flrts_user)
SELECT 
  'U001', 
  p.id, 
  'johndoe_10nz', 
  'john.doe@10netzero.example.com', 
  'Site Manager', 
  TRUE
FROM personnel p WHERE p.personnel_id_display = 'P001'
ON CONFLICT (user_id_display) DO NOTHING;

INSERT INTO flrts_users (user_id_display, personnel_id, telegram_username, noloco_user_email, user_role_flrts, is_active_flrts_user)
SELECT 
  'U002', 
  p.id, 
  'janesmith_10nz', 
  'jane.smith@10netzero.example.com', 
  'Field Technician', 
  TRUE
FROM personnel p WHERE p.personnel_id_display = 'P002'
ON CONFLICT (user_id_display) DO NOTHING;

INSERT INTO flrts_users (user_id_display, personnel_id, telegram_username, noloco_user_email, user_role_flrts, is_active_flrts_user)
SELECT 
  'U003', 
  p.id, 
  'alexj_10nz', 
  'alex.johnson@10netzero.example.com', 
  'Site Manager', 
  TRUE
FROM personnel p WHERE p.personnel_id_display = 'P003'
ON CONFLICT (user_id_display) DO NOTHING;

INSERT INTO flrts_users (user_id_display, personnel_id, telegram_username, noloco_user_email, user_role_flrts, is_active_flrts_user)
SELECT 
  'U004', 
  p.id, 
  NULL, 
  'maria.rodriguez@consultant.example.com', 
  'Field Technician', 
  TRUE
FROM personnel p WHERE p.personnel_id_display = 'P004'
ON CONFLICT (user_id_display) DO NOTHING;

-- ===================
-- Sample Site-Partner Assignments
-- ===================
INSERT INTO site_partner_assignments (assignment_id_display, site_id, partner_id, role_of_partner_at_site, markup_percentage)
VALUES 
('SPA001', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM partners WHERE partner_id_display = 'P001'), 'Primary Investor', 15.00),
('SPA002', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM partners WHERE partner_id_display = 'P002'), 'Primary Investor', 12.50),
('SPA003', (SELECT id FROM sites WHERE site_id_display = 'S003'), (SELECT id FROM partners WHERE partner_id_display = 'P003'), 'Community Partnership', 7.50),
('SPA004', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM partners WHERE partner_id_display = 'P003'), 'Secondary Partner', 5.00)
ON CONFLICT (assignment_id_display) DO NOTHING;

-- ===================
-- Sample Site-Vendor Assignments
-- ===================
INSERT INTO site_vendor_assignments (assignment_id_display, site_id, vendor_id, services_products_provided_at_site)
VALUES 
('SVA001', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), 'ASIC hardware and maintenance'),
('SVA002', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V002'), 'Cooling systems and maintenance'),
('SVA003', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), 'ASIC hardware'),
('SVA004', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), 'Power infrastructure'),
('SVA005', (SELECT id FROM sites WHERE site_id_display = 'S003'), (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), 'Security systems installation')
ON CONFLICT (assignment_id_display) DO NOTHING;

-- ===================
-- Sample Vendor Invoices
-- ===================
INSERT INTO vendor_invoices (vendor_invoice_id_display, status, vendor_id, site_id, invoice_date, invoice_number, original_amount, due_date)
VALUES 
('VI001', 'Received', (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-04-15', 'MT-2025-042', 45000.00, '2025-05-15'),
('VI002', 'Approved', (SELECT id FROM vendors WHERE vendor_id_display = 'V002'), (SELECT id FROM sites WHERE site_id_display = 'S001'), '2025-04-20', 'CS-10458', 12500.00, '2025-05-20'),
('VI003', 'Processing', (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-04-25', 'MT-2025-051', 75000.00, '2025-05-25'),
('VI004', 'Draft', (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), (SELECT id FROM sites WHERE site_id_display = 'S002'), '2025-05-01', 'PG-2025-15', 32000.00, '2025-06-01'),
('VI005', 'Paid', (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), (SELECT id FROM sites WHERE site_id_display = 'S003'), '2025-03-10', 'SN-2025-022', 18500.00, '2025-04-10')
ON CONFLICT (vendor_invoice_id_display) DO NOTHING;

-- Update the partner_id for invoices (the trigger will calculate markup)
UPDATE vendor_invoices 
SET partner_id = (
    SELECT partner_id FROM site_partner_assignments 
    WHERE site_id = vendor_invoices.site_id 
    AND role_of_partner_at_site LIKE '%Primary%'
    LIMIT 1
)
WHERE vendor_invoice_id_display IN ('VI001', 'VI002', 'VI003', 'VI004')
AND partner_id IS NULL;

UPDATE vendor_invoices 
SET partner_id = (
    SELECT partner_id FROM site_partner_assignments 
    WHERE site_id = vendor_invoices.site_id 
    LIMIT 1
)
WHERE vendor_invoice_id_display = 'VI005'
AND partner_id IS NULL;

-- ===================
-- Sample Equipment
-- ===================
INSERT INTO equipment (equipment_id_display, equipment_name, equipment_type, site_location_id, vendor_id, date_purchased, status)
VALUES 
('EQ001', 'Industrial Network Switch 48-port', 'Networking', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'Operational'),
('EQ002', 'Backup Generator 50kW', 'Power Supply', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V003'), '2025-01-20', 'Operational'),
('EQ003', 'Security Camera System', 'Security', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V004'), '2025-02-10', 'Operational')
ON CONFLICT (equipment_id_display) DO NOTHING;

-- ===================
-- Sample ASICs
-- ===================
INSERT INTO asics (asic_id_display, asic_name_model, site_location_id, vendor_id, date_purchased, serial_number, status, nominal_hashrate_th)
VALUES 
('ASIC001', 'MiningMaster Pro X1', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'MMX1-2025-001', 'Operational/Mining', 110.5),
('ASIC002', 'MiningMaster Pro X1', (SELECT id FROM sites WHERE site_id_display = 'S001'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-01-15', 'MMX1-2025-002', 'Operational/Mining', 110.5),
('ASIC003', 'MiningMaster Pro X2', (SELECT id FROM sites WHERE site_id_display = 'S002'), (SELECT id FROM vendors WHERE vendor_id_display = 'V001'), '2025-03-01', 'MMX2-2025-001', 'Idle', 125.0)
ON CONFLICT (asic_id_display) DO NOTHING;

-- ===================
-- Sample Field Reports
-- ===================
INSERT INTO field_reports (report_id_display, site_id, report_date, submitted_by_user_id, report_type, report_title_summary, report_content_full, report_status)
SELECT
  'FR001',
  s.id,
  '2025-05-01',
  u.id,
  'Daily Operational Summary',
  'Daily checks complete - all systems normal',
  'Completed daily checklist for North Austin Facility. All systems operational. Temperature ranges normal. No incidents to report.',
  'Submitted'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S001'
AND u.user_id_display = 'U002'
ON CONFLICT (report_id_display) DO NOTHING;

INSERT INTO field_reports (report_id_display, site_id, report_date, submitted_by_user_id, report_type, report_title_summary, report_content_full, report_status)
SELECT
  'FR002',
  s.id,
  '2025-05-05',
  u.id,
  'Incident Report',
  'Brief power fluctuation at 14:30',
  'Experienced power fluctuation at approximately 14:30. Lasted about 3 seconds. All ASICs rebooted successfully. No permanent issues detected. Local utility company contacted to inquire about grid status.',
  'Under Review'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S001'
AND u.user_id_display = 'U002'
ON CONFLICT (report_id_display) DO NOTHING;

INSERT INTO field_reports (report_id_display, site_id, report_date, submitted_by_user_id, report_type, report_title_summary, report_content_full, report_status)
SELECT
  'FR003',
  s.id,
  '2025-05-10',
  u.id,
  'Maintenance Log',
  'Cooling system maintenance performed',
  'Scheduled maintenance performed on cooling systems. Replaced filters, cleaned heat exchangers, checked refrigerant levels. All systems operating within normal parameters.',
  'Actioned'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S002'
AND u.user_id_display = 'U003'
ON CONFLICT (report_id_display) DO NOTHING;

-- ===================
-- Sample Lists
-- ===================
INSERT INTO lists (list_id_display, list_name, list_type, site_id, owner_user_id, status)
SELECT
  'LST001',
  'Daily Operational Checklist',
  'Master Task List (Template)',
  s.id,
  u.id,
  'Active'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S001'
AND u.user_id_display = 'U001'
ON CONFLICT (list_id_display) DO NOTHING;

INSERT INTO lists (list_id_display, list_name, list_type, site_id, owner_user_id, status)
SELECT
  'LST002',
  'Facility Tool Inventory',
  'Tools Inventory',
  s.id,
  u.id,
  'Active'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S001'
AND u.user_id_display = 'U002'
ON CONFLICT (list_id_display) DO NOTHING;

INSERT INTO lists (list_id_display, list_name, list_type, site_id, owner_user_id, status)
SELECT
  'LST003',
  'Commissioning Tasks',
  'Master Task List (Template)',
  s.id,
  u.id,
  'Active'
FROM sites s, flrts_users u
WHERE s.site_id_display = 'S002'
AND u.user_id_display = 'U003'
ON CONFLICT (list_id_display) DO NOTHING;

-- ===================
-- Sample List Items
-- ===================
INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
SELECT
  'LI001',
  l.id,
  'Check ambient temperature',
  'Ensure temperature is between 65-85°F',
  1,
  TRUE
FROM lists l
WHERE l.list_id_display = 'LST001'
ON CONFLICT (list_item_id_display) DO NOTHING;

INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
SELECT
  'LI002',
  l.id,
  'Verify all ASICs running',
  'Check dashboards and physical indicators',
  2,
  TRUE
FROM lists l
WHERE l.list_id_display = 'LST001'
ON CONFLICT (list_item_id_display) DO NOTHING;

INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
SELECT
  'LI003',
  l.id,
  'Inspect cooling systems',
  'Check for leaks or unusual noises',
  3,
  TRUE
FROM lists l
WHERE l.list_id_display = 'LST001'
ON CONFLICT (list_item_id_display) DO NOTHING;

INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
SELECT
  'LI004',
  l.id,
  'Network cable tester',
  'Located in storage cabinet A',
  1,
  TRUE
FROM lists l
WHERE l.list_id_display = 'LST002'
ON CONFLICT (list_item_id_display) DO NOTHING;

INSERT INTO list_items (list_item_id_display, parent_list_id, item_name_primary_text, item_detail_1_text, item_order, is_complete_or_checked)
SELECT
  'LI005',
  l.id,
  'Thermal imaging camera',
  'Located in office desk drawer',
  2,
  TRUE
FROM lists l
WHERE l.list_id_display = 'LST002'
ON CONFLICT (list_item_id_display) DO NOTHING;

-- ===================
-- Sample Tasks
-- ===================
INSERT INTO tasks (task_id_display, task_title, task_description_detailed, assigned_to_user_id, site_id, due_date, priority, status)
SELECT
  'TSK001',
  'Replace ASIC001 power supply',
  'Power supply showing intermittent failures. Replacement parts in storage room B.',
  u.id,
  s.id,
  '2025-05-25',
  'Medium',
  'To Do'
FROM flrts_users u, sites s
WHERE u.user_id_display = 'U002'
AND s.site_id_display = 'S001'
ON CONFLICT (task_id_display) DO NOTHING;

INSERT INTO tasks (task_id_display, task_title, task_description_detailed, assigned_to_user_id, site_id, due_date, priority, status)
SELECT
  'TSK002',
  'Calibrate temperature sensors',
  'Monthly calibration of temperature sensors throughout facility.',
  u.id,
  s.id,
  '2025-05-20',
  'Low',
  'In Progress'
FROM flrts_users u, sites s
WHERE u.user_id_display = 'U002'
AND s.site_id_display = 'S001'
ON CONFLICT (task_id_display) DO NOTHING;

INSERT INTO tasks (task_id_display, task_title, task_description_detailed, assigned_to_user_id, site_id, due_date, priority, status)
SELECT
  'TSK003',
  'Set up new security cameras',
  'Install 4 new security cameras at designated locations. See site map for details.',
  u.id,
  s.id,
  '2025-06-01',
  'High',
  'To Do'
FROM flrts_users u, sites s
WHERE u.user_id_display = 'U003'
AND s.site_id_display = 'S002'
ON CONFLICT (task_id_display) DO NOTHING;

-- ===================
-- Sample Reminders
-- ===================
INSERT INTO reminders (reminder_id_display, reminder_title, reminder_date_time, user_to_remind_id, related_task_id, status)
SELECT
  'REM001',
  'Complete temperature sensor calibration',
  '2025-05-20 09:00:00-05:00',
  u.id,
  t.id,
  'Scheduled'
FROM flrts_users u, tasks t
WHERE u.user_id_display = 'U002'
AND t.task_id_display = 'TSK002'
ON CONFLICT (reminder_id_display) DO NOTHING;

INSERT INTO reminders (reminder_id_display, reminder_title, reminder_date_time, user_to_remind_id, status)
SELECT
  'REM002',
  'Order replacement power supplies',
  '2025-05-22 10:00:00-05:00',
  u.id,
  'Scheduled'
FROM flrts_users u
WHERE u.user_id_display = 'U001'
ON CONFLICT (reminder_id_display) DO NOTHING;

INSERT INTO reminders (reminder_id_display, reminder_title, reminder_date_time, user_to_remind_id, status)
SELECT
  'REM003',
  'Submit weekly site report',
  '2025-05-17 16:00:00-05:00',
  u.id,
  'Scheduled'
FROM flrts_users u
WHERE u.user_id_display = 'U003'
ON CONFLICT (reminder_id_display) DO NOTHING;

-- ===================
-- Create missing calculate_invoice_markup function
-- ===================
CREATE OR REPLACE FUNCTION calculate_invoice_markup(invoice_uuid UUID)
RETURNS VOID AS $$
DECLARE
    invoice_record RECORD;
    markup_pct DECIMAL(5,2);
BEGIN
    -- Get the invoice record
    SELECT * INTO invoice_record
    FROM vendor_invoices
    WHERE id = invoice_uuid;
    
    -- If no partner is set, we can't calculate markup
    IF invoice_record.partner_id IS NULL THEN
        RETURN;
    END IF;
    
    -- Get the markup percentage for this site-partner combination
    SELECT spa.markup_percentage INTO markup_pct
    FROM site_partner_assignments spa
    WHERE spa.site_id = invoice_record.site_id
    AND spa.partner_id = invoice_record.partner_id;
    
    -- If no markup percentage is found, use 0
    IF markup_pct IS NULL THEN
        markup_pct := 0;
    END IF;
    
    -- Update the invoice with the calculated values
    UPDATE vendor_invoices
    SET markup_percentage = markup_pct,
        markup_amount = ROUND(original_amount * markup_pct / 100, 2),
        final_amount = original_amount + ROUND(original_amount * markup_pct / 100, 2),
        updated_at = NOW()
    WHERE id = invoice_uuid;
END;
$$ LANGUAGE plpgsql;

-- Make sure we have the trigger for vendor_invoices
CREATE OR REPLACE FUNCTION update_billing_after_invoice_change()
RETURNS TRIGGER AS $$
BEGIN
    -- If this is a new record or partner_id is changed, calculate markup
    IF (TG_OP = 'INSERT') OR (OLD.partner_id IS DISTINCT FROM NEW.partner_id) OR
       (OLD.original_amount IS DISTINCT FROM NEW.original_amount) THEN
        PERFORM calculate_invoice_markup(NEW.id);
    END IF;
    
    -- Create or update the corresponding partner billing
    PERFORM create_partner_billing(NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'vendor_invoices_after_change_trigger'
    ) THEN
        CREATE TRIGGER vendor_invoices_after_change_trigger
        AFTER INSERT OR UPDATE ON vendor_invoices
        FOR EACH ROW
        EXECUTE FUNCTION update_billing_after_invoice_change();
    END IF;
END $$;

-- Create the trigger for assignments if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'site_partner_assignments_after_change_trigger'
    ) THEN
        CREATE TRIGGER site_partner_assignments_after_change_trigger
        AFTER UPDATE ON site_partner_assignments
        FOR EACH ROW
        EXECUTE FUNCTION update_invoices_after_assignment_change();
    END IF;
END $$;

-- Call recalculate_all_markups to ensure all invoices have markup calculated
SELECT recalculate_all_markups();