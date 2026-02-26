# Development Principles

## 1. Separation of Concerns

**Skills (Commands)**: User workflows (/kkclaude:jira-ticket, etc.). **Skills (Knowledge)**: Auto-loaded patterns. **Agents**: Autonomous execution. **Hooks**: Automated checks.

## 2. Progressive Disclosure

**Commands**: High-level intent. **Agents**: Detailed execution. **Knowledge**: Domain patterns.

## 3. Repository-Agnostic Design

Multi-stack support (Ruby, TypeScript, Python, Go, .NET). Auto-detect repo patterns (Gemfile, package.json). Don't hardcode specifics. Target repos customize via `.claude/` directory.
