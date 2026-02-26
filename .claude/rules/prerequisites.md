# Prerequisites: Working on Plugin Components

**CRITICAL**: When modifying plugin infrastructure (hooks, agents, skills, MCP integrations, plugin manifest), you MUST:

## 1. Read Official Documentation First

Always consult Claude Code documentation before making changes:

- [Claude Code Documentation](https://code.claude.com/docs/)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Agent Development](https://code.claude.com/docs/en/subagents)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)

## 2. Use WebSearch When Documentation is Unclear

If you need clarification on Claude Code behavior:

- Search for "Claude Code [feature] documentation 2026"
- Check GitHub issues for known limitations
- Verify against latest API changes

## 3. Never Guess Claude Code Behavior

The plugin system has specific requirements:

- Hook response formats must match schema exactly
- Agent invocation patterns are version-specific
- Skill frontmatter has strict validation
- MCP server integration follows specific protocols
