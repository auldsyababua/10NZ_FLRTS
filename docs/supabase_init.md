# Manually Applying the 10NetZero-FLRTS Schema to Supabase

Since direct API access is not working with the current credentials, you will need to apply the schema manually through the Supabase dashboard. Follow these steps:

## 1. Check Project Settings

First, ensure you have the right Supabase project:
- Project URL: https://thnwlykidzhrsagyjncc.supabase.co
- Access Token: The token in your .mcp/.env file

## 2. Apply the SQL Schema

1. Log in to the [Supabase Dashboard](https://app.supabase.com)
2. Navigate to your project
3. Click on "SQL Editor" in the left sidebar
4. Create a new query

## 3. Execute the SQL Scripts in Order

Execute the SQL files in this specific order:

### Step 1: Create the Schema

1. Open `/Users/colinaulds/Desktop/projects/10NZ_FLRTS/supabase_schema.sql`
2. Copy the entire content
3. Paste into the SQL Editor
4. Click "Run" button
5. Wait for completion (this may take a minute)

### Step 2: Apply Schema Updates

1. Open `/Users/colinaulds/Desktop/projects/10NZ_FLRTS/supabase_schema_update.sql`
2. Copy the entire content
3. Paste into a new SQL Editor query
4. Click "Run" button
5. Wait for completion

### Step 3: Load Sample Data (Optional)

1. Open `/Users/colinaulds/Desktop/projects/10NZ_FLRTS/supabase_sample_data.sql`
2. Copy the entire content
3. Paste into a new SQL Editor query
4. Click "Run" button
5. Wait for completion

## 4. Verify Schema Implementation

After executing all scripts, verify by:

1. Go to "Table Editor" in the left sidebar
2. You should see tables like:
   - sites
   - partners
   - vendors
   - site_partner_assignments
   - vendor_invoices
   - personnel
   - and more...

## 5. Test Markup Manager Business Logic

Test the markup management functionality by:

1. Go to the SQL Editor
2. Run the following insert query:

```sql
INSERT INTO vendor_invoices (
    vendor_invoice_id_display, 
    status, 
    vendor_id, 
    site_id, 
    invoice_date, 
    invoice_number, 
    original_amount, 
    due_date
)
SELECT 
    'VI-TEST-001', 
    'Received', 
    v.id AS vendor_id, 
    s.id AS site_id, 
    CURRENT_DATE, 
    'TEST-001', 
    5000.00, 
    CURRENT_DATE + INTERVAL '30 days'
FROM 
    sites s, vendors v, site_partner_assignments spa
WHERE 
    s.id = spa.site_id
    AND spa.assignment_active = TRUE
LIMIT 1;
```

3. Verify that the markup was automatically calculated by checking:

```sql
SELECT 
    vi.vendor_invoice_id_display, 
    vi.original_amount, 
    vi.markup_percentage, 
    vi.markup_amount, 
    vi.final_amount,
    pb.partner_billing_id_display,
    pb.total_amount
FROM 
    vendor_invoices vi
LEFT JOIN 
    partner_billings pb ON vi.id = pb.vendor_invoice_id
WHERE 
    vi.vendor_invoice_id_display = 'VI-TEST-001';
```

## Troubleshooting

If you encounter errors:

1. **Extension errors**: Ensure the required extensions are enabled in Supabase
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "pgcrypto";
   ```

2. **Table creation order issues**: If you get foreign key constraint errors, execute the schema in smaller chunks, starting with tables that don't depend on others

3. **Function errors**: If trigger functions cause errors, check PostgreSQL version compatibility

For any other issues, refer to the detailed Supabase PostgreSQL schema in `noloco_appendix_a.md`.