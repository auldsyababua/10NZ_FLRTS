#!/bin/bash
# Script to clone the MCP configuration to a new project

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Check if a destination path is provided
if [ $# -lt 1 ]; then
  echo -e "${RED}Error: No destination project path provided${RESET}"
  echo -e "Usage: $0 /path/to/new/project [project_name]"
  exit 1
fi

DEST_PATH="$1"
# Default project name is the basename of the destination path
PROJECT_NAME="${2:-$(basename "$DEST_PATH")}"

# Check if destination exists
if [ ! -d "$DEST_PATH" ]; then
  echo -e "${YELLOW}Warning: Destination directory does not exist${RESET}"
  echo -e "Would you like to create it? (y/n)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    mkdir -p "$DEST_PATH"
    if [ $? -ne 0 ]; then
      echo -e "${RED}Error: Could not create destination directory${RESET}"
      exit 1
    fi
  else
    echo -e "${RED}Aborted${RESET}"
    exit 1
  fi
fi

# Create .mcp directory
DEST_MCP_DIR="$DEST_PATH/.mcp"
mkdir -p "$DEST_MCP_DIR"

# Copy configuration files
echo -e "${BLUE}Copying MCP configuration files...${RESET}"

# Copy mcp.json with project name update
cat "$(dirname "$0")/mcp.json" | sed "s/10NZ_FLRTS/$PROJECT_NAME/g" > "$DEST_MCP_DIR/mcp.json"
echo -e "${GREEN}✅ Created $DEST_MCP_DIR/mcp.json${RESET}"

# Copy .env-template
cp "$(dirname "$0")/.env-template" "$DEST_MCP_DIR/.env-template"
echo -e "${GREEN}✅ Created $DEST_MCP_DIR/.env-template${RESET}"

# Copy scripts
for script in load_env.sh check_servers.sh start_servers.sh troubleshoot.sh; do
  # Copy with project name and path updates
  cat "$(dirname "$0")/$script" | sed "s|/Users/colinaulds/Desktop/projects/10NZ_FLRTS|$DEST_PATH|g" | sed "s/10NZ_FLRTS/$PROJECT_NAME/g" > "$DEST_MCP_DIR/$script"
  chmod +x "$DEST_MCP_DIR/$script"
  echo -e "${GREEN}✅ Created $DEST_MCP_DIR/$script${RESET}"
done

# Create logs directory
mkdir -p "$DEST_MCP_DIR/logs"
echo -e "${GREEN}✅ Created $DEST_MCP_DIR/logs${RESET}"

# Create .env from template
cp "$DEST_MCP_DIR/.env-template" "$DEST_MCP_DIR/.env"
echo -e "${GREEN}✅ Created $DEST_MCP_DIR/.env${RESET}"

# Create README.md if it doesn't exist
if [ ! -f "$DEST_PATH/README.md" ]; then
  cat > "$DEST_PATH/README.md" << EOL
# $PROJECT_NAME

## MCP Configuration

This project uses the Model Context Protocol (MCP) for integrating with external services like Todoist, Google Drive, Noloco, and Telegram Bot.

### Quick Setup

Configure a new alias in your .zshrc file:

\`\`\`bash
alias setup${PROJECT_NAME,,}='cd $DEST_PATH && ~/.bin/mcp-project -c && source .mcp/load_env.sh && ./.mcp/check_servers.sh'
alias run${PROJECT_NAME,,}mcps='cd $DEST_PATH && ./.mcp/start_servers.sh'
alias check${PROJECT_NAME,,}='cd $DEST_PATH && ./.mcp/check_servers.sh'
alias debug${PROJECT_NAME,,}='cd $DEST_PATH && ./.mcp/troubleshoot.sh'
alias editcreds_${PROJECT_NAME,,}='code $DEST_PATH/.mcp/.env'
\`\`\`

Run \`source ~/.zshrc\` to load the new aliases, then:

1. Run \`editcreds_${PROJECT_NAME,,}\` to set your API keys
2. Run \`setup${PROJECT_NAME,,}\` to configure the MCPs
3. Run \`run${PROJECT_NAME,,}mcps\` to start the MCP servers

### Troubleshooting

If you encounter issues:

1. Run \`check${PROJECT_NAME,,}\` to verify server status
2. Run \`debug${PROJECT_NAME,,}\` for detailed diagnostics
EOL
  echo -e "${GREEN}✅ Created $DEST_PATH/README.md${RESET}"
fi

echo
echo -e "${GREEN}MCP configuration successfully copied to $DEST_PATH/.mcp${RESET}"
echo
echo -e "${BLUE}Next steps:${RESET}"
echo -e "1. Add the following aliases to your .zshrc:"
echo -e "${YELLOW}alias setup${PROJECT_NAME,,}='cd $DEST_PATH && ~/.bin/mcp-project -c && source .mcp/load_env.sh && ./.mcp/check_servers.sh'${RESET}"
echo -e "${YELLOW}alias run${PROJECT_NAME,,}mcps='cd $DEST_PATH && ./.mcp/start_servers.sh'${RESET}"
echo -e "${YELLOW}alias check${PROJECT_NAME,,}='cd $DEST_PATH && ./.mcp/check_servers.sh'${RESET}"
echo -e "${YELLOW}alias debug${PROJECT_NAME,,}='cd $DEST_PATH && ./.mcp/troubleshoot.sh'${RESET}"
echo -e "${YELLOW}alias editcreds_${PROJECT_NAME,,}='code $DEST_PATH/.mcp/.env'${RESET}"
echo
echo -e "2. Run \`source ~/.zshrc\` to load the new aliases"
echo -e "3. Run \`editcreds_${PROJECT_NAME,,}\` to set your API keys"
echo -e "4. Run \`setup${PROJECT_NAME,,}\` to configure the MCPs"
echo -e "5. Run \`run${PROJECT_NAME,,}mcps\` to start the MCP servers"