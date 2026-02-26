# Overview

This is the **kkclaude Claude Code Plugin** - a personal plugin that provides workflow automation and custom skills for agent-first development.

**Important**: These files guide Claude when working ON this plugin repository. The plugin affects behavior in target repositories through:

- **Skills** (in `skills/`) - Loaded into context when plugin is active
- **Agents** (in `agents/`) - Available for task delegation
- **Hooks** (in `hooks/`) - Execute at lifecycle events
- **MCP integrations** (via `.mcp.json`) - Provide external tools

## Rules Organization

Rules files use **path-targeted frontmatter** to load only when working on relevant files:

```text
.claude/rules/
├── overview.md              # Always loaded - repository structure (this file)
├── prerequisites.md         # Always loaded - read docs first
├── principles.md            # Always loaded - design philosophy
├── best-practices.md        # Always loaded - development standards
├── agent-development.md     # Path: agents/** - agent development guide
├── skill-development.md     # Path: skills/** - skill development guide
├── hook-development.md      # Path: hooks/** - hook development guide
├── mcp-integration.md       # Path: .mcp.json, contexts/** - MCP configuration
├── testing.md               # Path: **/*test*, **/*spec* - testing guide
└── distribution.md          # Path: *.md, docs/**, examples/** - installation
```

**Priority hierarchy** (per Claude Code docs):

1. **Highest**: CLAUDE.md (operational workflows, always loaded)
2. **High**: .claude/rules without path targeting (core rules, always loaded)
3. **High, path-filtered**: .claude/rules with path targeting (domain rules)
4. **Medium**: Skills (loaded on-demand by Claude)
5. **Standard**: Regular file contents (read when needed)

## Repository Structure

```text
my-claude-code/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace metadata
├── agents/                      # Autonomous agents
├── skills/                      # Skills (commands + knowledge)
├── hooks/                       # Lifecycle automation
│   ├── hooks.json               # Hook definitions
│   └── scripts/                 # Hook implementation scripts
├── .mcp.json                    # MCP server configurations
├── .claude/rules/               # Plugin development guidelines (see above)
├── CLAUDE.md                    # Operational workflow (orchestration)
└── README.md                    # User guide (for plugin users)
```
