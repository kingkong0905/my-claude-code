#!/bin/bash
# Claude Code Statusline Template

# Colors (customize these hex values)
GIT_BRANCH_COLOR="#10b981"    # green
GIT_STATUS_COLOR="#f59e0b"    # amber
DIRECTORY_COLOR="#3b82f6"     # blue
MODEL_COLOR="#8b5cf6"         # purple
TOKENS_COLOR="#ec4899"        # pink
COST_COLOR="#ef4444"          # red
USED_PCT_ICON_COLOR="#f97316" # orange
USAGE_OK_COLOR="#10b981"      # green  (< 70%)
USAGE_WARN_COLOR="#f59e0b"    # amber  (70–89%)
USAGE_CRIT_COLOR="#ef4444"    # red    (>= 90%)

# Icons (Nerd Font - customize these)
GIT_BRANCH_ICON="🌿"
GIT_STATUS_ICON="☁️"
DIRECTORY_ICON="📁"
MODEL_ICON="🚀"
TOKENS_ICON="🔥"
COST_ICON="💰"
USED_PCT_ICON="📊"
RESET_ICON="📅"
USAGE_ICON="💳"

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
fi

# Directory
directory=$(basename "$PWD")
output+="$(colorize "$DIRECTORY_COLOR" "$DIRECTORY_ICON $directory") "

# Model (from Claude Code JSON input)
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
output+="$(colorize "$MODEL_COLOR" "$MODEL_ICON $model_name") "

# Context window remaining
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)
if [ -n "$remaining" ]; then
    remaining_formatted=$(printf "%.1f" "$remaining")
    output+="$(colorize "$TOKENS_COLOR" "$TOKENS_ICON ${remaining_formatted}% left") "
fi

# Session cost
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")
output+="$(colorize "$COST_COLOR" "$COST_ICON $COST_FMT") "

# Context window progress bar
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▓')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"
output+="$(colorize "$USED_PCT_ICON_COLOR" "$USED_PCT_ICON $BAR $PCT%") "



# ── Usage limits: current / weekly / extra + reset times ─────────────────────
# Uses OAuth token from macOS Keychain (same credential Claude Code uses).
# Cached 5 min; negative-cached 10 min on failure to avoid hammering the API.

cache_dir="$HOME/.claude/cache"
cache_file="$cache_dir/statusline-usage-cache.json"
neg_cache_file="$cache_dir/statusline-usage-neg-cache"
mkdir -p "$cache_dir"

get_oauth_token() {
    [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ] && { echo "$CLAUDE_CODE_OAUTH_TOKEN"; return; }
    if command -v security >/dev/null 2>&1; then
        local blob token
        blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
        [ -n "$token" ] && [ "$token" != "null" ] && { echo "$token"; return; }
    fi
    if [ -f "$HOME/.claude/.credentials.json" ]; then
        jq -r '.claudeAiOauth.accessToken // empty' "$HOME/.claude/.credentials.json" 2>/dev/null
    fi
}

build_bar() {
    local pct=$1 width=$2
    [ "$pct" -lt 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar_color
    if [ "$pct" -ge 90 ]; then bar_color='\033[38;2;255;85;85m'
    elif [ "$pct" -ge 70 ]; then bar_color='\033[38;2;230;200;0m'
    elif [ "$pct" -ge 50 ]; then bar_color='\033[38;2;255;176;85m'
    else bar_color='\033[38;2;0;160;0m'
    fi
    local f="" e=""
    for ((i=0; i<filled; i++)); do f+="●"; done
    for ((i=0; i<empty;  i++)); do e+="○"; done
    printf "${bar_color}${f}\033[2m${e}\033[0m"
}

iso_to_epoch() {
    local s="$1"
    local epoch
    epoch=$(date -d "$s" +%s 2>/dev/null) && { echo "$epoch"; return; }
    local stripped="${s%%.*}"; stripped="${stripped%%Z}"; stripped="${stripped%%+*}"
    stripped="${stripped%%-[0-9][0-9]:[0-9][0-9]}"
    if [[ "$s" == *Z* ]] || [[ "$s" == *+00:00* ]]; then
        epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    fi
    [ -n "$epoch" ] && echo "$epoch"
}

fmt_reset() {
    local iso="$1" style="$2"
    [ -z "$iso" ] || [ "$iso" = "null" ] && return
    local epoch; epoch=$(iso_to_epoch "$iso") || return
    case "$style" in
        time)
            date -j -r "$epoch" +"%l:%M%p" 2>/dev/null | sed 's/^ //' | tr '[:upper:]' '[:lower:]' ||
            date -d "@$epoch" +"%l:%M%P" 2>/dev/null | sed 's/^ //' ;;
        datetime)
            date -j -r "$epoch" +"%b %-d, %l:%M%p" 2>/dev/null | sed 's/  / /g;s/^ //' | tr '[:upper:]' '[:lower:]' ||
            date -d "@$epoch" +"%b %-d, %l:%M%P" 2>/dev/null | sed 's/  / /g;s/^ //' ;;
        *)
            date -j -r "$epoch" +"%b %-d" 2>/dev/null | tr '[:upper:]' '[:lower:]' ||
            date -d "@$epoch" +"%b %-d" 2>/dev/null ;;
    esac
}

# Check / refresh cache
needs_refresh=true
usage_data=""
now=$(date +%s)

if [ -f "$cache_file" ]; then
    _mt=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    if [ $(( now - _mt )) -lt 300 ]; then
        needs_refresh=false
        usage_data=$(cat "$cache_file")
    fi
fi

if $needs_refresh && [ -f "$neg_cache_file" ]; then
    _nmt=$(stat -f %m "$neg_cache_file" 2>/dev/null || stat -c %Y "$neg_cache_file" 2>/dev/null)
    [ $(( now - _nmt )) -lt 600 ] && needs_refresh=false
fi

if $needs_refresh; then
    _token=$(get_oauth_token)
    if [ -n "$_token" ] && [ "$_token" != "null" ]; then
        _ver=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        _resp=$(curl -s --max-time 5 \
            -H "Authorization: Bearer $_token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/${_ver:-2.1.69}" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if [ -n "$_resp" ] && echo "$_resp" | jq -e 'has("error") | not' >/dev/null 2>&1; then
            usage_data="$_resp"
            echo "$_resp" > "$cache_file"
            rm -f "$neg_cache_file"
        else
            touch "$neg_cache_file"
        fi
    fi
fi

[ -z "$usage_data" ] && [ -f "$cache_file" ] && usage_data=$(cat "$cache_file")

if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
    bw=10
    dim='\033[2m' rst='\033[0m' wht='\033[38;2;220;220;220m' cyn='\033[38;2;46;149;153m'

    # 5-hour
    five_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f",$1}')
    five_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    five_reset=$(fmt_reset "$five_iso" "time")
    five_bar=$(build_bar "$five_pct" $bw)

    # 7-day
    seven_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | awk '{printf "%.0f",$1}')
    seven_iso=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')
    seven_reset=$(fmt_reset "$seven_iso" "datetime")
    seven_bar=$(build_bar "$seven_pct" $bw)

    sep=" ${dim}|${rst} "
    # Extra usage (optional)
    extra_enabled=$(echo "$usage_data" | jq -r '.extra_usage.is_enabled // false')
    if [ "$extra_enabled" = "true" ]; then
        extra_pct=$(echo "$usage_data" | jq -r '.extra_usage.utilization // 0' | awk '{printf "%.0f",$1}')
        extra_used=$(echo "$usage_data" | jq -r '.extra_usage.used_credits // 0' | awk '{printf "%.2f",$1/100}')
        extra_limit=$(echo "$usage_data" | jq -r '.extra_usage.monthly_limit // 0' | awk '{printf "%.2f",$1/100}')
        extra_bar=$(build_bar "$extra_pct" $bw)
        extra_reset=$(date -v+1m -v1d +"%b %-d" 2>/dev/null | tr '[:upper:]' '[:lower:]')

        output+="$(colorize "$GIT_BRANCH_COLOR" "$USAGE_ICON $extra_used/\$${extra_limit}") "
    fi

    # Line 3: reset times
    [ "$extra_enabled" = "true" ] && [ -n "$extra_reset" ] && \
        output+="$(colorize "$GIT_BRANCH_COLOR" "$RESET_ICON $extra_reset") "
fi
echo -e "$output"
