# Pushing the 10NetZero-FLRTS Schema to Supabase

## Secure Method Using 1Password

This guide explains how to push the PostgreSQL schema to your Supabase project using the secure 1Password-managed API keys.

### Step 1: Get Your Credentials

1. Get your Supabase project URL:
   ```bash
   key supabaseurl
   ```
   This will copy the URL to your clipboard.

2. Export it as an environment variable:
   ```bash
   export SUPABASE_URL=<paste_url_here>
   ```

3. Get your Supabase access token:
   ```bash
   key supabase
   ```
   This will copy the token to your clipboard.

4. Export it as an environment variable:
   ```bash
   export SUPABASE_KEY=<paste_token_here>
   ```

### Step 2: Run the Migration Script

Once you have the environment variables set, run:

```bash
./push_schema.sh apply
```

This will:
1. Combine all SQL files (main schema, updates, and sample data)
2. Log in to Supabase CLI using your API key
3. Link to your Supabase project
4. Push the schema to your database

### Verifying the Migration

After pushing the schema, you can verify it by:

1. Logging into your Supabase dashboard at https://app.supabase.com
2. Go to your project
3. Click on "Table Editor" to see your tables
4. Check that key tables like `sites`, `partners`, and `vendor_invoices` exist

### Testing the Markup Manager

To test the markup manager functionality:

1. Create a new vendor invoice on a site that has a partner assigned
2. Verify that markup is automatically calculated
3. Check that a partner billing record is created

### Troubleshooting

If you encounter issues:

1. Check the Supabase SQL Editor logs
2. Verify your API key has proper permissions
3. Make sure your project reference is correct
4. Try executing the SQL in smaller chunks through the Supabase SQL Editor interface

### Alternative Methods

If the script doesn't work, you can:

1. Use the Supabase SQL Editor directly
   - Go to https://app.supabase.com
   - Click on "SQL" in the left sidebar
   - Paste the SQL from each file and execute it

2. Use the Supabase JavaScript client:
   ```javascript
   const { createClient } = require('@supabase/supabase-js')
   const supabase = createClient(url, key)
   const { data, error } = await supabase.rpc('execute_sql', { sql: sqlString })
   ```