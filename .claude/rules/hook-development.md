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
