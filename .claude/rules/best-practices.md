# Best Practices

## ✅ DO

- **Create feature branch BEFORE making changes**: Never work directly on main/master
- **Follow branch naming conventions**: feature/, fix/, docs/, refactor/
- **Follow [Claude Code documentation](https://code.claude.com/docs/) patterns**: Official documentation is authoritative
- **Support multiple stacks**: Ruby/Rails, TypeScript/Node.js, Python/FastAPI, Go, .NET/C#
- **Provide clear examples**: Working code, not pseudocode
- **Test in real target repositories**: Don't rely on synthetic tests
- **Use progressive disclosure**: High-level → detailed (commands → agents → knowledge)
- **Cache expensive operations**: See hook scripts with SHA256 caching
- **Provide MCP fallbacks**: Handle OAuth failures gracefully
- **Document environment requirements**: Make setup clear
- **Commit to feature branch, create PR for review**: Never commit directly to target branch
- **Use gh CLI for GitHub operations**: Never use GitHub MCP; always use gh CLI for PRs, issues, code search
- **Use Atlassian MCP for Confluence/Jira**: Always use MCP tools (mcp**atlassian**\*) for Confluence/Jira content

## ❌ DON'T

- **Commit directly to main/master or target branches**: Always create feature branch first
- **Run git add/commit on main/master**: Work on feature branches only
- **Skip testing in real repositories**: Always verify in actual codebases
- **Use complex tool chains unnecessarily**: Prefer specialized tools over bash
- **Block without clear error messages**: Always explain why and how to fix
- **Assume target repo uses specific stack**: Auto-detect or provide fallbacks
- **Skip documentation updates**: Keep README.md and CLAUDE.md in sync
- **Use GitHub MCP**: Always use gh CLI instead for reliability
- **Scrape Confluence/Jira URLs with `WebFetch`**: Use MCP tools for authenticated access

## Documentation Standards

### Code Examples

Provide multi-stack examples using this pattern:

````markdown
### Ruby/Rails Example

```ruby
# Code here
```

### TypeScript/Node.js Example

```typescript
// Code here
```

### .NET/C# Example

```csharp
// Code here
```
````

### Linking

**Within plugin:**

```markdown
See [skill-development.md](../../skills/jira-ticket/SKILL.md)
```

**External resources:**

```markdown
See [Claude Code Docs](https://code.claude.com/docs/)
```

## Contributing

### Pull Request Process

1. **Branch naming**: `feature/command-name` or `fix/issue-description`
2. **Testing**: Verify in real target repo
3. **Documentation**: Update CLAUDE.md and README.md
4. **Changelog**: Note changes in PR description

## Review Checklist

### Skills (Command)

- [ ] Clear description in frontmatter
- [ ] Progressive disclosure (high-level → detailed)
- [ ] Examples for all supported stacks

### Agents

- [ ] Clear role definition
- [ ] Appropriate model selection (haiku/sonnet/opus)
- [ ] Minimal tool set (only what's needed)
- [ ] Output format specified

### Hooks

- [ ] Performance optimized (caching, early exits)
- [ ] Clear error messages
- [ ] Appropriate blocking vs. warning
- [ ] Stack detection if needed
- [ ] Exit code correct (0 = success)

### Documentation

- [ ] Up-to-date with changes
- [ ] Links working
- [ ] Examples tested in real repos
