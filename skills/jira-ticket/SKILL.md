---
description: "Use when drafting a Jira ticket from a feature idea, bug report, or task description. Produces structured Jira wiki markup with Overview, Context, and Acceptance Criteria."
argument-hint: "[brief description of the feature, bug, or task]"
model: sonnet
---

# Jira Ticket Skill

Draft a complete, ready-to-file Jira ticket in Jira wiki markup.

## Invocation

Use this skill when you need to:

- Turn a rough idea or conversation into a structured Jira ticket
- Write a bug report with reproducible steps
- Draft a feature request with clear acceptance criteria
- Produce output ready to paste directly into Jira (wiki markup, not Markdown)

## Workflow

### 1. Determine ticket type

Identify the type from the input or ask if unclear:

- `[Feature]` — new capability or enhancement
- `[Bug]` — something broken or behaving incorrectly
- `[Chore]` — maintenance, refactor, dependency update
- `[Spike]` — research or investigation task

### 2. Gather missing context (batch all questions in one message)

Ask only for what is not already clear:

- What is the desired outcome?
- Why is this needed — what problem or value does it address?
- Who is affected (users, systems, teams)?
- What is explicitly out of scope?
- Any blocking dependencies or related tickets?

### 3. Select and fill the appropriate template

Use the templates in `templates/` as the basis for the output.
All output must be in **Jira wiki markup** — see `references/jira-syntax-quick-reference.md`.
Never output Markdown in the ticket body.

- Feature/Story/Chore → `templates/feature-template.md`
- Bug → `templates/bug-template.md`
- Spike → use feature template, replace AC section with `h2. Definition of Done`

### 4. Review with user

Present the draft and ask:

- "Does this capture what you need?"
- "Anything missing or incorrect?"

Revise until the user confirms. Then output the final clean ticket.

> Do NOT create the Jira issue automatically unless the user explicitly asks.

## Writing Rules

- _Overview_ = what. _Context_ = why. _Acceptance Criteria_ = done when.
- AC items describe observable outcomes, not implementation tasks.
- Replace vague language: "works correctly" → specific behaviour; "should" → "must".
- Keep it concise — a ticket is not a specification document.
