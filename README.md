# kkclaude

Personal Claude Code plugin for Jira ticket drafting and engineering proposal writing.

## Structure

```
kkclaude/
├── .claude-plugin/          # Plugin manifest
├── agents/                  # Autonomous agent definitions
├── skills/                  # Skill slash commands
├── hooks/                   # Lifecycle automation scripts
│   ├── hooks.json
│   └── scripts/
│       └── lib/
│           └── mcp.js       # mcporter wrapper for hook scripts
├── config/
│   └── mcporter.json        # mcporter config (imports .mcp.json servers)
├── package.json
└── CLAUDE.md
```

## Skills (Slash Commands)

| Command                          | Description                                             |
| -------------------------------- | ------------------------------------------------------- |
| `/kkclaude:jira-ticket`          | Draft a Jira ticket with Overview, Context, AC          |
| `/kkclaude:engineering-proposal` | Draft an engineering proposal, RFC, or architecture ADR |

## Agents

| Agent                      | Model  | Purpose                                                    |
| -------------------------- | ------ | ---------------------------------------------------------- |
| `kkclaude:ticket-create`   | sonnet | Draft Jira tickets in Jira wiki markup                     |
| `kkclaude:proposal-writer` | sonnet | Draft engineering proposals and architecture decision docs |

## Hooks

| Event                      | Script                  | Purpose                                           |
| -------------------------- | ----------------------- | ------------------------------------------------- |
| `SessionStart`             | `session-start.js`      | Log session info + fetch in-progress Jira tickets |
| `UserPromptSubmit`         | `user-prompt-submit.js` | Inject git context into every prompt              |
| `PreToolUse[Bash]`         | `bash-safety-check.js`  | Block dangerous shell commands                    |
| `PostToolUse[Edit\|Write]` | `auto-format.js`        | Auto-format edited files on save                  |

## MCP Integration (mcporter)

Hook scripts call MCP tools (Atlassian/Jira) via **[mcporter](https://github.com/steipete/mcporter)** — a lightweight JS runtime that auto-discovers servers from `.mcp.json`.

`config/mcporter.json` uses `"imports": ["claude-code"]` so `.mcp.json` is the single source of truth — no config duplication.

### Installation

mcporter is included in `package.json`. Install with:

```bash
npm install
```

Or install globally for CLI access:

```bash
brew install steipete/tap/mcporter
# or
pnpm add -g mcporter
```

### Atlassian OAuth Setup

The `atlassian` MCP server uses OAuth. Authenticate once before using Jira-enriched hooks:

```bash
npx mcporter auth atlassian
```

This opens a browser login and caches the token under `~/.mcporter/atlassian/`.

Verify it works and retrieve your **Cloud ID** (required for every Atlassian tool call):

```bash
npx mcporter call atlassian.getAccessibleAtlassianResources
```

Copy the `id` field from the response. Set it as an environment variable so hooks can use it:

```bash
export ATLASSIAN_CLOUD_ID=<id-from-above>
# Add to ~/.zshrc or ~/.zshenv to persist across sessions
```

### Troubleshooting

**Session-start Jira fetch silently skipped**

The `SessionStart` hook attempts to fetch in-progress Jira tickets with a 3-second timeout. It is silently skipped when:

- mcporter is not installed (`npm install` not run)
- Atlassian OAuth token is missing or expired → run `npx mcporter auth atlassian`
- Network is unavailable

To debug interactively:

```bash
npx mcporter call atlassian.searchJiraIssuesUsingJql \
  cloudId:'<CLOUD_ID>' \
  jql:'assignee = currentUser() AND status = "In Progress"' \
  maxResults:5
```

**Timeouts on slow networks**

Override the default call timeout via environment variable:

```bash
MCPORTER_CALL_TIMEOUT=10000 npx mcporter list
```

Or set it permanently in your shell profile:

```bash
export MCPORTER_CALL_TIMEOUT=10000
```

**Debug logs**

```bash
npx mcporter list --log-level debug
```

**Test ad-hoc without editing config**

```bash
# Test against Atlassian MCP directly
npx mcporter list --http-url https://mcp.atlassian.com/v1/mcp
```

## Development

```bash
npm install
npm run lint
npm run lint:fix
```

## Installation

```bash
claude plugin install /path/to/kkclaude
```
