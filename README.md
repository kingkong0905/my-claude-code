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
