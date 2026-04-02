#!/bin/bash
# ClaudeWatch Mac Uninstaller
# Usage: curl -fsSL https://claudewatch-web.vercel.app/uninstall.sh | bash

set -euo pipefail

INSTALL_DIR="$HOME/Library/ClaudeWatch"
USER_BIN_PATH="$HOME/.local/bin/claudewatch"
LAUNCH_AGENT_NAME="com.claudewatch.server"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_NAME.plist"
HOOK_FILE="$HOME/.claude/hooks/claudewatch-hook.sh"
CONNECTION_FILE="$HOME/.claudewatch_connection"

ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${ORANGE}${BOLD}  ClaudeWatch${NC} — Uninstaller"
echo ""

# Stop and remove LaunchAgent
echo -e "  ${BOLD}[1/4]${NC} Stopping server..."
launchctl bootout "gui/$(id -u)/$LAUNCH_AGENT_NAME" 2>/dev/null || true
rm -f "$LAUNCH_AGENT_PLIST"

# Remove server files
echo -e "  ${BOLD}[2/4]${NC} Removing server files..."
rm -f "$USER_BIN_PATH"
rm -rf "$INSTALL_DIR"

# Remove hook
echo -e "  ${BOLD}[3/4]${NC} Removing Claude Code hook..."
rm -f "$HOOK_FILE"

# Remove connection file
echo -e "  ${BOLD}[4/4]${NC} Cleaning up..."
rm -f "$CONNECTION_FILE"
rm -f /tmp/claudewatch-server.log /tmp/claudewatch-server.err

echo ""
echo -e "  ${GREEN}${BOLD}ClaudeWatch uninstalled.${NC}"
echo -e "  ${DIM}The iOS app can be deleted from your iPhone separately.${NC}"
echo ""
