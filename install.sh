#!/bin/bash
# ClaudeWatch Mac Setup — one-command installer
# Usage: curl -fsSL https://claudewatch-web.vercel.app/install.sh | bash
#
# What it does:
#   1. Copies the watch server to ~/Library/ClaudeWatch/
#   2. Installs a ClaudeWatch CLI command for pairing/re-linking
#   3. Installs a LaunchAgent so it starts automatically on login
#   4. Installs the Claude Code hook for session event forwarding
#   5. Starts the server and gives you a real pairing command
#
# To uninstall: curl -fsSL https://claudewatch-web.vercel.app/uninstall.sh | bash

set -euo pipefail

# --- Config ---
INSTALL_DIR="$HOME/Library/ClaudeWatch"
CLI_PATH="$INSTALL_DIR/claudewatch"
USER_BIN_DIR="$HOME/.local/bin"
USER_BIN_PATH="$USER_BIN_DIR/claudewatch"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_NAME="com.claudewatch.server"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/$LAUNCH_AGENT_NAME.plist"
CLAUDE_HOOKS_DIR="$HOME/.claude/hooks"
CONNECTION_FILE="$HOME/.claudewatch_connection"
PORT=7432

# --- Colors ---
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${ORANGE}${BOLD}  ClaudeWatch${NC} — Mac Setup"
echo -e "${DIM}  Companion server for the ClaudeWatch iOS app${NC}"
echo ""

# --- Step 1: Create install directory ---
echo -e "  ${BOLD}[1/6]${NC} Creating install directory..."
mkdir -p "$INSTALL_DIR"

# --- Step 2: Copy or download server script ---
echo -e "  ${BOLD}[2/6]${NC} Installing server..."

# Check if running from the repo (local install) or from curl (remote install)
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
if [ -n "$SCRIPT_SOURCE" ] && [ "$SCRIPT_SOURCE" != "bash" ] && [ "$SCRIPT_SOURCE" != "stdin" ] && [ -e "$SCRIPT_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
fi

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../watch-server.sh" ]; then
    # Local install — copy from repo
    cp "$SCRIPT_DIR/../watch-server.sh" "$INSTALL_DIR/watch-server.sh"
    echo -e "       ${DIM}Copied from local repo${NC}"
elif [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/watch-server.sh" ]; then
    cp "$SCRIPT_DIR/watch-server.sh" "$INSTALL_DIR/watch-server.sh"
    echo -e "       ${DIM}Copied from local directory${NC}"
else
    # Remote install — download from GitHub/hosting
    echo -e "       ${DIM}Downloading latest version...${NC}"
    if command -v curl &>/dev/null; then
        DOWNLOAD_OK=""
        for WATCH_SERVER_URL in \
            "https://claudewatch-web.vercel.app/watch-server.sh" \
            "https://claudewatch.app/watch-server.sh" \
            "https://raw.githubusercontent.com/mitre88/ClaudeWatch/main/watch-server.sh"
        do
            if curl -fsSL "$WATCH_SERVER_URL" -o "$INSTALL_DIR/watch-server.sh" 2>/dev/null; then
                DOWNLOAD_OK=1
                echo -e "       ${DIM}Downloaded from ${WATCH_SERVER_URL}${NC}"
                break
            fi
        done

        [ -n "$DOWNLOAD_OK" ] || {
            echo -e "  ${RED}Error: Could not download watch-server.sh${NC}"
            echo -e "  ${DIM}Copy watch-server.sh to ~/Library/ClaudeWatch/ manually${NC}"
            exit 1
        }
    else
        echo -e "  ${RED}Error: curl not found${NC}"
        exit 1
    fi
fi

chmod +x "$INSTALL_DIR/watch-server.sh"

wait_for_server() {
    local max_attempts="${1:-8}"
    local attempt=1

    while [ "$attempt" -le "$max_attempts" ]; do
        if curl -sf "http://127.0.0.1:$PORT/pair" >/dev/null 2>&1; then
            return 0
        fi

        sleep 1
        attempt=$((attempt + 1))
    done

    return 1
}

start_server_directly() {
    nohup "$INSTALL_DIR/watch-server.sh" --no-open >/tmp/claudewatch-server.log 2>/tmp/claudewatch-server.err &
}

# --- Step 3: Install ClaudeWatch CLI ---
echo -e "  ${BOLD}[3/6]${NC} Installing ClaudeWatch command..."
mkdir -p "$USER_BIN_DIR"

cat > "$CLI_PATH" << 'CLI_EOF'
#!/bin/bash
exec "$HOME/Library/ClaudeWatch/watch-server.sh" "$@"
CLI_EOF

chmod +x "$CLI_PATH"
ln -sf "$CLI_PATH" "$USER_BIN_PATH"

# --- Step 4: Install LaunchAgent ---
echo -e "  ${BOLD}[4/6]${NC} Installing LaunchAgent (auto-start on login)..."
mkdir -p "$LAUNCH_AGENT_DIR"

# Stop existing agent if running
launchctl bootout "gui/$(id -u)/$LAUNCH_AGENT_NAME" 2>/dev/null || true

cat > "$LAUNCH_AGENT_PLIST" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claudewatch.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>exec "$HOME/Library/ClaudeWatch/watch-server.sh" --no-open</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>ThrottleInterval</key>
    <integer>10</integer>
    <key>StandardOutPath</key>
    <string>/tmp/claudewatch-server.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/claudewatch-server.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
    </dict>
</dict>
</plist>
PLIST_EOF

# --- Step 5: Install Claude Code hook ---
echo -e "  ${BOLD}[5/6]${NC} Installing Claude Code hook..."
mkdir -p "$CLAUDE_HOOKS_DIR"

cat > "$CLAUDE_HOOKS_DIR/claudewatch-hook.sh" << 'HOOK_EOF'
#!/bin/bash
# ClaudeWatch hook — forwards Claude Code events to the local server
# Auto-starts server if not running

CONNECTION_FILE="$HOME/.claudewatch_connection"
DEFAULT_PORT=7432

# Read port and token from connection file
if [ -f "$CONNECTION_FILE" ]; then
    PORT=$(python3 -c "import json; print(json.load(open('$CONNECTION_FILE')).get('port', $DEFAULT_PORT))" 2>/dev/null || echo "$DEFAULT_PORT")
    TOKEN=$(python3 -c "import json; print(json.load(open('$CONNECTION_FILE')).get('token', ''))" 2>/dev/null || echo "")
else
    PORT="$DEFAULT_PORT"
    TOKEN=""
fi

# Check if server is running, auto-start if not
if ! curl -sf "http://127.0.0.1:$PORT/pair" >/dev/null 2>&1; then
    WATCH_SERVER="$HOME/Library/ClaudeWatch/watch-server.sh"
    if [ -f "$WATCH_SERVER" ]; then
        nohup "$WATCH_SERVER" --no-open >/dev/null 2>&1 &
        sleep 1
        # Re-read connection file
        if [ -f "$CONNECTION_FILE" ]; then
            TOKEN=$(python3 -c "import json; print(json.load(open('$CONNECTION_FILE')).get('token', ''))" 2>/dev/null || echo "")
        fi
    fi
fi

# Forward event to server
if [ -n "$TOKEN" ]; then
    TOKEN_PARAM="?token=$TOKEN"
else
    TOKEN_PARAM=""
fi

# Read event data from stdin or arguments
EVENT_TYPE="${1:-unknown}"
EVENT_DATA="${2:-{}}"

curl -sf -X POST "http://127.0.0.1:$PORT/hook${TOKEN_PARAM}" \
    -H "Content-Type: application/json" \
    -d "{\"event\": \"$EVENT_TYPE\", \"data\": $EVENT_DATA}" \
    >/dev/null 2>&1 || true
HOOK_EOF

chmod +x "$CLAUDE_HOOKS_DIR/claudewatch-hook.sh"

# --- Step 6: Start server and prepare pairing command ---
echo -e "  ${BOLD}[6/6]${NC} Starting server..."

# Load the LaunchAgent
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PLIST" 2>/dev/null || {
    launchctl load "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
}

# Ask launchd to start it right away if possible
launchctl kickstart -k "gui/$(id -u)/$LAUNCH_AGENT_NAME" 2>/dev/null || true

# Wait for server to start via launchd
if ! wait_for_server 5; then
    echo -e "       ${DIM}LaunchAgent not reachable yet. Starting direct fallback...${NC}"
    start_server_directly
fi

# Verify it's running
if wait_for_server 8; then
    echo ""
    echo -e "  ${GREEN}${BOLD}Installation complete!${NC}"
    echo ""
    echo -e "  ${BOLD}Server running${NC} on port ${ORANGE}$PORT${NC}"
    echo -e "  ${BOLD}Auto-start${NC}  enabled (starts on login)"
    echo -e "  ${BOLD}Hook${NC}        installed for Claude Code events"
    echo ""
    echo -e "  ${BOLD}Pair now or later:${NC}"
    echo -e "  ${ORANGE}$CLI_PATH link${NC}"
    echo ""
    if [[ ":$PATH:" == *":$USER_BIN_DIR:"* ]]; then
        echo -e "  ${DIM}Shortcut also available as:${NC} ${ORANGE}claudewatch link${NC}"
    else
        echo -e "  ${DIM}Shortcut installed at:${NC} ${ORANGE}$USER_BIN_PATH${NC}"
        echo -e "  ${DIM}If ~/.local/bin is on PATH, you can also use:${NC} ${ORANGE}claudewatch link${NC}"
    fi
    echo ""
    "$CLI_PATH" link
else
    echo ""
    echo -e "  ${RED}Server failed to start.${NC}"
    echo -e "  ${DIM}Check logs: cat /tmp/claudewatch-server.err${NC}"
    echo ""
    exit 1
fi

echo -e "  ${DIM}Logs:      /tmp/claudewatch-server.log${NC}"
echo -e "  ${DIM}Uninstall: curl -fsSL https://claudewatch-web.vercel.app/uninstall.sh | bash${NC}"
echo ""
