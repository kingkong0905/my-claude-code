#!/bin/bash
# Claude Code Statusline Template

# Colors (customize these hex values)
GIT_BRANCH_COLOR="#10b981"    # green
GIT_STATUS_COLOR="#f59e0b"    # amber
DIRECTORY_COLOR="#3b82f6"     # blue
MODEL_COLOR="#8b5cf6"         # purple
TOKENS_COLOR="#ec4899"        # pink
COST_COLOR="#ef4444"          # red
USED_PCT_ICON_COLOR="#f97316"    # orange

# Icons (Nerd Font - customize these)
GIT_BRANCH_ICON="🌿"
GIT_STATUS_ICON="☁️"
DIRECTORY_ICON="📁"
MODEL_ICON="🚀"
TOKENS_ICON="🔥"
COST_ICON="💰"
USED_PCT_ICON="📊"

# Helper function to colorize text
colorize() {
    local color=$1
    local text=$2
    echo "\033[38;2;$(printf '%d;%d;%d' 0x${color:1:2} 0x${color:3:2} 0x${color:5:2})m${text}\033[0m"
}

# Read JSON input from stdin (Claude Code sends context as JSON)
input=$(cat)

output=""

# Git branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")
    output+="$(colorize "$GIT_BRANCH_COLOR" "$GIT_BRANCH_ICON $branch") "

    # Git status
    uncommitted=$(git --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    ahead=$(git --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    behind=$(git --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

    if [ "$uncommitted" != "0" ] || [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
        output+="$(colorize "$GIT_STATUS_COLOR" "$GIT_STATUS_ICON ${uncommitted}↕${ahead}↓${behind}") "
    fi
fi

# Directory
directory=$(basename "$PWD")
output+="$(colorize "$DIRECTORY_COLOR" "$DIRECTORY_ICON $directory") "

# Model (from Claude Code JSON input)
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
output+="$(colorize "$MODEL_COLOR" "$MODEL_ICON $model_name") "

# Context window usage (from Claude Code JSON input)
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)
if [ -n "$remaining" ]; then
    remaining_formatted=$(printf "%.1f" "$remaining")
    output+="$(colorize "$TOKENS_COLOR" "$TOKENS_ICON ${remaining_formatted}% left")"
fi

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

COST_FMT=$(printf '$%.2f' "$COST")
output+="$(colorize "$COST_COLOR" "$COST_ICON $COST_FMT") "

PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▓')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

output+="$(colorize "$USED_PCT_ICON_COLOR" "$USED_PCT_ICON $BAR $PCT%") "
echo -e "$output"
