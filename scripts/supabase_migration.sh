#!/bin/bash

# ==========================================
# 10NetZero-FLRTS: Supabase Schema Migration Script
# ==========================================
# Version: 1.0
# Date: May 21, 2025
# Description: Script to apply the database schema to Supabase

# Set variables
PROJECT_DIR=$(pwd)
SCHEMA_FILE="$PROJECT_DIR/supabase_schema.sql"
UPDATE_FILE="$PROJECT_DIR/supabase_schema_update.sql"
SAMPLE_DATA_FILE="$PROJECT_DIR/supabase_sample_data.sql"
LOG_FILE="$PROJECT_DIR/supabase_migration.log"

# Check if the schema files exist
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file not found at $SCHEMA_FILE"
    exit 1
fi

if [ ! -f "$UPDATE_FILE" ]; then
    echo "Error: Update file not found at $UPDATE_FILE"
    exit 1
fi

# Start logging
echo "=======================================" > "$LOG_FILE"
echo "Migration started: $(date)" >> "$LOG_FILE"
echo "=======================================" >> "$LOG_FILE"

# Verify Supabase MCP is configured
if ! grep -q "Supabase" "$PROJECT_DIR/.mcp/mcp.json"; then
    echo "Error: Supabase MCP not found in .mcp/mcp.json" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Supabase MCP configuration found." | tee -a "$LOG_FILE"

# Check for required environment variables using the 'env' command from .mcp/load_env.sh if available
if [ -f "$PROJECT_DIR/.mcp/load_env.sh" ]; then
    source "$PROJECT_DIR/.mcp/load_env.sh"
fi

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "Error: SUPABASE_ACCESS_TOKEN environment variable not set" | tee -a "$LOG_FILE"
    echo "Please set the variable in the .mcp/.env file or use:" | tee -a "$LOG_FILE"
    echo "export SUPABASE_ACCESS_TOKEN=your_token" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Environment variables verified." | tee -a "$LOG_FILE"

# Run the SQL migration using the Supabase CLI (if installed) or MCP
if command -v supabase &> /dev/null; then
    echo "Using Supabase CLI..." | tee -a "$LOG_FILE"
    
    # Apply main schema
    echo "Applying main schema..." | tee -a "$LOG_FILE"
    supabase db run "$SCHEMA_FILE"
    
    # Apply updates
    echo "Applying schema updates..." | tee -a "$LOG_FILE"
    supabase db run "$UPDATE_FILE"
    
    # Load sample data if file exists
    if [ -f "$SAMPLE_DATA_FILE" ]; then
        echo "Loading sample data..." | tee -a "$LOG_FILE"
        supabase db run "$SAMPLE_DATA_FILE"
    fi
else
    echo "Supabase CLI not found, using MCP approach..." | tee -a "$LOG_FILE"
    
    # Create a temporary directory for the SQL files
    TEMP_DIR=$(mktemp -d)
    COMBINED_SQL="$TEMP_DIR/combined.sql"
    
    # Combine SQL files
    cat "$SCHEMA_FILE" > "$COMBINED_SQL"
    echo "\n\n-- Schema updates\n\n" >> "$COMBINED_SQL"
    cat "$UPDATE_FILE" >> "$COMBINED_SQL"
    
    if [ -f "$SAMPLE_DATA_FILE" ]; then
        echo "\n\n-- Sample data\n\n" >> "$COMBINED_SQL"
        cat "$SAMPLE_DATA_FILE" >> "$COMBINED_SQL"
    fi
    
    # Use Supabase MCP to execute the SQL
    # Create a temporary file with MCP command
    MCP_COMMAND_FILE="$TEMP_DIR/mcp_command.js"
    
    cat > "$MCP_COMMAND_FILE" << EOF
const fs = require('fs');
const { execSQL } = require('@supabase/mcp-server-supabase/dist/utils');

async function run() {
  try {
    const sql = fs.readFileSync('${COMBINED_SQL}', 'utf8');
    console.log('Executing SQL...');
    const result = await execSQL(sql);
    console.log('SQL migration completed successfully');
    return result;
  } catch (error) {
    console.error('Error executing SQL:', error);
    process.exit(1);
  }
}

run();
EOF
    
    # Run the MCP command
    echo "Executing SQL via MCP..." | tee -a "$LOG_FILE"
    node "$MCP_COMMAND_FILE" | tee -a "$LOG_FILE"
    
    # Clean up temp files
    rm -rf "$TEMP_DIR"
fi

echo "=======================================" >> "$LOG_FILE"
echo "Migration completed: $(date)" >> "$LOG_FILE"
echo "=======================================" >> "$LOG_FILE"

echo "Migration completed. See $LOG_FILE for details."