---
paths: hooks/**
---

# Hook Development

## Structure

Hooks are defined in `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "node hooks/scripts/bash-safety-check.js",
          "description": "Prevent destructive operations",
          "blocking": true
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Edit",
      "hooks": [
        {
          "type": "command",
          "command": "./hooks/scripts/auto-format.sh",
          "description": "Auto-format after edits"
        }
      ]
    }
  ]
}
```

## Hook Events

| Event                  | When It Fires            | Use For                                    |
| ---------------------- | ------------------------ | ------------------------------------------ |
| **UserPromptSubmit**   | Before each user message | Inject context (todos, git status)         |
| **SessionStart**       | Session begins           | Restore session context, initialization    |
| **PreToolUse**         | Before tool execution    | Safety checks (bash commands, file edits)  |
| **PostToolUse**        | After tool execution     | Auto-formatting, logging                   |
| **PostToolUseFailure** | Tool execution fails     | Failure analysis, recovery suggestions     |
| **Stop**               | User requests stop       | Check if work complete, continue if needed |
| **SessionEnd**         | Session ends             | Save session context                       |

## Hook Scripts

Scripts live in `hooks/scripts/` and must:

- Use ESM (`import`/`export`) — `"type": "module"` in package.json
- Read tool input from stdin (JSON)
- Exit with code `0` to allow, `1` to block (PreToolUse only)
- Be fast (< 1 second) — they run on every tool call

```bash
# Test a hook manually
echo '{"tool_input":{"command":"rm -rf /"}}' | node hooks/scripts/bash-safety-check.js
```

## Calling MCP Tools from Hooks (mcporter)

Use the shared `hooks/scripts/lib/mcp.js` wrapper to call MCP servers (Atlassian, etc.) from hook scripts. Servers are auto-discovered from `.mcp.json` via `config/mcporter.json`.

```js
import { callMcp } from "./lib/mcp.js";

// Single MCP tool call with 3 s timeout
const result = await callMcp("atlassian", "searchJiraIssuesUsingJql", {
  jql: 'assignee = currentUser() AND status = "In Progress" ORDER BY updated DESC',
  maxResults: 5,
});
const issues = result?.json()?.issues ?? [];
```

**When to use MCP in hooks:**

| Hook             | MCP calls OK? | Why                                       |
| ---------------- | ------------- | ----------------------------------------- |
| SessionStart     | ✅ Yes        | Fires once — latency acceptable           |
| UserPromptSubmit | ⚠️ Careful    | Fires on every message — keep calls short |
| PreToolUse       | ❌ No         | Fires on every tool call — must be < 1 s  |
| PostToolUse      | ❌ No         | Same as PreToolUse                        |

**Always wrap in try/catch** — mcporter is silently skipped if not installed or Atlassian is not authenticated.

## Best Practices

1. **Fail fast**: Exit early with clear error messages
2. **Performance**: Cache results when possible (SHA256 caching)
3. **Blocking vs. Warning**: Block for critical issues, warn for suggestions
4. **User feedback**: Clear, actionable messages
5. **Stack detection**: Adapt to target repo's tech stack
6. **Context injection**: Use hooks to provide runtime context (git status, todos)

## Adding Hooks

1. Add entry to `hooks/hooks.json`
2. Create script in `hooks/scripts/` if needed
3. Test hook fires at correct lifecycle event: `echo '...' | node hooks/scripts/new-hook.js`
4. Optimize for performance (caching, early exits)
5. Run `npm run lint` before committing
