#!/bin/bash

# ==========================================
# 10NetZero-FLRTS: Push Schema to Supabase
# ==========================================
# Version: 1.0
# Date: May 21, 2025
# Description: Script to push schema to Supabase using credentials from .env

# Load environment variables from .mcp/.env
if [ -f ".mcp/.env" ]; then
  echo "Loading environment variables from .mcp/.env"
  source .mcp/.env
else
  echo "Error: .mcp/.env file not found"
  exit 1
fi

# Check for required environment variables
if [ -z "$SUPABASE_PROJECT_URL" ]; then
  echo "Error: SUPABASE_PROJECT_URL environment variable not set in .mcp/.env"
  exit 1
fi

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
  echo "Error: SUPABASE_ACCESS_TOKEN environment variable not set in .mcp/.env"
  exit 1
fi

# Verify read-only mode is disabled
if [ "$SUPABASE_READ_ONLY" = "true" ]; then
  echo "Error: SUPABASE_READ_ONLY is set to true. Set it to false to allow write operations."
  exit 1
fi

echo "Supabase project URL: $SUPABASE_PROJECT_URL"
echo "Using Supabase access token: ${SUPABASE_ACCESS_TOKEN:0:5}...${SUPABASE_ACCESS_TOKEN: -5}"
echo "Read-only mode: $SUPABASE_READ_ONLY"

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
export SUPABASE_ACCESS_TOKEN
supabase login

# Extract project reference from URL
PROJECT_REF=$(echo "$SUPABASE_PROJECT_URL" | sed -E 's/.*\/\/([^.]+).*/\1/')
if [ -z "$PROJECT_REF" ]; then
  echo "Error: Could not extract project reference from URL: $SUPABASE_PROJECT_URL"
  echo "Trying alternative extraction method..."
  PROJECT_REF=$(echo "$SUPABASE_PROJECT_URL" | awk -F[/:] '{print $4}')
  if [ -z "$PROJECT_REF" ]; then
    echo "Error: Could not extract project reference from URL: $SUPABASE_PROJECT_URL"
    exit 1
  fi
fi

echo "Using project reference: $PROJECT_REF"

# Create/update migration file
MIGRATION_DIR="supabase/migrations"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
MIGRATION_FILE="$MIGRATION_DIR/${TIMESTAMP}_schema_migration.sql"

# Create migration directory if it doesn't exist
mkdir -p "$MIGRATION_DIR"

# Copy the combined SQL to the migration file
cp "$COMBINED_SQL" "$MIGRATION_FILE"
echo "Created migration file: $MIGRATION_FILE"

# Link to the project
echo "Linking to Supabase project..."
supabase link --project-ref "$PROJECT_REF"

# Execute the schema SQL via migration
echo "Pushing schema migration..."
supabase db push

echo "Schema push completed successfully!"