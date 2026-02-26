# kkclaude

Personal Claude Code plugin focused on Jira ticket drafting.

## Structure

```
kkclaude/
├── .claude-plugin/          # Plugin manifest
├── agents/                  # Autonomous agent definitions
├── skills/                  # Skill slash commands
├── hooks/                   # Lifecycle automation scripts
│   ├── hooks.json
│   └── scripts/
├── package.json
└── CLAUDE.md
```

## Skills (Slash Commands)

| Command                 | Description                                    |
| ----------------------- | ---------------------------------------------- |
| `/kkclaude:jira-ticket` | Draft a Jira ticket with Overview, Context, AC |

## Agents

| Agent                | Model  | Purpose                                |
| -------------------- | ------ | -------------------------------------- |
| `jira-ticket-writer` | sonnet | Draft Jira tickets in Jira wiki markup |

## Hooks

| Event                      | Script                  | Purpose                  |
| -------------------------- | ----------------------- | ------------------------ |
| `UserPromptSubmit`         | `user-prompt-submit.js` | Inject git context       |
| `SessionStart`             | `session-start.js`      | Log session info         |
| `PreToolUse[Bash]`         | `bash-safety-check.js`  | Block dangerous commands |
| `PostToolUse[Edit\|Write]` | `auto-format.js`        | Auto-format on save      |

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
