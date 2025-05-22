#!/bin/bash

# ==========================================
# 10NetZero-FLRTS: Push Schema to Supabase
# ==========================================
# Version: 1.0
# Date: May 21, 2025
# Description: Script to push schema to Supabase using 1Password-managed credentials

# Step 1: Get credentials from 1Password
echo "Please run these commands to get your credentials:"
echo ""
echo "  key supabaseurl    # Copy this to clipboard"
echo "  export SUPABASE_URL=<paste_url_here>"
echo ""
echo "  key supabase       # Copy this to clipboard"
echo "  export SUPABASE_KEY=<paste_token_here>"
echo ""
echo "Then run this script again with: ./push_schema.sh apply"
echo ""

# Check if we're asked to apply the schema
if [[ "$1" != "apply" ]]; then
  exit 0
fi

# Check for required environment variables
if [ -z "$SUPABASE_URL" ]; then
  echo "Error: SUPABASE_URL environment variable not set"
  echo "Please run: export SUPABASE_URL=<your_supabase_url>"
  exit 1
fi

if [ -z "$SUPABASE_KEY" ]; then
  echo "Error: SUPABASE_KEY environment variable not set"
  echo "Please run: export SUPABASE_KEY=<your_supabase_key>"
  exit 1
fi

# Check that Supabase CLI is installed
if ! command -v supabase >/dev/null 2>&1; then
  echo "Error: Supabase CLI not found"
  echo "Please install it with: brew install supabase/tap/supabase"
  exit 1
fi

# Define file paths
SCHEMA_FILE="supabase_schema.sql"
UPDATE_FILE="supabase_schema_update.sql"
SAMPLE_DATA_FILE="supabase_sample_data.sql"
COMBINED_SQL="/tmp/combined_schema.sql"

echo "Creating combined SQL file..."
cat "$SCHEMA_FILE" > "$COMBINED_SQL"
echo -e "\n\n-- Schema updates\n\n" >> "$COMBINED_SQL"
cat "$UPDATE_FILE" >> "$COMBINED_SQL"
echo -e "\n\n-- Sample data\n\n" >> "$COMBINED_SQL"
cat "$SAMPLE_DATA_FILE" >> "$COMBINED_SQL"

echo "Logging in to Supabase..."
export SUPABASE_ACCESS_TOKEN="$SUPABASE_KEY"
supabase login

# Extract project reference from URL
PROJECT_REF=$(echo "$SUPABASE_URL" | sed -E 's/.*\.([a-zA-Z0-9-]+)\.supabase\.co.*/\1/')
if [ -z "$PROJECT_REF" ]; then
  echo "Error: Could not extract project reference from URL: $SUPABASE_URL"
  exit 1
fi

echo "Using project reference: $PROJECT_REF"

# Link to the project
echo "Linking to Supabase project..."
supabase link --project-ref "$PROJECT_REF"

# Execute the schema SQL
echo "Executing combined schema SQL..."
supabase db push

echo "Schema push completed successfully!"