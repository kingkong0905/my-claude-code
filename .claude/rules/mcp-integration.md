---
paths:
  - .mcp.json
  - contexts/**
---

# MCP Integration

## Tool Selection Decision Tree

**GitHub operations:**

- ✅ Use: `gh` CLI via Bash tool
- ❌ Never: GitHub MCP server
- Examples: PRs, issues, code search, fetch files from repos

**Confluence/Jira operations:**

- ✅ Use: Atlassian MCP tools (`mcp__atlassian__*`)
- ❌ Never: WebFetch on Atlassian URLs (requires OAuth)
- Examples: Search docs, fetch pages, get issues
- **Always use `contentFormat: "markdown"`** for Confluence page reads/writes (never ADF)
- **Always use Markdown** for Jira write operations: `description` in `createJiraIssue`/`editJiraIssue`, `commentBody` in `addCommentToJiraIssue` (never ADF)

**When given URLs:**

- `github.com/*` → Extract info, use gh CLI
- `*.atlassian.net/*` → Extract IDs, use MCP tools

---

## Configuration

MCP servers are defined in `.mcp.json` (plugin root directory):

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "description": "Jira, Confluence, Compass (OAuth)"
    },
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "claude-code",
        "--project-from-cwd",
        "--open-web-dashboard",
        "False"
      ],
      "description": "Semantic code navigation (optimized for large repos)"
    }
  }
}
```

**Key MCP Integrations:**

- **Atlassian**: Jira, Confluence, Compass (HTTP/OAuth)
- **Serena**: Semantic code understanding (stdio/LSP)
- **GitHub**: Use `gh` CLI directly (not MCP)

## Serena Integration

**Serena** provides IDE-like semantic code understanding:

**When to Use:**

- ✅ Large codebases (>100 files)
- ✅ Finding symbol definitions/references
- ✅ Understanding code structure
- ✅ Refactoring operations

**When NOT to Use:**

- ❌ Small projects (<10 files)
- ❌ Text searches in comments/strings
- ❌ Reading config files

## Calling MCP from Hook Scripts (mcporter)

Hook scripts can call MCP tools via **mcporter** — a lightweight JS runtime that auto-discovers servers from `.mcp.json`.

**Setup:** `mcporter` is listed in `package.json` dependencies. Run `npm install` once.

**Config:** `config/mcporter.json` imports servers from Claude Code's `.mcp.json`:

```json
{ "mcpServers": {}, "imports": ["claude-code"] }
```

**Usage in a hook script:**

```js
import { callMcp } from "./lib/mcp.js";

try {
  const result = await callMcp("atlassian", "searchJiraIssuesUsingJql", {
    jql: 'assignee = currentUser() AND status = "In Progress" ORDER BY updated DESC',
    maxResults: 5,
  });
  const issues = result?.json()?.issues ?? [];
} catch {
  // Not authenticated or timed out — skip
}
```

See [hook-development.md](hook-development.md) for when MCP calls are appropriate in each hook type.

## Troubleshooting

### Atlassian MCP Not Working

```bash
# Test Atlassian MCP server
npx -y @modelcontextprotocol/server-atlassian

# Verify .mcp.json syntax
cat .mcp.json | jq .
```

### Serena Not Indexing

```bash
# Check Serena installation
uvx --from "git+https://github.com/oraios/serena" serena --version

# Force reindex
uvx --from "git+https://github.com/oraios/serena" serena reindex
```

### GitHub CLI Issues

```bash
# Verify gh CLI installation
gh --version

# Check authentication
gh auth status
```
