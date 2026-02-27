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

## Releases

This project uses [release-please](https://github.com/googleapis/release-please) for automated releases.

### Normal Release Process

1. Make changes with conventional commits (feat:, fix:, etc.)
2. Merge to main branch
3. Release-please automatically creates a PR with version bump and CHANGELOG
4. Merge the release-please PR
5. Release-please automatically creates the GitHub release

### Manual Release Creation

If a release needs to be created manually:

1. Go to Actions → [Manual Release workflow](https://github.com/kingkong0905/my-claude-code/actions/workflows/manual-release.yml)
2. Click "Run workflow"
3. Enter the version number (e.g., `0.5.0`)
4. Click "Run workflow"

See [RELEASE_INSTRUCTIONS.md](./RELEASE_INSTRUCTIONS.md) for detailed instructions.

## Installation

```bash
claude plugin install /path/to/kkclaude
```
