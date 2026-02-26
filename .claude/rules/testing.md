---
paths:
  - "**/*test*"
  - "**/*spec*"
  - .github/workflows/**
---

# Testing the Plugin

## Local Development Setup

1. **Clone plugin repository:**

   ```bash
   git clone git@github.com:kingkong0905/my-claude-code.git
   cd my-claude-code
   ```

2. **Install in test repo:**

   ```bash
   cd /path/to/test-repo
   claude plugin install /path/to/my-claude-code
   ```

3. **Test commands:**

   ```bash
   claude
   > /kkclaude:jira-ticket "test feature"
   ```

4. **Check logs:**

   ```bash
   tail -f ~/.claude/logs/latest.log
   ```

## Hook Testing

```bash
# Lint hook scripts
npm run lint

# Test a specific hook manually
echo '{"tool_input":{"command":"echo hello"}}' | node hooks/scripts/bash-safety-check.js
```

## Verification Checklist

Before committing changes:

- [ ] **Command triggers work** in real session
- [ ] **Agents activate** with correct tools and models
- [ ] **Skill examples work** as expected
- [ ] **Hooks execute** at correct lifecycle events
- [ ] **MCP integration works** (Atlassian, Serena)
- [ ] **GitHub CLI integration works** (`gh` commands)
- [ ] **Documentation is up-to-date** (README.md, CLAUDE.md)

## Troubleshooting

### Plugin Not Loading

```bash
# Check plugin installation
claude plugin list

# Reinstall
claude plugin install /path/to/my-claude-code

# Check logs
tail -f ~/.claude/logs/latest.log
```

### Command Not Triggering

1. Check frontmatter `name` and `description` fields
2. Test with exact command name: `/kkclaude:jira-ticket`
3. Check YAML frontmatter validity

### Hook Not Firing

1. Verify event type (PreToolUse, PostToolUse, etc.)
2. Check matcher pattern
3. Verify script has execute permissions (if shell script)
4. Check script exit code (0 = success)
