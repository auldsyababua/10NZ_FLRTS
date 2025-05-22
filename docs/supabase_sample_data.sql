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
('V002', 'CoolSystems Inc', 'Hardware', 'Jennifer Brown', TRUE, TRUE),
('V003', 'PowerGrid Solutions', 'Services', 'Thomas Wilson', FALSE, TRUE),
('V004', 'SecureNet Systems', 'Services', 'Lisa Garcia', FALSE, TRUE);

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