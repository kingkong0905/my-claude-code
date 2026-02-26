---
paths: agents/**
---

# Agent Development

## Structure

Agents are markdown files with YAML frontmatter:

```markdown
---
description: "What this agent does"
tools:
  - Glob
  - Grep
  - Read
  - Edit
  - Write
  - Bash
color: "blue" # UI color
model: "sonnet" # or "opus", "haiku"
---

# Agent Name

You are an expert [domain] agent...

## Your Expertise

[What you're good at]

## Your Responsibilities

[What you do]

## Output Format

[Expected output structure]
```

## Tool Selection

Choose tools based on agent needs:

| Tool          | Use For                  | Don't Use For                           |
| ------------- | ------------------------ | --------------------------------------- |
| **Read**      | Reading specific files   | Searching (use Grep)                    |
| **Grep**      | Content search           | File listing (use Glob)                 |
| **Glob**      | File pattern matching    | Reading content                         |
| **Edit**      | Modifying existing files | Creating new files (use Write)          |
| **Write**     | Creating new files       | Modifying existing (use Edit)           |
| **Bash**      | Running commands         | File operations (use specialized tools) |
| **Task**      | Launching sub-agents     | Direct file operations                  |
| **MCP Tools** | Jira, Confluence, Serena | GitHub (use `gh` CLI)                   |

## Model Selection

| Model      | When to Use                           | Cost   | Speed  | Context Window |
| ---------- | ------------------------------------- | ------ | ------ | -------------- |
| **haiku**  | Simple tasks, fast iteration          | Low    | Fast   | 200K tokens    |
| **sonnet** | Most tasks (default)                  | Medium | Medium | 200K tokens    |
| **opus**   | Complex reasoning, critical decisions | High   | Slow   | 200K tokens    |

## Best Practices

1. **Clear role definition**: "You are an expert X who does Y"
2. **Tool restriction**: Only include tools agent actually needs
3. **Output format**: Specify expected structure
4. **Examples**: Show ideal outputs
5. **Guardrails**: Specify what agent should NOT do

## Adding New Agent

1. Create `agents/new-agent.md`
2. Define frontmatter (tools, model, color)
3. Write system prompt with clear role
4. Specify output format
5. Test with a skill that uses it
