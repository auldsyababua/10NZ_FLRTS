#!/bin/bash
# Display comprehensive help for MCP configuration

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}========================================${RESET}"
echo -e "${BOLD}🔌 MODEL CONTEXT PROTOCOL (MCP) GUIDE${RESET}"
echo -e "${BOLD}========================================${RESET}"
echo

echo -e "${BLUE}${BOLD}AVAILABLE COMMANDS:${RESET}"
echo -e "  ${CYAN}setup10nzflrts${RESET}     - Configure MCPs and check environment"
echo -e "  ${CYAN}runflrtsmcps${RESET}       - Start the MCP servers with detailed error checking"
echo -e "  ${CYAN}check10nzflrts${RESET}     - Check if servers are running correctly"
echo -e "  ${CYAN}debug10nzflrts${RESET}     - Run comprehensive diagnostics and troubleshooting"
echo -e "  ${CYAN}editcreds_10nzflrts${RESET} - Edit project-specific credentials"
echo -e "  ${CYAN}mcpp${RESET}               - Run the MCP project tool directly"
echo
echo -e "${BLUE}${BOLD}PROJECT CONFIGURATION:${RESET}"
echo -e "  Project config: ${YELLOW}/Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/mcp.json${RESET}"
if [ -f "/Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/mcp.json" ]; then
  echo -e "  Project MCPs:"
  cat "/Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/mcp.json" | grep -A 1 "name" | grep -v -- "--" | grep -v "command" | sed 's/.*"name": "\(.*\)",/    - \1/'
fi
echo
echo -e "${BLUE}${BOLD}GLOBAL CONFIGURATION:${RESET}"
echo -e "  Global config: ${YELLOW}~/.config/mcp/mcp.json${RESET}"
if [ -f "$HOME/.config/mcp/mcp.json" ]; then
  echo -e "  Global MCPs:"
  cat "$HOME/.config/mcp/mcp.json" | grep -A 1 "name" | grep -v -- "--" | grep -v "command" | sed 's/.*"name": "\(.*\)",/    - \1/'
fi
echo
echo -e "${BLUE}${BOLD}ENVIRONMENT VARIABLES:${RESET}"
echo -e "  Project .env: ${YELLOW}/Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/.env${RESET}"
echo -e "  Global .env:  ${YELLOW}~/.config/mcp/.env${RESET}"
echo
echo -e "  ${MAGENTA}How environment variables work:${RESET}"
echo -e "  1. Each MCP server requires specific API keys/credentials"
echo -e "  2. Keys are stored in .env files, not in mcp.json (for security)"
echo -e "  3. When MCPs start, they read credentials from environment variables"
echo -e "  4. load_env.sh script loads both global and project-specific variables"
echo -e "  5. Project variables override global ones when both exist"
echo
echo -e "${BLUE}${BOLD}SERVER MANAGEMENT:${RESET}"
echo -e "  ${CYAN}Start controller:${RESET} mcpc start"
echo -e "  ${CYAN}Stop controller:${RESET}  mcpc stop"
echo -e "  ${CYAN}Check server status:${RESET} check10nzflrts"
echo -e "  ${CYAN}Start servers:${RESET} runflrtsmcps"
echo
echo -e "${BLUE}${BOLD}TROUBLESHOOTING:${RESET}"
echo -e "  ${CYAN}Basic check:${RESET} check10nzflrts"
echo -e "  ${CYAN}Advanced diagnostics:${RESET} debug10nzflrts"
echo -e "  ${CYAN}View logs:${RESET} ls -la /Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/logs/"
echo
echo -e "${BLUE}${BOLD}REUSING MCP CONFIGURATION:${RESET}"
echo -e "  To copy this setup to a new project:"
echo -e "  ${YELLOW}/Users/colinaulds/Desktop/projects/10NZ_FLRTS/.mcp/setup_new_project.sh /path/to/new/project [project_name]${RESET}"
echo
echo -e "${BLUE}${BOLD}DOCUMENTATION:${RESET}"
echo -e "  See project README: ${YELLOW}/Users/colinaulds/Desktop/projects/10NZ_FLRTS/README.md${RESET}"
echo