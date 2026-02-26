---
paths: skills/**
---

# Skill Development

## Structure

Skills are markdown files with YAML frontmatter in `skills/<skill-name>/SKILL.md`:

```markdown
---
name: my-skill
description: "When this skill activates and what it does"
argument-hint: "[optional argument hint]"
disable-model-invocation: true # User-only invocation (for commands)
---

# Skill Title

## When to Use

[Activation conditions]

## Patterns

[Best practices, code examples]

## Anti-Patterns

[What to avoid]

## Examples

[Concrete examples]
```

## Skill Types

**Command Skills** (user-invocable via `/skill-name`):

- Set `disable-model-invocation: true` for actions where we want to ensure user intent (e.g., destructive actions, external API calls)

**Knowledge Skills** (auto-loaded by Claude when relevant):

- Claude uses `description` to decide when to load
- Examples: domain patterns, best practices guides

## Frontmatter Fields

| Field                      | Required    | Description                                                         |
| -------------------------- | ----------- | ------------------------------------------------------------------- |
| `name`                     | No          | Display name (defaults to directory name)                           |
| `description`              | Recommended | What skill does, when to use it (Claude uses this for auto-loading) |
| `argument-hint`            | No          | Hint for arguments, e.g., `[jira-url]`                              |
| `disable-model-invocation` | No          | `true` = user-only command, prevents auto-invocation                |
| `user-invocable`           | No          | `false` = Claude-only skill, hidden from `/` menu                   |
| `allowed-tools`            | No          | Restrict tools when skill is active                                 |
| `context`                  | No          | `fork` to run in subagent                                           |
| `agent`                    | No          | Which subagent type for `context: fork`                             |

## Best Practices

1. **Clear description**: Claude uses this to decide when to auto-load knowledge skills
2. **Multi-stack support**: Provide examples for Ruby/Rails, TypeScript/Node.js, Python/FastAPI, Go, .NET/C#
3. **Pattern > Prescription**: Show patterns, not rigid rules
4. **Working code examples**: Use real, tested code (not pseudocode)
5. **Anti-patterns**: Show what NOT to do (equally important)

## Adding Skills

1. Create `skills/new-skill/SKILL.md`
2. Define frontmatter with appropriate fields
3. Write clear activation conditions and patterns
4. Provide multi-stack examples where relevant
5. Test in target repo
6. Document in README.md
