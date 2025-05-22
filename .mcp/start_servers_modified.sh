#!/bin/bash
# Modified script to start MCP servers for the 10NZ_FLRTS project

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Create log directory if it doesn't exist
LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/server_start_$(date +"%Y%m%d_%H%M%S").log"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "MCP Server Start - $(date)"
echo "=================="

# Check if MCP server configuration is valid
check_config() {
  echo -e "${BLUE}Validating MCP configs...${RESET}"
  
  # Global config
  if [ -f "$HOME/.config/mcp/mcp.json" ]; then
    echo -e "  Global config: $HOME/.config/mcp/mcp.json"
    cat "$HOME/.config/mcp/mcp.json" | jq . > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "  ${RED}❌ Global MCP config is not valid JSON${RESET}"
      echo -e "  ${YELLOW}⚠️  Fix this using:${RESET} editcreds_mcp"
      return 1
    else
      echo -e "  ${GREEN}✅ Global config is valid JSON${RESET}"
    fi
  else
    echo -e "  ${RED}❌ Global MCP config missing: $HOME/.config/mcp/mcp.json${RESET}"
    return 1
  fi
  
  # Project config
  if [ -f "$(dirname "$0")/mcp.json" ]; then
    echo -e "  Project config: $(dirname "$0")/mcp.json"
    cat "$(dirname "$0")/mcp.json" | jq . > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "  ${RED}❌ Project MCP config is not valid JSON${RESET}"
      return 1
    else
      echo -e "  ${GREEN}✅ Project config is valid JSON${RESET}"
    fi
  else
    echo -e "  ${RED}❌ Project MCP config missing: $(dirname "$0")/mcp.json${RESET}"
    return 1
  fi
  
  # Check for duplicate servers
  echo -e "  Checking for duplicate servers..."
  output=$(~/.bin/mcp-project -c 2>&1)
  dups_found=$(echo "$output" | grep -i "Found duplicate servers" | wc -l)
  
  if [ $dups_found -gt 0 ]; then
    echo -e "  ${RED}❌ Duplicate servers detected:${RESET}"
    echo "$output" | grep -i "duplicate" -A 5
    return 1
  else
    echo -e "  ${GREEN}✅ No duplicate servers detected${RESET}"
  fi
  
  return 0
}

# Check environment variables
check_env_vars() {
  local is_global=$1
  local config_path=""
  local editor_command=""
  
  if [ "$is_global" == "true" ]; then
    config_path="$HOME/.config/mcp/.env"
    editor_command="editcreds_mcp"
  else
    config_path="$(dirname "$0")/.env"
    editor_command="editcreds_10nzflrts"
  fi
  
  echo -e "${BLUE}Checking $([ "$is_global" == "true" ] && echo "global" || echo "project") environment variables...${RESET}"
  
  local missing_vars=0
  
  check_env_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [ -z "$var_value" ] || [ "$var_value" == "your_${var_name,,}_here" ]; then
      echo -e "  ${RED}❌ $var_name is not set${RESET}"
      missing_vars=$((missing_vars + 1))
      return 1
    else
      echo -e "  ${GREEN}✅ $var_name is set${RESET}"
      return 0
    fi
  }
  
  # Load environment variables
  source "$(dirname "$0")/load_env.sh" > /dev/null
  
  if [ "$is_global" == "true" ]; then
    # Check global environment variables
    check_env_var "GITHUB_TOKEN"
    check_env_var "BRAVE_API_KEY"
  else
    # Check project-specific environment variables
    check_env_var "TODOIST_API_TOKEN"
    check_env_var "GOOGLE_API_KEY" 
    check_env_var "GOOGLE_CLIENT_ID"
    check_env_var "GOOGLE_CLIENT_SECRET"
    check_env_var "NOLOCO_API_KEY"
    check_env_var "NOLOCO_API_URL"
    check_env_var "TELEGRAM_BOT_TOKEN"
  fi
  
  if [ $missing_vars -gt 0 ]; then
    echo -e "  ${RED}❌ $missing_vars environment variables are missing${RESET}"
    echo -e "  ${YELLOW}⚠️  Edit the .env file using: $editor_command${RESET}"
    return 1
  fi
  
  echo -e "  ${GREEN}✅ All required environment variables are set${RESET}"
  return 0
}

# Skip controller and start MCP servers directly
start_mcp_servers() {
  echo -e "${BLUE}Starting MCP servers...${RESET}"
  
  # Project-specific servers from config file
  echo -e "${CYAN}Starting project-specific MCP servers...${RESET}"
  
  # Read from project mcp.json file
  PROJECT_CONFIG="$(dirname "$0")/mcp.json"
  if [ -f "$PROJECT_CONFIG" ]; then
    # For each server in the project config
    SERVER_COUNT=$(jq '.servers | length' "$PROJECT_CONFIG")
    for ((i=0; i<$SERVER_COUNT; i++)); do
      SERVER_NAME=$(jq -r ".servers[$i].name" "$PROJECT_CONFIG")
      SERVER_CMD=$(jq -r ".servers[$i].command" "$PROJECT_CONFIG")
      
      echo -e "  Starting ${CYAN}$SERVER_NAME${RESET} server..."
      eval "$SERVER_CMD > \"$LOG_DIR/${SERVER_NAME// /_}.log\" 2>&1 &"
      echo -e "  ${GREEN}✅ Started $SERVER_NAME (PID: $!)${RESET}"
      sleep 1  # Brief pause between starting servers
    done
  fi
  
  return 0
}

# Main execution
echo -e "${BLUE}Starting MCP servers for 10NZ_FLRTS project...${RESET}"
echo

# Check configurations
check_config || {
  echo -e "${RED}❌ Configuration check failed${RESET}"
  echo -e "${YELLOW}⚠️  Fix configuration issues before continuing${RESET}"
  exit 1
}

echo

# Check environment variables
check_env_vars "false" || {
  echo -e "${RED}❌ Project environment variable check failed${RESET}"
  echo -e "${YELLOW}⚠️  Set required environment variables before continuing${RESET}"
  exit 1
}

check_env_vars "true" || {
  echo -e "${YELLOW}⚠️  Global environment variable check found issues${RESET}"
  echo -e "${YELLOW}⚠️  Some global MCPs may not function properly${RESET}"
  # Continue anyway as global MCPs might not be critical
}

echo

# Start MCP servers
start_mcp_servers

echo
echo -e "${GREEN}✅ MCP servers started successfully${RESET}"
echo -e "${BLUE}Run './.mcp/check_servers.sh' to verify all servers are running${RESET}"
echo -e "Log saved to: ${LOG_FILE}"