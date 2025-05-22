#!/bin/bash
# MCP Server Troubleshooting Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Create log directory if it doesn't exist
LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/troubleshoot_$(date +"%Y%m%d_%H%M%S").log"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "MCP Server Troubleshooting - $(date)"
echo "============================="

# Function to check system requirements
check_system() {
  echo -e "${MAGENTA}[1/6] Checking system requirements...${RESET}"
  
  # Check for required commands
  for cmd in jq node npm nc; do
    if ! command -v $cmd &> /dev/null; then
      echo -e "  ${RED}❌ Required command not found: $cmd${RESET}"
      case $cmd in
        jq)
          echo -e "  ${YELLOW}⚠️  Install with: brew install jq${RESET}"
          ;;
        node|npm)
          echo -e "  ${YELLOW}⚠️  Install with: brew install node${RESET}"
          ;;
        nc)
          echo -e "  ${YELLOW}⚠️  Install with: brew install netcat${RESET}"
          ;;
      esac
    else
      echo -e "  ${GREEN}✅ $cmd is installed${RESET}"
    fi
  done
  
  # Check for MCP command line tools
  if [ -x "$HOME/.bin/mcp-project" ]; then
    echo -e "  ${GREEN}✅ MCP Project tool found${RESET}"
  else
    echo -e "  ${RED}❌ MCP Project tool not found at ~/.bin/mcp-project${RESET}"
  fi
  
  if command -v mcpc &> /dev/null; then
    echo -e "  ${GREEN}✅ MCP Controller command found${RESET}"
  else
    echo -e "  ${RED}❌ MCP Controller command not found${RESET}"
    echo -e "  ${YELLOW}⚠️  Install with: npm install -g @modelcontextprotocol/controller${RESET}"
  fi
  
  # Check disk space
  disk_space=$(df -h . | awk 'NR==2 {print $4}')
  echo -e "  ${BLUE}ℹ️  Available disk space: $disk_space${RESET}"
  
  # Check memory
  mem_info=$(vm_stat | grep "Pages free:" | awk '{print $3}' | sed 's/\.//')
  free_mem=$((mem_info * 4096 / 1024 / 1024))
  echo -e "  ${BLUE}ℹ️  Available memory: $free_mem MB${RESET}"
  
  echo
}

# Function to check configuration files
check_config_files() {
  echo -e "${MAGENTA}[2/6] Checking configuration files...${RESET}"
  
  # Check global config
  echo -e "${BLUE}Global MCP configuration:${RESET}"
  if [ -f "$HOME/.config/mcp/mcp.json" ]; then
    echo -e "  ${GREEN}✅ File exists: $HOME/.config/mcp/mcp.json${RESET}"
    
    # Check if the config is valid JSON
    cat "$HOME/.config/mcp/mcp.json" | jq . > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "  ${GREEN}✅ Valid JSON format${RESET}"
      
      # Count number of servers
      server_count=$(cat "$HOME/.config/mcp/mcp.json" | jq '.servers | length')
      echo -e "  ${BLUE}ℹ️  Contains $server_count servers${RESET}"
      
      # List all servers
      echo -e "  ${BLUE}ℹ️  Server names:${RESET}"
      cat "$HOME/.config/mcp/mcp.json" | jq -r '.servers[].name' | sed 's/^/    - /'
    else
      echo -e "  ${RED}❌ Invalid JSON format${RESET}"
      echo -e "  ${YELLOW}⚠️  Fix by running:${RESET} editcreds_mcp"
    fi
  else
    echo -e "  ${RED}❌ File missing: $HOME/.config/mcp/mcp.json${RESET}"
  fi
  
  # Check global environment
  echo -e "${BLUE}Global environment variables:${RESET}"
  if [ -f "$HOME/.config/mcp/.env" ]; then
    echo -e "  ${GREEN}✅ File exists: $HOME/.config/mcp/.env${RESET}"
    
    # Check for common issues
    if grep -q "EOF" "$HOME/.config/mcp/.env"; then
      echo -e "  ${RED}❌ File contains EOF marker (syntax error)${RESET}"
    else
      echo -e "  ${GREEN}✅ No syntax errors detected${RESET}"
    fi
  else
    echo -e "  ${RED}❌ File missing: $HOME/.config/mcp/.env${RESET}"
  fi
  
  # Check project config
  echo -e "${BLUE}Project MCP configuration:${RESET}"
  if [ -f "$(dirname "$0")/mcp.json" ]; then
    echo -e "  ${GREEN}✅ File exists: $(dirname "$0")/mcp.json${RESET}"
    
    # Check if the config is valid JSON
    cat "$(dirname "$0")/mcp.json" | jq . > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "  ${GREEN}✅ Valid JSON format${RESET}"
      
      # Count number of servers
      server_count=$(cat "$(dirname "$0")/mcp.json" | jq '.servers | length')
      echo -e "  ${BLUE}ℹ️  Contains $server_count servers${RESET}"
      
      # List all servers
      echo -e "  ${BLUE}ℹ️  Server names:${RESET}"
      cat "$(dirname "$0")/mcp.json" | jq -r '.servers[].name' | sed 's/^/    - /'
    else
      echo -e "  ${RED}❌ Invalid JSON format${RESET}"
    fi
  else
    echo -e "  ${RED}❌ File missing: $(dirname "$0")/mcp.json${RESET}"
  fi
  
  # Check project environment
  echo -e "${BLUE}Project environment variables:${RESET}"
  if [ -f "$(dirname "$0")/.env" ]; then
    echo -e "  ${GREEN}✅ File exists: $(dirname "$0")/.env${RESET}"
    
    # Check for common issues
    if grep -q "EOF" "$(dirname "$0")/.env"; then
      echo -e "  ${RED}❌ File contains EOF marker (syntax error)${RESET}"
    else
      echo -e "  ${GREEN}✅ No syntax errors detected${RESET}"
    fi
  else
    echo -e "  ${RED}❌ File missing: $(dirname "$0")/.env${RESET}"
  fi
  
  echo
}

# Function to check for duplicate MCP servers
check_duplicates() {
  echo -e "${MAGENTA}[3/6] Checking for duplicate MCP servers...${RESET}"
  
  # Run the built-in check
  echo -e "${BLUE}Running MCP project duplicate check:${RESET}"
  ~/.bin/mcp-project -c
  
  # Check for issues with server types
  echo -e "${BLUE}Validating server types:${RESET}"
  
  if [ -f "$(dirname "$0")/mcp.json" ]; then
    # Check for the "type" field in each server entry
    cat "$(dirname "$0")/mcp.json" | jq -r '.servers[] | select(.type == null) | .name' > /tmp/missing_types.txt
    
    if [ -s "/tmp/missing_types.txt" ]; then
      echo -e "  ${YELLOW}⚠️  Servers missing 'type' field:${RESET}"
      cat /tmp/missing_types.txt | sed 's/^/    - /'
      echo -e "  ${YELLOW}⚠️  Consider adding 'type': 'custom' for non-standard MCPs${RESET}"
    else
      echo -e "  ${GREEN}✅ All servers have proper type specification${RESET}"
    fi
    
    rm /tmp/missing_types.txt
  fi
  
  echo
}

# Function to check MCP controller
check_controller() {
  echo -e "${MAGENTA}[4/6] Checking MCP controller...${RESET}"
  
  # Check if controller is running
  nc -z localhost 8080 &>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ MCP controller is running on port 8080${RESET}"
    
    # Try to connect to the controller
    curl -s http://localhost:8080/ping > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "  ${GREEN}✅ MCP controller responds to ping${RESET}"
    else
      echo -e "  ${YELLOW}⚠️  MCP controller does not respond to ping${RESET}"
    fi
  else
    echo -e "  ${RED}❌ MCP controller is not running${RESET}"
    echo -e "  ${YELLOW}⚠️  Start with: mcpc start${RESET}"
  fi
  
  # Check controller logs if they exist
  if [ -f "$HOME/.mcp/logs/mcp-controller.log" ]; then
    echo -e "${BLUE}Checking controller logs:${RESET}"
    
    # Count errors and warnings
    error_count=$(grep -i "error" "$HOME/.mcp/logs/mcp-controller.log" | wc -l | tr -d ' ')
    warning_count=$(grep -i "warn" "$HOME/.mcp/logs/mcp-controller.log" | wc -l | tr -d ' ')
    
    echo -e "  ${BLUE}ℹ️  Controller log contains:${RESET}"
    echo -e "    - ${error_count} error entries"
    echo -e "    - ${warning_count} warning entries"
    
    if [ $error_count -gt 0 ]; then
      echo -e "  ${YELLOW}⚠️  Last 3 error entries:${RESET}"
      grep -i "error" "$HOME/.mcp/logs/mcp-controller.log" | tail -n 3 | sed 's/^/    /'
    fi
  else
    echo -e "  ${YELLOW}⚠️  Controller log file not found${RESET}"
    echo -e "  ${YELLOW}⚠️  Expected location: $HOME/.mcp/logs/mcp-controller.log${RESET}"
  fi
  
  echo
}

# Function to check MCP server processes
check_processes() {
  echo -e "${MAGENTA}[5/6] Checking MCP server processes...${RESET}"
  
  # Get all running MCP processes
  echo -e "${BLUE}Currently running MCP processes:${RESET}"
  ps_output=$(ps aux | grep -i "mcp\|modelcontextprotocol" | grep -v grep)
  
  if [ -z "$ps_output" ]; then
    echo -e "  ${RED}❌ No MCP processes found running${RESET}"
  else
    echo "$ps_output" | while read line; do
      # Extract process info
      pid=$(echo "$line" | awk '{print $2}')
      cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
      
      # Try to determine server type
      server_type="Unknown"
      if [[ "$cmd" == *"todoist"* ]]; then
        server_type="Todoist"
      elif [[ "$cmd" == *"googledrive"* ]]; then
        server_type="Google Drive"
      elif [[ "$cmd" == *"noloco"* ]]; then
        server_type="Noloco"
      elif [[ "$cmd" == *"telegram"* ]]; then
        server_type="Telegram"
      elif [[ "$cmd" == *"github"* ]]; then
        server_type="GitHub"
      elif [[ "$cmd" == *"memory"* ]]; then
        server_type="Memory"
      elif [[ "$cmd" == *"filesystem"* ]]; then
        server_type="Filesystem"
      elif [[ "$cmd" == *"controller"* ]]; then
        server_type="Controller"
      fi
      
      # Output process info
      echo -e "  ${GREEN}✅ ${server_type}${RESET} (PID: ${pid})"
    done
  fi
  
  # Check for each expected server
  echo -e "${BLUE}Checking for expected servers:${RESET}"
  
  # Function to check for a specific server
  check_server_process() {
    local server_name="$1"
    local pattern="$2"
    
    if ps aux | grep -i "$pattern" | grep -v grep > /dev/null; then
      echo -e "  ${GREEN}✅ $server_name is running${RESET}"
      return 0
    else
      echo -e "  ${RED}❌ $server_name is NOT running${RESET}"
      return 1
    fi
  }
  
  # Check project-specific servers
  check_server_process "Todoist" "todoist-mcp"
  check_server_process "Google Drive" "googledrive-mcp"
  check_server_process "Noloco" "noloco-mcp"
  check_server_process "Telegram" "telegram-mcp"
  
  # Check global servers
  check_server_process "GitHub" "server-github"
  check_server_process "Filesystem" "server-filesystem"
  check_server_process "Memory" "server-memory"
  
  echo
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
  echo -e "${MAGENTA}[6/6] Troubleshooting recommendations...${RESET}"
  
  # Check for common issues and provide recommendations
  issues_found=0
  
  # Check if controller is running
  nc -z localhost 8080 &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "  ${RED}⚠️  MCP Controller is not running${RESET}"
    echo -e "  ${YELLOW}   Solution: Start the controller with 'mcpc start'${RESET}"
    issues_found=1
  fi
  
  # Check for duplicate servers
  dups=$(~/.bin/mcp-project -c 2>&1 | grep -i duplicate)
  if [ $? -eq 0 ] && [ -n "$dups" ]; then
    echo -e "  ${RED}⚠️  Duplicate MCP servers detected${RESET}"
    echo -e "  ${YELLOW}   Solution: Edit global or project config to remove duplicates${RESET}"
    issues_found=1
  fi
  
  # Check for missing environment variables
  source "$(dirname "$0")/load_env.sh" > /dev/null
  missing_vars=""
  
  # Project-specific vars
  for var in TODOIST_API_TOKEN GOOGLE_API_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET NOLOCO_API_KEY NOLOCO_API_URL TELEGRAM_BOT_TOKEN; do
    if [ -z "${!var}" ] || [ "${!var}" == "your_${var,,}_here" ]; then
      missing_vars="$missing_vars $var"
    fi
  done
  
  if [ -n "$missing_vars" ]; then
    echo -e "  ${RED}⚠️  Missing environment variables:${RESET}$missing_vars"
    echo -e "  ${YELLOW}   Solution: Run 'editcreds_10nzflrts' and set the missing variables${RESET}"
    issues_found=1
  fi
  
  # If any expected server process is missing
  if ! ps aux | grep -i "todoist-mcp\|googledrive-mcp\|noloco-mcp\|telegram-mcp" | grep -v grep > /dev/null; then
    echo -e "  ${RED}⚠️  One or more project MCP servers are not running${RESET}"
    echo -e "  ${YELLOW}   Solution: Run 'runflrtsmcps' to start the servers${RESET}"
    issues_found=1
  fi
  
  # Final recommendations
  if [ $issues_found -eq 0 ]; then
    echo -e "  ${GREEN}✅ No critical issues detected!${RESET}"
    echo -e "  ${BLUE}If you're still experiencing problems:${RESET}"
    echo -e "    1. Try restarting the MCP controller: mcpc stop && mcpc start"
    echo -e "    2. Review logs in $LOG_DIR for more details"
    echo -e "    3. Check the MCP documentation for additional help"
  else
    echo -e "  ${YELLOW}Follow the recommendations above to resolve the issues.${RESET}"
    echo -e "  ${YELLOW}After fixing these issues, run this troubleshooting script again.${RESET}"
  fi
  
  echo
}

# Main execution
check_system
check_config_files
check_duplicates
check_controller
check_processes
provide_recommendations

echo -e "${GREEN}Troubleshooting completed!${RESET}"
echo -e "${BLUE}Log saved to: ${LOG_FILE}${RESET}"