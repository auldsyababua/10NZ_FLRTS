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