#!/bin/bash
# Load environment variables for 10NZ_FLRTS project MCPs

# Source global MCP environment variables first
source ~/.config/mcp/load_env.sh

# Project-specific environment variables
if [ -f "$PWD/.mcp/.env" ]; then
  set -a
  source "$PWD/.mcp/.env"
  set +a
  echo "✅ Project-specific environment variables loaded"
fi

echo "✅ All environment variables loaded for 10NZ_FLRTS project"