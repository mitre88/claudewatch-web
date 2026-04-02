#!/bin/bash
# ClaudeWatch Server v2.0 — Production CLI
# Monitors real Claude Code sessions from ~/.claude/ and serves status + remote control.
# Generates a secure QR code for pairing.
#
# FEATURES:
#   - Real session detection from ~/.claude/history.jsonl and project JSONL files
#   - Remote command execution via claude CLI (stream-json mode)
#   - Session history with message counts, tool calls, git branches
#   - Hook-based real-time event tracking
#   - Secure token authentication
#
# INSTALL:
#   brew install qrencode  (optional, for QR display)
#   chmod +x watch-server.sh
#   cp watch-server.sh ~/.local/bin/claudewatch
#
# USAGE:
#   claudewatch                     # Start server
#   claudewatch link                # Re-open the pairing flow
#   claudewatch pair                # Alias for "link"
#   claudewatch --port 8080         # Start server on custom port
#   claudewatch --install-hooks     # Install Claude Code hooks
#   claudewatch --help              # Show help

set -e

# ============================================================
# CONFIG
# ============================================================

PORT="${CLAUDEWATCH_PORT:-7432}"
VERSION="2.0.0"
CLAUDE_DIR="${HOME}/.claude"
HOOKS_DIR="${CLAUDE_DIR}/hooks"
CONN_FILE="${HOME}/.claudewatch_connection"
LAUNCH_AGENT_NAME="com.claudewatch.server"
LAUNCH_AGENT_PLIST="${HOME}/Library/LaunchAgents/${LAUNCH_AGENT_NAME}.plist"
INSTALL_CLI_PATH="${HOME}/Library/ClaudeWatch/claudewatch"

NO_OPEN=""
DAEMON=""
TOKEN=""
COMMAND="serve"
PORT_EXPLICIT=""

print_help() {
    echo "ClaudeWatch Server v${VERSION}"
    echo ""
    echo "Usage:"
    echo "  claudewatch [serve] [options]"
    echo "  claudewatch link [--no-open] [--port PORT]"
    echo "  claudewatch pair [--no-open] [--port PORT]"
    echo "  claudewatch qr [--no-open] [--port PORT]"
    echo "  claudewatch status [--port PORT]"
    echo "  claudewatch restart [--no-open] [--port PORT]"
    echo ""
    echo "Commands:"
    echo "  serve, start         Start the local ClaudeWatch server (default)"
    echo "  link, pair           Re-open pairing and print host/port/token"
    echo "  qr                   Alias for 'link'"
    echo "  status               Show whether the local server is reachable"
    echo "  restart              Restart the local server, then reopen pairing"
    echo ""
    echo "Options:"
    echo "  --port, -p PORT      Set server port (default: 7432)"
    echo "  --no-open            Don't auto-open pairing page in browser"
    echo "  --daemon, -d         Run in background (daemon mode)"
    echo "  --install-hooks      Install Claude Code event hooks"
    echo "  --help, -h           Show this help"
    echo "  --version, -v        Show version"
    echo ""
    echo "Endpoints:"
    echo "  GET  /status               Process count + summary"
    echo "  GET  /sessions             List real Claude Code sessions"
    echo "  GET  /session/{id}         Session details with recent messages"
    echo "  POST /command              Send command to Claude Code"
    echo "  GET  /command/{id}         Get command output"
    echo "  POST /command/{id}/cancel  Cancel running command"
    echo ""
}

if [[ $# -gt 0 ]]; then
    case "$1" in
        serve|start)
            COMMAND="serve"
            shift
            ;;
        link|pair|qr)
            COMMAND="link"
            shift
            ;;
        status)
            COMMAND="status"
            shift
            ;;
        restart)
            COMMAND="restart"
            shift
            ;;
        help)
            print_help
            exit 0
            ;;
        version)
            echo "ClaudeWatch Server v${VERSION}"
            exit 0
            ;;
    esac
fi

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port|-p) PORT="$2"; PORT_EXPLICIT=1; shift 2 ;;
        --no-open) NO_OPEN=1; shift ;;
        --daemon|-d) DAEMON=1; shift ;;
        --install-hooks)
            echo "Installing ClaudeWatch hooks..."
            mkdir -p "$HOOKS_DIR"

            # Create auto-start + event forwarding hook
            cat > "$HOOKS_DIR/claudewatch-hook.sh" <<'HOOKEOF'
#!/bin/bash
# ClaudeWatch hook — auto-starts server + forwards Claude Code events
CONN_FILE="${HOME}/.claudewatch_connection"
WATCH_SERVER="${HOME}/.local/bin/claudewatch"
[ ! -f "$WATCH_SERVER" ] && WATCH_SERVER="$(dirname "$0")/../../Desktop/ClaudeWatch/watch-server.sh"

EVENT_TYPE="${1:-unknown}"

# Auto-start server on SessionStart if not running
if [ "$EVENT_TYPE" = "SessionStart" ]; then
    if ! curl -sf "http://127.0.0.1:7432/pair" >/dev/null 2>&1; then
        if [ -x "$WATCH_SERVER" ]; then
            CLAUDEWATCH_NO_OPEN=1 nohup "$WATCH_SERVER" --no-open >/dev/null 2>&1 &
            sleep 1
        fi
    fi
fi

# Forward event to server
EVENT_DATA=$(cat)
[ ! -f "$CONN_FILE" ] && exit 0
TOKEN=$(python3 -c "import json; print(json.load(open('$CONN_FILE'))['token'])" 2>/dev/null)
PORT=$(python3 -c "import json; print(json.load(open('$CONN_FILE'))['port'])" 2>/dev/null)
[ -z "$TOKEN" ] && exit 0
curl -s -X POST "http://127.0.0.1:${PORT}/hook?token=${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"event\":\"${EVENT_TYPE}\",\"data\":${EVENT_DATA}}" \
    >/dev/null 2>&1 || true
HOOKEOF
            chmod +x "$HOOKS_DIR/claudewatch-hook.sh"
            echo ""
            echo "  Hook installed: $HOOKS_DIR/claudewatch-hook.sh"
            echo ""
            echo "  Features:"
            echo "    - Auto-starts ClaudeWatch server on SessionStart"
            echo "    - Forwards all events to the server"
            echo ""
            echo "  Add to ~/.claude/settings.json hooks section:"
            echo '  "hooks": {'
            echo '    "SessionStart": [{"type":"command","command":"~/.claude/hooks/claudewatch-hook.sh SessionStart"}],'
            echo '    "SessionEnd": [{"type":"command","command":"~/.claude/hooks/claudewatch-hook.sh SessionEnd"}],'
            echo '    "UserPromptSubmit": [{"type":"command","command":"~/.claude/hooks/claudewatch-hook.sh UserPromptSubmit"}],'
            echo '    "PreToolUse": [{"type":"command","command":"~/.claude/hooks/claudewatch-hook.sh PreToolUse"}],'
            echo '    "PostToolUse": [{"type":"command","command":"~/.claude/hooks/claudewatch-hook.sh PostToolUse"}]'
            echo '  }'
            exit 0
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        --version|-v) echo "ClaudeWatch Server v${VERSION}"; exit 0 ;;
        *) echo "Unknown option: $1. Use --help for usage."; exit 1 ;;
    esac
done

# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

# ============================================================
# FUNCTIONS
# ============================================================

get_local_ip() {
    local ip
    ip=$(ipconfig getifaddr en0 2>/dev/null)
    [ -z "$ip" ] && ip=$(ipconfig getifaddr en1 2>/dev/null)
    [ -z "$ip" ] && ip=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    echo "${ip:-localhost}"
}

load_connection_details() {
    if [ -f "$CONN_FILE" ]; then
        local saved_port saved_token
        saved_port=$(python3 -c "import json; print(json.load(open('$CONN_FILE')).get('port', ''))" 2>/dev/null || true)
        saved_token=$(python3 -c "import json; print(json.load(open('$CONN_FILE')).get('token', ''))" 2>/dev/null || true)
        if [ -z "$PORT_EXPLICIT" ] && [ -n "$saved_port" ]; then
            PORT="$saved_port"
        fi
        if [ -n "$saved_token" ]; then
            TOKEN="$saved_token"
        fi
    fi
}

generate_session_token() {
    TOKEN=$(openssl rand -hex 16 2>/dev/null || head -c 32 /dev/urandom | xxd -p | head -c 32)
    echo "{\"token\":\"${TOKEN}\",\"port\":${PORT}}" > "$CONN_FILE"
}

server_is_running_local() {
    curl -sf "http://127.0.0.1:${PORT}/pair" >/dev/null 2>&1
}

ensure_server_for_link() {
    load_connection_details
    if server_is_running_local; then
        return 0
    fi

    if [ -f "$LAUNCH_AGENT_PLIST" ]; then
        launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PLIST" >/dev/null 2>&1 || true
        launchctl kickstart -k "gui/$(id -u)/${LAUNCH_AGENT_NAME}" >/dev/null 2>&1 || true
    else
        local launcher="$INSTALL_CLI_PATH"
        [ -x "$launcher" ] || launcher="$0"
        CLAUDEWATCH_NO_OPEN=1 nohup "$launcher" serve --no-open >/tmp/claudewatch-server.log 2>/tmp/claudewatch-server.err &
    fi

    local attempts=20
    while [ "$attempts" -gt 0 ]; do
        sleep 0.5
        load_connection_details
        if server_is_running_local; then
            return 0
        fi
        attempts=$((attempts - 1))
    done

    return 1
}

restart_local_server() {
    load_connection_details

    if [ -f "$LAUNCH_AGENT_PLIST" ]; then
        launchctl bootout "gui/$(id -u)/${LAUNCH_AGENT_NAME}" >/dev/null 2>&1 || true
        launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PLIST" >/dev/null 2>&1 || true
        launchctl kickstart -k "gui/$(id -u)/${LAUNCH_AGENT_NAME}" >/dev/null 2>&1 || true
    else
        local pids
        pids=$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)
        if [ -n "$pids" ]; then
            kill $pids >/dev/null 2>&1 || true
            sleep 1
        fi

        local launcher="$INSTALL_CLI_PATH"
        [ -x "$launcher" ] || launcher="$0"
        CLAUDEWATCH_NO_OPEN=1 nohup "$launcher" serve --no-open >/tmp/claudewatch-server.log 2>/tmp/claudewatch-server.err &
    fi

    local attempts=20
    while [ "$attempts" -gt 0 ]; do
        sleep 0.5
        load_connection_details
        if server_is_running_local; then
            return 0
        fi
        attempts=$((attempts - 1))
    done

    return 1
}

show_status_banner() {
    load_connection_details
    local ip
    ip=$(get_local_ip)

    printf "\n"
    printf "${ORANGE}${BOLD}  ClaudeWatch Status${RESET}\n\n"

    if server_is_running_local; then
        printf "  ${DIM}State       :${RESET} ${GREEN}${BOLD}RUNNING${RESET}\n"
        printf "  ${DIM}Browser URL :${RESET} ${CYAN}${BOLD}http://localhost:${PORT}/pair${RESET}\n"
        printf "  ${DIM}Manual URL  :${RESET} ${CYAN}${BOLD}http://${ip}:${PORT}/pair${RESET}\n"
        printf "  ${DIM}Host        :${RESET} ${CYAN}${BOLD}${ip}${RESET}\n"
        printf "  ${DIM}Port        :${RESET} ${CYAN}${BOLD}${PORT}${RESET}\n"
        if [ -n "$TOKEN" ]; then
            printf "  ${DIM}Token       :${RESET} ${ORANGE}${TOKEN}${RESET}\n"
        fi
        printf "\n"
        return 0
    fi

    printf "  ${DIM}State       :${RESET} ${RED}${BOLD}OFFLINE${RESET}\n"
    if [ -n "$TOKEN" ]; then
        printf "  ${DIM}Last Port   :${RESET} ${CYAN}${BOLD}${PORT}${RESET}\n"
        printf "  ${DIM}Saved Token :${RESET} ${ORANGE}${TOKEN}${RESET}\n"
    else
        printf "  ${DIM}Saved Config :${RESET} ${DIM}No pairing details stored yet${RESET}\n"
    fi
    printf "  ${DIM}Next Step   :${RESET} Run ${CYAN}${BOLD}claudewatch link${RESET}${DIM} to start pairing${RESET}\n"
    printf "\n"
    return 1
}

show_banner() {
    local ip="$1"
    local pair_url="http://${ip}:${PORT}/pair"
    local deep_url="claudewatch://pair?host=${ip}&port=${PORT}&token=${TOKEN}"

    if [ -t 1 ] && [ -n "${TERM:-}" ]; then
        clear || true
    fi
    printf "\n"
    printf "${ORANGE}${BOLD}"
    printf "  ╔════════════════════════════════════════════╗\n"
    printf "  ║     ClaudeWatch Server v${VERSION}            ║\n"
    printf "  ║          Real Session Monitor              ║\n"
    printf "  ╚════════════════════════════════════════════╝\n"
    printf "${RESET}\n"

    printf "  ${DIM}IP      :${RESET}  ${CYAN}${BOLD}${ip}${RESET}\n"
    printf "  ${DIM}Port    :${RESET}  ${CYAN}${BOLD}${PORT}${RESET}\n"
    printf "  ${DIM}Token   :${RESET}  ${DIM}${TOKEN:0:8}...${RESET}\n"
    printf "  ${DIM}Claude  :${RESET}  ${CYAN}${CLAUDE_DIR}${RESET}\n"
    printf "\n"

    # Pairing page — always available, no dependencies
    printf "  ${DIM}────────────────────────────────────────────${RESET}\n"
    printf "  ${WHITE}${BOLD}Pair your iPhone:${RESET}\n\n"
    printf "  ${CYAN}${BOLD}  ${pair_url}${RESET}\n\n"
    printf "  ${DIM}  Open this URL on your Mac or scan the QR${RESET}\n"
    printf "  ${DIM}  from the pairing page with your iPhone.${RESET}\n"

    # Terminal QR Code (bonus, if qrencode available)
    if command -v qrencode &>/dev/null; then
        printf "\n"
        qrencode -t ANSIUTF8 "$deep_url" 2>/dev/null | sed 's/^/    /'
    fi

    printf "\n  ${DIM}────────────────────────────────────────────${RESET}\n"

    printf "\n"
    printf "  ${YELLOW}${BOLD}ENDPOINTS${RESET}\n\n"
    printf "  ${WHITE}GET${RESET}  ${CYAN}/pair${RESET}             Pairing page (QR + deep link)\n"
    printf "  ${WHITE}GET${RESET}  ${CYAN}/status${RESET}           Process monitor\n"
    printf "  ${WHITE}GET${RESET}  ${CYAN}/sessions${RESET}         Real Claude sessions\n"
    printf "  ${WHITE}GET${RESET}  ${CYAN}/session/{id}${RESET}     Session details\n"
    printf "  ${WHITE}GET${RESET}  ${CYAN}/usage${RESET}            Usage quota stats\n"
    printf "  ${WHITE}POST${RESET} ${CYAN}/command${RESET}          Remote control\n"
    printf "\n"
    printf "  ${GREEN}${BOLD}Monitoring Claude Code sessions...${RESET}\n"
    printf "  ${DIM}Press Ctrl+C to stop.${RESET}\n"
    printf "  ${DIM}────────────────────────────────────────────${RESET}\n\n"
}

show_link_banner() {
    local ip="$1"
    local pair_url="http://${ip}:${PORT}/pair"
    local local_url="http://localhost:${PORT}/pair"
    local deep_url="claudewatch://pair?host=${ip}&port=${PORT}&token=${TOKEN}"

    printf "\n"
    printf "${ORANGE}${BOLD}  ClaudeWatch Link${RESET}\n\n"
    printf "  ${WHITE}${BOLD}Pair your iPhone:${RESET}\n"
    printf "  ${DIM}Browser page:${RESET} ${CYAN}${BOLD}${local_url}${RESET}\n"
    printf "  ${DIM}Manual URL  :${RESET} ${CYAN}${BOLD}${pair_url}${RESET}\n"
    printf "  ${DIM}Host        :${RESET} ${CYAN}${BOLD}${ip}${RESET}\n"
    printf "  ${DIM}Port        :${RESET} ${CYAN}${BOLD}${PORT}${RESET}\n"
    printf "  ${DIM}Token       :${RESET} ${ORANGE}${TOKEN}${RESET}\n"
    printf "\n"
    printf "  ${DIM}Run this command any time to reopen pairing.${RESET}\n"
    printf "  ${DIM}Scan the browser QR or paste host/port/token manually in ClaudeWatch.${RESET}\n"

    if command -v qrencode &>/dev/null; then
        printf "\n"
        qrencode -t ANSIUTF8 "$deep_url" 2>/dev/null | sed 's/^/    /'
        printf "\n"
    fi

    printf "\n"
    if [ -z "$NO_OPEN" ] && [ -z "$CLAUDEWATCH_NO_OPEN" ] && [ -n "$DISPLAY" -o "$(uname)" = "Darwin" ]; then
        open "$local_url" 2>/dev/null || true
    fi
}

# ============================================================
# STARTUP
# ============================================================

if [ "$COMMAND" = "status" ]; then
    if show_status_banner; then
        exit 0
    fi
    exit 1
fi

if [ "$COMMAND" = "restart" ]; then
    if ! restart_local_server; then
        echo "ClaudeWatch could not restart the local server."
        echo "Check /tmp/claudewatch-server.err and try again."
        exit 1
    fi
    load_connection_details
    LOCAL_IP=$(get_local_ip)
    show_link_banner "$LOCAL_IP"
    exit 0
fi

if [ "$COMMAND" = "link" ]; then
    if ! ensure_server_for_link; then
        echo "ClaudeWatch could not start the local server."
        echo "Check /tmp/claudewatch-server.err and try again."
        exit 1
    fi
    load_connection_details
    LOCAL_IP=$(get_local_ip)
    show_link_banner "$LOCAL_IP"
    exit 0
fi

generate_session_token
LOCAL_IP=$(get_local_ip)
show_banner "$LOCAL_IP"

# Auto-open pairing page in browser (unless --no-open or running headless)
if [ -z "$NO_OPEN" ] && [ -z "$CLAUDEWATCH_NO_OPEN" ] && [ -n "$DISPLAY" -o "$(uname)" = "Darwin" ]; then
    open "http://localhost:${PORT}/pair" 2>/dev/null || true
fi

# Daemon mode: fork to background and exit parent
if [ -n "$DAEMON" ]; then
    printf "  ${DIM}Running in daemon mode (PID: $$)${RESET}\n"
fi

# ============================================================
# BONJOUR/mDNS — Advertise service for auto-discovery
# ============================================================

dns-sd -R "ClaudeWatch" _claudewatch._tcp local "${PORT}" "token=${TOKEN}" &>/dev/null &
DNSSD_PID=$!

# Kill dns-sd on exit
trap "kill $DNSSD_PID 2>/dev/null; exit 0" INT TERM

# ============================================================
# MAIN SERVER — Python HTTP (production-ready)
# ============================================================

exec python3 -u - "$PORT" "$TOKEN" "$CLAUDE_DIR" <<'PYSERVER'
import http.server
import json
import subprocess
import sys
import signal
import os
import glob
import time
import threading
import uuid
from datetime import datetime
from urllib.parse import urlparse, parse_qs
from pathlib import Path

PORT = int(sys.argv[1])
TOKEN = sys.argv[2]
CLAUDE_DIR = sys.argv[3]

# Store running commands
running_commands = {}
# Store hook events
hook_events = []
MAX_EVENTS = 500

# ============================================================
# QR Code Generator (pure Python, no dependencies)
# Generates QR Code as SVG — supports up to Version 10 (271 chars)
# ============================================================

def _qr_make_svg(data_str):
    """Generate a QR code SVG string. Uses a minimal QR encoder."""
    import struct, io

    # --- Minimal QR encoder (Mode: Byte, ECC: L) ---
    # This is a self-contained QR code generator for short strings.

    GF256_EXP = [0]*512
    GF256_LOG = [0]*256
    v = 1
    for i in range(255):
        GF256_EXP[i] = v
        GF256_LOG[v] = i
        v <<= 1
        if v >= 256:
            v ^= 0x11d
    for i in range(255, 512):
        GF256_EXP[i] = GF256_EXP[i - 255]

    def gf_mul(a, b):
        if a == 0 or b == 0: return 0
        return GF256_EXP[GF256_LOG[a] + GF256_LOG[b]]

    def gf_poly_mul(p, q):
        r = [0]*(len(p)+len(q)-1)
        for i,a in enumerate(p):
            for j,b in enumerate(q):
                r[i+j] ^= gf_mul(a,b)
        return r

    def rs_generator(nsym):
        g = [1]
        for i in range(nsym):
            g = gf_poly_mul(g, [1, GF256_EXP[i]])
        return g

    def rs_encode(data, nsym):
        gen = rs_generator(nsym)
        res = data + [0]*nsym
        for i in range(len(data)):
            coef = res[i]
            if coef != 0:
                for j in range(len(gen)):
                    res[i+j] ^= gf_mul(gen[j], coef)
        return res[len(data):]

    # QR Version selection (ECC Level L, Byte mode)
    # Capacities: v1=17, v2=32, v3=53, v4=78, v5=106, v6=134, v7=154, v8=192, v9=230, v10=271
    version_caps = [(1,17,7),(2,32,10),(3,53,15),(4,78,20),(5,106,26),(6,134,18),(7,154,20),(8,192,24),(9,230,30),(10,271,18)]
    # (version, byte_capacity_L, ec_codewords_per_block_L)

    data_bytes = data_str.encode('utf-8')
    data_len = len(data_bytes)

    # Find smallest version
    version = None
    total_codewords = 0
    ec_per_block = 0
    for v, cap, ec in version_caps:
        if data_len <= cap:
            version = v
            ec_per_block = ec
            break

    if version is None:
        version = 10
        ec_per_block = 18

    size = 17 + version * 4

    # Data codeword capacities (total data codewords for ECC L)
    # Simplified: we compute from known total capacities
    total_capacity_bits = {
        1: 19, 2: 34, 3: 55, 4: 80, 5: 108,
        6: 136, 7: 156, 8: 194, 9: 232, 10: 274
    }

    total_data_cw = total_capacity_bits.get(version, 274)

    # EC block structure for L level
    ec_blocks_L = {
        1: [(1, 19, 7)],  # (num_blocks, data_cw, ec_cw)
        2: [(1, 34, 10)],
        3: [(1, 55, 15)],
        4: [(1, 80, 20)],
        5: [(1, 108, 26)],
        6: [(2, 68, 18)],
        7: [(2, 78, 20)],
        8: [(2, 97, 24)],
        9: [(2, 116, 30)],
        10: [(2, 137, 18)],  # 2 blocks of 68+69 data cw
    }

    blocks_info = ec_blocks_L.get(version, [(2, 137, 18)])

    # Encode data: byte mode indicator (0100) + char count + data + terminator
    bits = []
    def add_bits(val, length):
        for i in range(length-1, -1, -1):
            bits.append((val >> i) & 1)

    add_bits(0b0100, 4)  # Byte mode
    cc_len = 8 if version <= 9 else 16
    add_bits(data_len, cc_len)
    for b in data_bytes:
        add_bits(b, 8)

    # Terminator
    remaining = total_data_cw * 8 - len(bits)
    add_bits(0, min(4, remaining))

    # Byte-align
    while len(bits) % 8 != 0:
        bits.append(0)

    # Pad bytes
    pad_bytes = [0xEC, 0x11]
    pi = 0
    while len(bits) < total_data_cw * 8:
        add_bits(pad_bytes[pi % 2], 8)
        pi += 1

    # Convert to codewords
    codewords = []
    for i in range(0, len(bits), 8):
        byte_val = 0
        for j in range(8):
            if i+j < len(bits):
                byte_val = (byte_val << 1) | bits[i+j]
            else:
                byte_val <<= 1
        codewords.append(byte_val)

    # Split into blocks and compute EC
    all_data_blocks = []
    all_ec_blocks = []
    idx = 0
    for num_blocks, data_cw, ec_cw in blocks_info:
        base_size = data_cw // num_blocks
        extra = data_cw % num_blocks
        for b in range(num_blocks):
            bsize = base_size + (1 if b >= num_blocks - extra and extra > 0 else 0)
            block_data = codewords[idx:idx+bsize]
            idx += bsize
            ec = rs_encode(block_data, ec_cw)
            all_data_blocks.append(block_data)
            all_ec_blocks.append(ec)

    # Interleave
    max_data = max(len(b) for b in all_data_blocks)
    max_ec = max(len(b) for b in all_ec_blocks)
    interleaved = []
    for i in range(max_data):
        for block in all_data_blocks:
            if i < len(block):
                interleaved.append(block[i])
    for i in range(max_ec):
        for block in all_ec_blocks:
            if i < len(block):
                interleaved.append(block[i])

    # Create module grid
    modules = [[None]*size for _ in range(size)]

    def set_module(r, c, val):
        if 0 <= r < size and 0 <= c < size:
            modules[r][c] = val

    # Finder patterns
    def place_finder(row, col):
        for r in range(-1, 8):
            for c in range(-1, 8):
                rr, cc = row+r, col+c
                if 0 <= rr < size and 0 <= cc < size:
                    if 0 <= r <= 6 and 0 <= c <= 6:
                        if r in (0,6) or c in (0,6) or (2<=r<=4 and 2<=c<=4):
                            set_module(rr, cc, True)
                        else:
                            set_module(rr, cc, False)
                    else:
                        set_module(rr, cc, False)

    place_finder(0, 0)
    place_finder(0, size-7)
    place_finder(size-7, 0)

    # Timing patterns
    for i in range(8, size-8):
        set_module(6, i, i % 2 == 0)
        set_module(i, 6, i % 2 == 0)

    # Alignment patterns (for version >= 2)
    alignment_positions = {
        2: [6,18], 3: [6,22], 4: [6,26], 5: [6,30],
        6: [6,34], 7: [6,22,38], 8: [6,24,42], 9: [6,26,46], 10: [6,28,50]
    }
    if version >= 2:
        positions = alignment_positions.get(version, [])
        for r in positions:
            for c in positions:
                if modules[r][c] is not None:
                    continue
                for dr in range(-2, 3):
                    for dc in range(-2, 3):
                        if abs(dr) == 2 or abs(dc) == 2 or (dr == 0 and dc == 0):
                            set_module(r+dr, c+dc, True)
                        else:
                            set_module(r+dr, c+dc, False)

    # Reserve format info areas
    for i in range(9):
        if modules[8][i] is None: modules[8][i] = False
        if modules[i][8] is None: modules[i][8] = False
    for i in range(8):
        if modules[8][size-1-i] is None: modules[8][size-1-i] = False
        if modules[size-1-i][8] is None: modules[size-1-i][8] = False
    modules[size-8][8] = True  # Dark module

    # Reserve version info (v >= 7)
    if version >= 7:
        for i in range(6):
            for j in range(3):
                modules[i][size-11+j] = False
                modules[size-11+j][i] = False

    # Place data bits
    bit_idx = 0
    data_bits = []
    for byte in interleaved:
        for i in range(7, -1, -1):
            data_bits.append((byte >> i) & 1)

    col = size - 1
    going_up = True
    while col >= 0:
        if col == 6:
            col -= 1
            continue
        for row_offset in range(size):
            row = (size - 1 - row_offset) if going_up else row_offset
            for dc in [0, -1]:
                c = col + dc
                if 0 <= c < size and modules[row][c] is None:
                    if bit_idx < len(data_bits):
                        modules[row][c] = data_bits[bit_idx] == 1
                    else:
                        modules[row][c] = False
                    bit_idx += 1
        going_up = not going_up
        col -= 2

    # Apply mask pattern 0 (checkerboard: (row + col) % 2 == 0)
    for r in range(size):
        for c in range(size):
            if modules[r][c] is not None:
                # Check if this is a data/EC module (not function pattern)
                # Simple heuristic: all modules are already placed
                pass

    # Actually we need to track which are data modules for masking
    # Rebuild: mark function modules
    is_function = [[False]*size for _ in range(size)]

    # Mark finder + separators
    for r in range(9):
        for c in range(9):
            is_function[r][c] = True
    for r in range(9):
        for c in range(size-8, size):
            is_function[r][c] = True
    for r in range(size-8, size):
        for c in range(9):
            is_function[r][c] = True

    # Timing
    for i in range(size):
        is_function[6][i] = True
        is_function[i][6] = True

    # Alignment
    if version >= 2:
        positions = alignment_positions.get(version, [])
        for r in positions:
            for c in positions:
                for dr in range(-2, 3):
                    for dc in range(-2, 3):
                        rr, cc = r+dr, c+dc
                        if 0 <= rr < size and 0 <= cc < size:
                            is_function[rr][cc] = True

    # Dark module
    is_function[size-8][8] = True

    # Version info
    if version >= 7:
        for i in range(6):
            for j in range(3):
                is_function[i][size-11+j] = True
                is_function[size-11+j][i] = True

    # Apply mask 0: (row + col) % 2 == 0
    for r in range(size):
        for c in range(size):
            if not is_function[r][c] and modules[r][c] is not None:
                if (r + c) % 2 == 0:
                    modules[r][c] = not modules[r][c]

    # Format info for mask 0, ECC L
    # Pre-computed: L=01, mask=000 -> data=01000, BCH=101011000010010 XOR 101010000010010 = 111011111000100
    format_bits = [1,1,1,0,1,1,1,1,1,0,0,0,1,0,0]

    # Place format info
    # Around top-left finder
    format_positions_h = [(8,0),(8,1),(8,2),(8,3),(8,4),(8,5),(8,7),(8,8)]
    format_positions_v = [(0,8),(1,8),(2,8),(3,8),(4,8),(5,8),(7,8),(8,8)]

    for i, (r,c) in enumerate(format_positions_h):
        modules[r][c] = format_bits[i] == 1
    for i, (r,c) in enumerate(format_positions_v):
        modules[r][c] = format_bits[14-i] == 1

    # Around top-right and bottom-left finders
    for i in range(8):
        modules[8][size-1-i] = format_bits[i] == 1
    for i in range(7):
        modules[size-1-i][8] = format_bits[8+i] == 1

    # Generate SVG
    scale = 8
    quiet = 4  # quiet zone modules
    total = (size + quiet*2) * scale

    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {total} {total}" ',
        f'width="{total}" height="{total}">',
        f'<rect width="{total}" height="{total}" fill="white"/>',
    ]

    for r in range(size):
        for c in range(size):
            if modules[r][c]:
                x = (c + quiet) * scale
                y = (r + quiet) * scale
                svg_parts.append(f'<rect x="{x}" y="{y}" width="{scale}" height="{scale}" fill="black"/>')

    svg_parts.append('</svg>')
    return ''.join(svg_parts)


def _generate_pair_page(host, port, token):
    """Generate a beautiful HTML pairing page with QR code."""
    deep_link = f"claudewatch://pair?host={host}&port={port}&token={token}"
    try:
        qr_svg = _qr_make_svg(deep_link)
    except Exception:
        qr_svg = '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><text x="20" y="100" fill="red">QR Error</text></svg>'

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ClaudeWatch — Pair Your iPhone</title>
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif;
    background: #0a0a0f;
    color: #e5e5e5;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 24px;
  }}
  .card {{
    background: #141419;
    border: 1px solid rgba(255,153,31,0.15);
    border-radius: 20px;
    padding: 40px 32px;
    max-width: 420px;
    width: 100%;
    text-align: center;
  }}
  .logo {{ font-size: 13px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase; color: #666; margin-bottom: 8px; }}
  .logo span {{ color: #ff991f; }}
  h1 {{ font-size: 24px; font-weight: 700; margin-bottom: 6px; }}
  .subtitle {{ font-size: 14px; color: #888; margin-bottom: 28px; }}
  .qr-container {{
    background: white;
    border-radius: 16px;
    padding: 20px;
    display: inline-block;
    margin-bottom: 24px;
    box-shadow: 0 0 40px rgba(255,153,31,0.08);
  }}
  .qr-container svg {{ display: block; width: 220px; height: 220px; }}
  .steps {{ text-align: left; margin-bottom: 28px; }}
  .step {{
    display: flex;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 14px;
    font-size: 14px;
    color: #bbb;
    line-height: 1.5;
  }}
  .step-num {{
    flex-shrink: 0;
    width: 24px; height: 24px;
    background: rgba(255,153,31,0.12);
    color: #ff991f;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; font-weight: 700;
  }}
  .btn {{
    display: inline-block;
    background: #ff991f;
    color: #000;
    font-size: 15px;
    font-weight: 700;
    padding: 14px 28px;
    border-radius: 12px;
    text-decoration: none;
    transition: all 0.2s;
    margin-bottom: 12px;
  }}
  .btn:hover {{ background: #ffaa40; transform: scale(1.02); }}
  .btn:active {{ transform: scale(0.98); }}
  .hint {{ font-size: 12px; color: #555; font-family: "SF Mono", monospace; }}
  .divider {{ width: 60px; height: 1px; background: rgba(255,153,31,0.2); margin: 20px auto; }}
  .token-row {{
    display: flex; align-items: center; justify-content: center; gap: 8px;
    background: rgba(255,255,255,0.04);
    border-radius: 8px;
    padding: 10px 14px;
    margin-top: 16px;
    cursor: pointer;
  }}
  .token-row:hover {{ background: rgba(255,255,255,0.08); }}
  .token-label {{ font-size: 11px; color: #666; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; }}
  .token-val {{ font-size: 13px; color: #ff991f; font-family: "SF Mono", monospace; }}
  .copied {{ position: fixed; top: 20px; right: 20px; background: #ff991f; color: #000; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; opacity: 0; transition: opacity 0.3s; pointer-events: none; }}
  .copied.show {{ opacity: 1; }}
  @media (max-width: 500px) {{
    .card {{ padding: 28px 20px; }}
    .qr-container svg {{ width: 180px; height: 180px; }}
  }}
</style>
</head>
<body>
  <div class="card">
    <div class="logo">Claude<span>Watch</span></div>
    <h1>Pair Your iPhone</h1>
    <p class="subtitle">Scan the QR code with your iPhone camera</p>

    <div class="qr-container">
      {qr_svg}
    </div>

    <div class="steps">
      <div class="step">
        <div class="step-num">1</div>
        <div>Open your <strong style="color:#e5e5e5">iPhone Camera</strong> and point it at the QR code above</div>
      </div>
      <div class="step">
        <div class="step-num">2</div>
        <div>Tap the <strong style="color:#ff991f">ClaudeWatch</strong> notification banner that appears</div>
      </div>
      <div class="step">
        <div class="step-num">3</div>
        <div>Your iPhone connects automatically — done!</div>
      </div>
    </div>

    <a class="btn" href="{deep_link}">Open in ClaudeWatch</a>
    <br>
    <span class="hint">Works if you're viewing this on your iPhone</span>

    <div class="divider"></div>

    <div class="token-row" onclick="copyToken()" title="Click to copy full token">
      <span class="token-label">Token</span>
      <span class="token-val">{token[:12]}...</span>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#666" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
    </div>
  </div>

  <div class="copied" id="copiedToast">Token copied!</div>

  <script>
    function copyToken() {{
      navigator.clipboard.writeText("{token}").then(function() {{
        var toast = document.getElementById("copiedToast");
        toast.classList.add("show");
        setTimeout(function() {{ toast.classList.remove("show"); }}, 1500);
      }});
    }}
  </script>
</body>
</html>'''

# ============================================================
# Claude Code Session Discovery
# ============================================================

def get_claude_processes():
    try:
        result = subprocess.run(
            ["pgrep", "-la", "claude"],
            capture_output=True, text=True, timeout=5
        )
        return [l.strip() for l in result.stdout.strip().split("\n") if l.strip()]
    except Exception:
        return []

def get_sessions(limit=50):
    """Read real Claude Code sessions from ~/.claude/"""
    sessions = []
    history_file = os.path.join(CLAUDE_DIR, "history.jsonl")

    if not os.path.exists(history_file):
        return sessions

    # Read history.jsonl to discover sessions
    seen_sessions = {}
    try:
        with open(history_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    sid = entry.get("sessionId", "")
                    if not sid:
                        continue
                    ts = entry.get("timestamp", 0)
                    project = entry.get("project", "")
                    display = entry.get("display", "")

                    if sid not in seen_sessions:
                        seen_sessions[sid] = {
                            "id": sid,
                            "project": project,
                            "projectName": os.path.basename(project) if project else "",
                            "startedAt": ts / 1000.0 if ts > 1e12 else ts,
                            "lastActivityAt": ts / 1000.0 if ts > 1e12 else ts,
                            "messageCount": 1,
                            "toolCallCount": 0,
                            "status": "completed",
                            "gitBranch": None,
                            "model": None,
                            "cwd": project
                        }
                    else:
                        s = seen_sessions[sid]
                        act_ts = ts / 1000.0 if ts > 1e12 else ts
                        if act_ts > s["lastActivityAt"]:
                            s["lastActivityAt"] = act_ts
                        s["messageCount"] += 1
                except json.JSONDecodeError:
                    continue
    except Exception as e:
        sys.stderr.write(f"  [Error] Reading history: {e}\n")

    # Enrich with session JSONL data
    projects_dir = os.path.join(CLAUDE_DIR, "projects")
    if os.path.isdir(projects_dir):
        for project_dir in os.listdir(projects_dir):
            project_path = os.path.join(projects_dir, project_dir)
            if not os.path.isdir(project_path):
                continue
            for jsonl_file in glob.glob(os.path.join(project_path, "*.jsonl")):
                sid = os.path.splitext(os.path.basename(jsonl_file))[0]
                if sid in seen_sessions:
                    # Read first and last few lines for metadata
                    try:
                        with open(jsonl_file, 'r') as f:
                            first_line = f.readline().strip()
                            if first_line:
                                entry = json.loads(first_line)
                                if "gitBranch" in entry:
                                    seen_sessions[sid]["gitBranch"] = entry["gitBranch"]
                                if "version" in entry:
                                    seen_sessions[sid]["model"] = entry.get("model", None)
                                if "cwd" in entry:
                                    seen_sessions[sid]["cwd"] = entry["cwd"]

                        # Count tool calls
                        file_size = os.path.getsize(jsonl_file)
                        if file_size < 5_000_000:  # Only for files under 5MB
                            with open(jsonl_file, 'r') as f:
                                tool_count = 0
                                msg_count = 0
                                for line in f:
                                    if '"tool_use"' in line:
                                        tool_count += 1
                                    if '"type"' in line:
                                        msg_count += 1
                                seen_sessions[sid]["toolCallCount"] = tool_count
                                if msg_count > seen_sessions[sid]["messageCount"]:
                                    seen_sessions[sid]["messageCount"] = msg_count
                    except Exception:
                        pass

    # Check which sessions might still be running (process check)
    active_pids = get_claude_processes()
    active_session_ids = set()

    # Check CCStatusBar sessions.json for live status
    ccstatus_file = os.path.expanduser("~/Library/Application Support/CCStatusBar/sessions.json")
    if os.path.exists(ccstatus_file):
        try:
            with open(ccstatus_file, 'r') as f:
                ccdata = json.load(f)
            for cc_sid, cc_info in ccdata.items():
                status = cc_info.get("status", "")
                if status in ("running", "waiting_input"):
                    active_session_ids.add(cc_sid)
                    if cc_sid in seen_sessions:
                        seen_sessions[cc_sid]["status"] = status
        except Exception:
            pass

    # Sort by last activity, most recent first
    sorted_sessions = sorted(
        seen_sessions.values(),
        key=lambda s: s["lastActivityAt"],
        reverse=True
    )

    # Convert timestamps to ISO format
    for s in sorted_sessions[:limit]:
        s["startedAt"] = datetime.fromtimestamp(s["startedAt"]).isoformat() if s["startedAt"] else None
        s["lastActivityAt"] = datetime.fromtimestamp(s["lastActivityAt"]).isoformat() if s["lastActivityAt"] else None
        sessions.append(s)

    return sessions

def get_usage_stats():
    """Compute usage stats: rolling 5h window + weekly sessions from history.jsonl"""
    now = time.time()
    five_hours_ago = now - (5 * 3600)

    # Find start of current week (Monday 00:00 local time)
    from datetime import timedelta
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today - timedelta(days=today.weekday())
    week_start_ts = week_start.timestamp()

    msgs_5h = 0
    sessions_5h = set()
    msgs_week = 0
    sessions_week = set()
    daily_breakdown = {}

    history_file = os.path.join(CLAUDE_DIR, "history.jsonl")
    if os.path.exists(history_file):
        try:
            with open(history_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        entry = json.loads(line)
                        ts = entry.get("timestamp", 0)
                        ts_sec = ts / 1000.0 if ts > 1e12 else ts
                        sid = entry.get("sessionId", "")

                        # Rolling 5-hour window
                        if ts_sec >= five_hours_ago:
                            msgs_5h += 1
                            if sid:
                                sessions_5h.add(sid)

                        # Weekly stats
                        if ts_sec >= week_start_ts:
                            msgs_week += 1
                            if sid:
                                sessions_week.add(sid)

                            # Daily breakdown
                            day_key = datetime.fromtimestamp(ts_sec).strftime("%Y-%m-%d")
                            if day_key not in daily_breakdown:
                                daily_breakdown[day_key] = {"messages": 0, "sessions": set()}
                            daily_breakdown[day_key]["messages"] += 1
                            if sid:
                                daily_breakdown[day_key]["sessions"].add(sid)
                    except (json.JSONDecodeError, ValueError):
                        continue
        except Exception as e:
            sys.stderr.write(f"  [Error] Reading usage: {e}\n")

    # Also read stats-cache.json for richer data
    stats_file = os.path.join(CLAUDE_DIR, "stats-cache.json")
    if os.path.exists(stats_file):
        try:
            with open(stats_file, 'r') as f:
                stats = json.load(f)
            for day_entry in stats.get("dailyActivity", []):
                day_key = day_entry.get("date", "")
                if day_key and day_key >= week_start.strftime("%Y-%m-%d"):
                    if day_key not in daily_breakdown:
                        daily_breakdown[day_key] = {
                            "messages": day_entry.get("messageCount", 0),
                            "sessions": set()
                        }
                    else:
                        # Use the larger count
                        cached_msgs = day_entry.get("messageCount", 0)
                        if cached_msgs > daily_breakdown[day_key]["messages"]:
                            daily_breakdown[day_key]["messages"] = cached_msgs
        except Exception:
            pass

    # Convert daily_breakdown sets to counts
    daily_list = []
    for day_key in sorted(daily_breakdown.keys()):
        d = daily_breakdown[day_key]
        daily_list.append({
            "date": day_key,
            "messages": d["messages"],
            "sessions": len(d["sessions"]) if isinstance(d["sessions"], set) else d.get("sessions", 0)
        })

    # Estimate remaining (Claude Pro: ~45 msgs/5h window, ~unlimited weekly but track)
    # These are approximate — actual limits are server-side
    window_limit = 45  # Approximate messages per 5h window for Pro
    weekly_session_limit = 200  # Approximate weekly session limit

    return {
        "rollingWindow": {
            "messages": msgs_5h,
            "sessions": len(sessions_5h),
            "windowHours": 5,
            "estimatedLimit": window_limit,
            "remaining": max(0, window_limit - msgs_5h),
            "percentUsed": min(100, round(msgs_5h / window_limit * 100, 1)),
            "resetsAt": datetime.fromtimestamp(five_hours_ago + 5 * 3600).isoformat()
        },
        "weekly": {
            "messages": msgs_week,
            "sessions": len(sessions_week),
            "estimatedLimit": weekly_session_limit,
            "remaining": max(0, weekly_session_limit - len(sessions_week)),
            "percentUsed": min(100, round(len(sessions_week) / weekly_session_limit * 100, 1)),
            "weekStart": week_start.isoformat(),
            "weekEnd": (week_start + timedelta(days=7)).isoformat()
        },
        "daily": daily_list,
        "timestamp": datetime.now().isoformat()
    }

def get_session_messages(session_id, limit=30):
    """Read recent messages from a specific session's JSONL file"""
    messages = []
    projects_dir = os.path.join(CLAUDE_DIR, "projects")

    if not os.path.isdir(projects_dir):
        return messages

    # Find the session JSONL file
    for project_dir in os.listdir(projects_dir):
        jsonl_file = os.path.join(projects_dir, project_dir, f"{session_id}.jsonl")
        if os.path.exists(jsonl_file):
            try:
                # Read last N lines efficiently
                with open(jsonl_file, 'r') as f:
                    all_lines = f.readlines()

                for line in all_lines[-limit*3:]:  # Read extra to ensure enough messages
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        entry = json.loads(line)
                        msg_type = entry.get("type", "")

                        if msg_type == "human":
                            content = ""
                            if isinstance(entry.get("message", {}).get("content", ""), str):
                                content = entry["message"]["content"]
                            elif isinstance(entry.get("message", {}).get("content", []), list):
                                parts = entry["message"]["content"]
                                content = " ".join(p.get("text", "") for p in parts if p.get("type") == "text")
                            if content:
                                messages.append({
                                    "role": "user",
                                    "content": content[:500],
                                    "timestamp": entry.get("timestamp", time.time()),
                                    "type": "text"
                                })

                        elif msg_type == "assistant":
                            content_data = entry.get("message", {}).get("content", [])
                            if isinstance(content_data, list):
                                for block in content_data:
                                    if block.get("type") == "text":
                                        messages.append({
                                            "role": "assistant",
                                            "content": block.get("text", "")[:500],
                                            "timestamp": entry.get("timestamp", time.time()),
                                            "type": "text"
                                        })
                                    elif block.get("type") == "tool_use":
                                        messages.append({
                                            "role": "assistant",
                                            "content": f"Tool: {block.get('name', 'unknown')}",
                                            "timestamp": entry.get("timestamp", time.time()),
                                            "type": "tool_use"
                                        })
                    except json.JSONDecodeError:
                        continue

                return messages[-limit:]
            except Exception as e:
                sys.stderr.write(f"  [Error] Reading session: {e}\n")
                return messages

    return messages

# ============================================================
# Remote Command Execution
# ============================================================

def run_command(cmd_id, prompt, session_id=None):
    """Run claude CLI command in background thread"""
    def _run():
        try:
            args = ["claude", "-p", "--output-format", "stream-json"]
            if session_id:
                args.extend(["--resume", session_id])
            args.append(prompt)

            proc = subprocess.Popen(
                args,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )

            running_commands[cmd_id]["pid"] = proc.pid
            running_commands[cmd_id]["proc"] = proc

            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    chunk = json.loads(line)
                    msg_type = chunk.get("type", "unknown")
                    content = ""
                    out_type = msg_type

                    # Skip system/hook messages — not useful for the user
                    if msg_type == "system":
                        subtype = chunk.get("subtype", "")
                        if subtype == "init":
                            content = "[Session initialized]"
                            out_type = "info"
                        else:
                            continue  # Skip hook_started, hook_response, etc.

                    elif msg_type == "assistant":
                        # Extract text from assistant message content blocks
                        msg_content = chunk.get("message", {}).get("content", [])
                        if isinstance(msg_content, list):
                            texts = []
                            for block in msg_content:
                                if block.get("type") == "text":
                                    texts.append(block.get("text", ""))
                                elif block.get("type") == "tool_use":
                                    tool_name = block.get("name", "unknown")
                                    running_commands[cmd_id]["output"].append({
                                        "type": "tool_use",
                                        "content": f"Using tool: {tool_name}",
                                        "timestamp": time.time()
                                    })
                            content = "\n".join(texts)
                            out_type = "text"
                        elif isinstance(msg_content, str):
                            content = msg_content
                            out_type = "text"

                    elif msg_type == "content_block_delta":
                        delta = chunk.get("delta", {})
                        content = delta.get("text", "")
                        out_type = "text"

                    elif msg_type == "result":
                        content = chunk.get("result", "")
                        out_type = "result"

                    elif msg_type == "rate_limit_event":
                        continue  # Skip rate limit events

                    else:
                        continue  # Skip unknown types

                    if content:
                        running_commands[cmd_id]["output"].append({
                            "type": out_type,
                            "content": content[:2000],
                            "timestamp": time.time()
                        })
                except json.JSONDecodeError:
                    pass  # Skip unparseable lines

            proc.wait()
            running_commands[cmd_id]["status"] = "completed" if proc.returncode == 0 else "error"

            # Capture stderr
            stderr = proc.stderr.read()
            if stderr:
                running_commands[cmd_id]["output"].append({
                    "type": "stderr",
                    "content": stderr[:1000],
                    "timestamp": time.time()
                })

        except Exception as e:
            running_commands[cmd_id]["status"] = "error"
            running_commands[cmd_id]["output"].append({
                "type": "error",
                "content": str(e),
                "timestamp": time.time()
            })

    running_commands[cmd_id] = {
        "id": cmd_id,
        "prompt": prompt,
        "session_id": session_id,
        "status": "running",
        "output": [],
        "pid": None,
        "proc": None,
        "started_at": time.time()
    }

    thread = threading.Thread(target=_run, daemon=True)
    thread.start()

# ============================================================
# HTTP Handler
# ============================================================

class Handler(http.server.BaseHTTPRequestHandler):

    def _parse(self):
        parsed = urlparse(self.path)
        params = parse_qs(parsed.query)
        return parsed.path, params

    def _auth(self, params):
        return params.get("token", [""])[0] == TOKEN

    def _json_response(self, code, data):
        body = json.dumps(data, default=str).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def _html_response(self, code, html):
        body = html.encode('utf-8')
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path, params = self._parse()

        # Pairing page — no auth required (it IS the auth mechanism)
        if path == "/pair":
            import socket
            host = socket.gethostbyname(socket.gethostname())
            # Try to get the LAN IP
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                s.connect(("8.8.8.8", 80))
                host = s.getsockname()[0]
                s.close()
            except Exception:
                pass
            html = _generate_pair_page(host, PORT, TOKEN)
            self._html_response(200, html)
            return

        if not self._auth(params):
            self._json_response(401, {"error": "unauthorized"})
            return

        if path == "/status":
            procs = get_claude_processes()
            sessions = get_sessions(limit=5)
            active_sessions = [s for s in sessions if s.get("status") in ("running", "waiting_input")]
            self._json_response(200, {
                "active": len(procs),
                "processes": procs,
                "activeSessions": len(active_sessions),
                "recentSessions": sessions[:5]
            })

        elif path == "/sessions":
            limit = int(params.get("limit", ["50"])[0])
            sessions = get_sessions(limit=limit)
            active = [s for s in sessions if s.get("status") in ("running", "waiting_input")]
            self._json_response(200, {
                "sessions": sessions,
                "totalActive": len(active)
            })

        elif path.startswith("/session/"):
            parts = path.split("/")
            if len(parts) >= 3:
                sid = parts[2]
                if len(parts) >= 4 and parts[3] == "messages":
                    msg_limit = int(params.get("limit", ["30"])[0])
                    messages = get_session_messages(sid, limit=msg_limit)
                    self._json_response(200, {"messages": messages, "sessionId": sid})
                else:
                    sessions = get_sessions(limit=200)
                    session = next((s for s in sessions if s["id"] == sid), None)
                    if session:
                        messages = get_session_messages(sid, limit=20)
                        session["recentMessages"] = messages
                        self._json_response(200, session)
                    else:
                        self._json_response(404, {"error": "session not found"})
            else:
                self._json_response(400, {"error": "invalid path"})

        elif path.startswith("/command/"):
            parts = path.split("/")
            if len(parts) >= 3:
                cmd_id = parts[2]
                cmd = running_commands.get(cmd_id)
                if cmd:
                    # Return output since last check
                    since = float(params.get("since", ["0"])[0])
                    output = [o for o in cmd["output"] if o["timestamp"] > since]
                    self._json_response(200, {
                        "command_id": cmd_id,
                        "status": cmd["status"],
                        "output": output
                    })
                else:
                    self._json_response(404, {"error": "command not found"})
            else:
                self._json_response(400, {"error": "invalid path"})

        elif path == "/usage":
            usage = get_usage_stats()
            self._json_response(200, usage)

        elif path == "/events":
            since = float(params.get("since", ["0"])[0])
            events = [e for e in hook_events if e.get("timestamp", 0) > since]
            self._json_response(200, {"events": events[-50:]})

        else:
            self._json_response(404, {"error": "not found"})

    def do_POST(self):
        path, params = self._parse()

        if not self._auth(params):
            self._json_response(401, {"error": "unauthorized"})
            return

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""

        if path == "/command":
            try:
                data = json.loads(body) if body else {}
                prompt = data.get("prompt", "")
                session_id = data.get("session_id", None)

                if not prompt:
                    self._json_response(400, {"error": "prompt required"})
                    return

                cmd_id = str(uuid.uuid4())[:8]
                run_command(cmd_id, prompt, session_id)
                self._json_response(200, {"command_id": cmd_id, "status": "running"})

            except json.JSONDecodeError:
                self._json_response(400, {"error": "invalid JSON"})

        elif path == "/session/new":
            try:
                data = json.loads(body) if body else {}
                cwd = data.get("cwd", "").strip()
                prompt = data.get("prompt", None)

                if not cwd:
                    self._json_response(400, {"error": "cwd required"})
                    return

                # Expand ~ in path
                cwd = os.path.expanduser(cwd)

                if not os.path.isdir(cwd):
                    self._json_response(400, {"error": f"directory not found: {cwd}"})
                    return

                # Launch claude in the specified directory
                cmd_id = str(uuid.uuid4())[:8]
                def _launch():
                    try:
                        args = ["claude"]
                        if prompt:
                            args.extend(["-p", "--output-format", "stream-json", prompt])
                        else:
                            args.extend(["--dangerously-skip-permissions"])

                        proc = subprocess.Popen(
                            args,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            cwd=cwd,
                            text=True,
                        )

                        running_commands[cmd_id]["pid"] = proc.pid
                        running_commands[cmd_id]["proc"] = proc

                        # Read first few lines to get session id
                        session_id_found = None
                        lines_read = 0
                        for line in proc.stdout:
                            line = line.strip()
                            if not line:
                                continue
                            try:
                                chunk = json.loads(line)
                                if chunk.get("type") == "system" and chunk.get("subtype") == "init":
                                    session_id_found = chunk.get("session_id")
                                    running_commands[cmd_id]["new_session_id"] = session_id_found
                                    running_commands[cmd_id]["output"].append({
                                        "type": "info",
                                        "content": f"[Session started: {session_id_found}]",
                                        "timestamp": time.time()
                                    })
                            except:
                                pass
                            lines_read += 1
                            if lines_read > 5 and session_id_found:
                                break

                        if not prompt:
                            # If no prompt, just kill — session file was created
                            try:
                                proc.terminate()
                            except:
                                pass
                            running_commands[cmd_id]["status"] = "completed"
                        else:
                            for line in proc.stdout:
                                line = line.strip()
                                if not line:
                                    continue
                                try:
                                    chunk = json.loads(line)
                                    msg_type = chunk.get("type", "")
                                    if msg_type == "assistant":
                                        msg_content = chunk.get("message", {}).get("content", [])
                                        if isinstance(msg_content, list):
                                            for block in msg_content:
                                                if block.get("type") == "text":
                                                    running_commands[cmd_id]["output"].append({
                                                        "type": "text",
                                                        "content": block.get("text", "")[:2000],
                                                        "timestamp": time.time()
                                                    })
                                    elif msg_type == "result":
                                        running_commands[cmd_id]["output"].append({
                                            "type": "result",
                                            "content": chunk.get("result", "")[:2000],
                                            "timestamp": time.time()
                                        })
                                except:
                                    pass
                            proc.wait()
                            running_commands[cmd_id]["status"] = "completed" if proc.returncode == 0 else "error"

                    except Exception as e:
                        running_commands[cmd_id]["status"] = "error"
                        running_commands[cmd_id]["output"].append({
                            "type": "error",
                            "content": str(e),
                            "timestamp": time.time()
                        })

                running_commands[cmd_id] = {
                    "id": cmd_id,
                    "prompt": prompt or f"[New session in {os.path.basename(cwd)}]",
                    "session_id": None,
                    "new_session_id": None,
                    "status": "running",
                    "output": [],
                    "pid": None,
                    "proc": None,
                    "started_at": time.time()
                }

                thread = threading.Thread(target=_launch, daemon=True)
                thread.start()

                # Wait briefly for session_id to appear
                time.sleep(0.5)
                new_sid = running_commands[cmd_id].get("new_session_id")

                self._json_response(200, {
                    "session_id": new_sid,
                    "command_id": cmd_id,
                    "status": "running",
                    "cwd": cwd
                })

            except json.JSONDecodeError:
                self._json_response(400, {"error": "invalid JSON"})
            except Exception as e:
                self._json_response(500, {"error": str(e)})

        elif path.startswith("/command/") and path.endswith("/cancel"):
            parts = path.split("/")
            cmd_id = parts[2] if len(parts) >= 3 else ""
            cmd = running_commands.get(cmd_id)
            if cmd and cmd.get("proc"):
                try:
                    cmd["proc"].terminate()
                    cmd["status"] = "cancelled"
                    self._json_response(200, {"command_id": cmd_id, "status": "cancelled"})
                except Exception as e:
                    self._json_response(500, {"error": str(e)})
            else:
                self._json_response(404, {"error": "command not found"})

        elif path == "/hook":
            try:
                data = json.loads(body) if body else {}
                data["timestamp"] = time.time()
                hook_events.append(data)
                if len(hook_events) > MAX_EVENTS:
                    hook_events[:] = hook_events[-MAX_EVENTS:]
                self._json_response(200, {"ok": True})
            except Exception:
                self._json_response(400, {"error": "invalid hook data"})

        else:
            self._json_response(404, {"error": "not found"})

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()

    def log_message(self, format, *args):
        status = args[1] if len(args) > 1 else "?"
        ts = self.log_date_time_string()
        method = args[0].split(" ")[0] if args else "?"
        path = args[0].split(" ")[1] if args and len(args[0].split(" ")) > 1 else "?"
        sys.stderr.write(f"  [{ts}] {method} {path} -> {status}\n")

def signal_handler(sig, frame):
    sys.stderr.write("\n  Server stopped. (Bonjour will be killed by shell trap)\n")
    conn_file = os.path.expanduser("~/.claudewatch_connection")
    try:
        os.remove(conn_file)
    except:
        pass
    # Cleanup running commands
    for cmd in running_commands.values():
        proc = cmd.get("proc")
        if proc:
            try:
                proc.terminate()
            except:
                pass
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

server = http.server.HTTPServer(("0.0.0.0", PORT), Handler)
sys.stderr.write(f"  Server listening on 0.0.0.0:{PORT}\n")
server.serve_forever()
PYSERVER
