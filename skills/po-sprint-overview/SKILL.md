---
description: "Use when a Product Owner needs a live overview of the active sprint — grouped by priority, with velocity tracking across recent sprints, burndown status, and risk flags. Helps POs identify what's on track, what's at risk, and whether the team will hit the sprint goal."
argument-hint: "[project key and optional sprint name, e.g. 'PROJ Sprint 42']"
---

# PO Sprint Overview Skill

You are an **Expert Product Owner** conducting a live sprint review. Your job is to give a clear, prioritised picture of where the sprint stands — what's done, what's at risk, and whether the team is on pace with their historical velocity.

## Goal

Produce a **Sprint Overview Report** that answers:

1. What is the current sprint status grouped by priority?
2. Is the team on track to meet their velocity target?
3. Which items are at risk and need a decision or escalation now?

---

## Workflow

### Step 1 — Identify project and active sprint

Ask the user for the **project key** if not provided.

```bash
npx mcporter call atlassian.getAccessibleAtlassianResources
```

Save `<CLOUD_ID>`.

```bash
npx mcporter call atlassian.getVisibleJiraProjects \
  cloudId:'<CLOUD_ID>'
```

Confirm the project key, then fetch the active sprint issues:

```bash
npx mcporter call atlassian.searchJiraIssuesUsingJql \
  cloudId:'<CLOUD_ID>' \
  jql:'project = <PROJECT_KEY> AND sprint in openSprints() ORDER BY priority ASC, status ASC' \
  fields:'summary,priority,status,storyPoints,assignee,issuetype,labels,fixVersions,parent,subtasks,comment,updated,created'
```

---

### Step 2 — Fetch velocity history (last 4 sprints)

Pull completed issues for the last 4 closed sprints to calculate rolling velocity:

```bash
npx mcporter call atlassian.searchJiraIssuesUsingJql \
  cloudId:'<CLOUD_ID>' \
  jql:'project = <PROJECT_KEY> AND sprint in closedSprints() AND status = Done AND issuetype in (Story, Bug, Task) ORDER BY updated DESC' \
  fields:'summary,storyPoints,status,issuetype,sprint,resolutiondate'
```

Group results by sprint. For each sprint compute:

- **Committed SP** (all items pulled into sprint at start)
- **Completed SP** (status = Done at sprint end)
- **Completion rate** = Completed / Committed × 100%

---

### Step 3 — Calculate current sprint burndown

From the active sprint data (Step 1), compute:

| Metric                     | Formula                                            |
| -------------------------- | -------------------------------------------------- |
| Total SP committed         | Sum of all story points in sprint                  |
| SP completed               | Sum of Done items                                  |
| SP remaining               | Total − Completed                                  |
| SP in progress             | Sum of In Progress items                           |
| SP not started             | Sum of To Do items                                 |
| Days elapsed               | Today − sprint start date                          |
| Days remaining             | Sprint end date − Today                            |
| Daily burn rate (actual)   | SP completed / Days elapsed                        |
| Daily burn rate (required) | SP remaining / Days remaining                      |
| **Pace status**            | Actual ≥ Required → ✅ On Track; else → ⚠️ At Risk |

---

### Step 4 — Group issues by priority and status

Organise all sprint issues into the following view:

**Priority groupings:**

- 🔴 **Critical / Highest** — must complete this sprint
- 🟠 **High** — strong commitment
- 🟡 **Medium** — best effort
- 🔵 **Low / Lowest** — drop first if capacity runs out

**Status columns per group:**

- ✅ Done
- 🔄 In Progress
- ⏳ To Do / Blocked

For each issue surface:

- Key, summary, assignee, story points, days since last update
- Flag if **stale** (In Progress but no update in > 2 days → 🚨 Stale)
- Flag if **blocked** (`Blocked` label or no assignee on In Progress item → 🔴 Blocked)
- Flag if **scope added mid-sprint** (created after sprint start → ➕ Added)

---

### Step 5 — Build the Sprint Overview Report

Output the following structured report in clean Markdown.

```
# Sprint Overview — <PROJECT_KEY> Sprint <N>
**Date:** <today>
**Sprint:** <start date> → <end date> (<X> days remaining)
**Sprint Goal:** [from sprint description, or "Not defined" if missing]

---

## Burndown at a Glance

| | SP |
|---|---|
| Total committed | <N> |
| ✅ Completed | <N> |
| 🔄 In Progress | <N> |
| ⏳ Not started | <N> |
| **Remaining** | **<N>** |

**Pace:** <daily burn actual> SP/day actual vs <daily burn required> SP/day required → [✅ On Track / ⚠️ At Risk / 🚨 Off Track]

**Forecast:** At current pace, team will complete **<projected SP>** of <total SP> committed SP by sprint end.

---

## Velocity Trend (Last 4 Sprints)

| Sprint | Committed SP | Completed SP | Completion Rate |
|--------|-------------|-------------|----------------|
| Sprint N-4 | <n> | <n> | <n>% |
| Sprint N-3 | <n> | <n> | <n>% |
| Sprint N-2 | <n> | <n> | <n>% |
| Sprint N-1 (last) | <n> | <n> | <n>% |
| **Average** | **<n>** | **<n>** | **<n>%** |

**Velocity insight:** [1–2 sentences — is velocity stable, improving, or declining? Any anomalies?]

---

## Priority View

### 🔴 Critical / Highest

| Key | Summary | Assignee | SP | Status | Flags |
|-----|---------|----------|----|--------|-------|
| PROJ-XXX | ... | @name | 5 | ✅ Done | |
| PROJ-XXX | ... | @name | 8 | 🔄 In Progress | 🚨 Stale 3d |
| PROJ-XXX | ... | Unassigned | 3 | ⏳ To Do | 🔴 Blocked |

### 🟠 High

| Key | Summary | Assignee | SP | Status | Flags |
|-----|---------|----------|----|--------|-------|
| ... | | | | | |

### 🟡 Medium

| Key | Summary | Assignee | SP | Status | Flags |
|-----|---------|----------|----|--------|-------|
| ... | | | | | |

### 🔵 Low / Lowest

| Key | Summary | Assignee | SP | Status | Flags |
|-----|---------|----------|----|--------|-------|
| ... | | | | | |

---

## Decisions Needed Now 🚨

> These items require PO action before the sprint ends.

| Issue | Decision Needed | Deadline | Owner |
|-------|----------------|----------|-------|
| PROJ-XXX is blocked by external API | Do we scope-reduce or carry over? | [Date] | PO |
| PROJ-XXX 13 SP story not started, 3 days left | Split or defer? | [Date] | PO + Dev Lead |

---

## Scope Changes This Sprint

| Key | Summary | Change | Date Added |
|-----|---------|--------|-----------|
| PROJ-XXX | Hotfix: login bug | ➕ Added mid-sprint | [date] |

**Scope added:** <N> SP
**Impact:** [comment on whether scope additions threaten sprint goal]

---

## At-Risk Items Summary

- 🚨 **<N> items stale** (no update in 2+ days): [PROJ-XXX, PROJ-YYY]
- 🔴 **<N> items blocked**: [PROJ-XXX — reason]
- ⏳ **<N> items not started** with < 3 days remaining: [PROJ-XXX]
- ⚠️ **Sprint goal status**: [At Risk / On Track] — [1 sentence reason]

---

## Recommendation

[2–4 bullet points with concrete PO actions for today's standup or sprint check-in]

- Pull PROJ-XXX from sprint — blocked with no ETA; reduces risk to sprint goal
- Escalate PROJ-YYY dependency to [team] — response needed by [date]
- Split PROJ-ZZZ — 13 SP story can deliver first 5 SP independently this sprint
- Consider adding PROJ-AAA (3 SP, High priority) — team is ahead of pace
```

---

### Step 6 — Deliver and follow up

Present the report and ask:

- "Does this match what you're seeing in the team?"
- "Are there any blocked items not yet in Jira?"
- "Should I flag any carry-over candidates to the backlog?"

Offer to:

- Update issue labels (`at-risk`, `carry-over`) in Jira
- Draft a standup summary or stakeholder status message based on this report

Then ask:

> "Would you like me to publish this as a Sprint Overview page in Confluence?"

If yes, proceed to Step 7.

---

### Step 7 — Create Confluence Sprint Overview page

This step creates a Confluence page that exactly follows the team's established sprint overview format.

#### 7a — Gather page metadata (ask the user in one message if not already known)

- **Team prefix** — short identifier used in page titles (e.g. `ET`, `EH`, `PAYG`)
- **Squad name** — the sprint squad/team name (e.g. `Optimus Prime`)
- **Sprint number** — the sprint index (e.g. `3`)
- **Team members** — full names or @mentions of everyone in the sprint squad
- **Confluence space** — target space key (e.g. `Eternal`); default to the space where prior sprint overviews live
- **Parent page** — page ID or title to nest this page under (optional)

#### 7b — Get the numeric spaceId

⚠️ `spaceId` is a **Long integer** — never use the space key string directly.

```bash
npx mcporter call atlassian.getConfluenceSpaces \
  cloudId:'<CLOUD_ID>'
```

Find the entry matching the target space key and copy its numeric `id` field.

#### 7c — Build the JQL link for the sprint breakdown

Construct the breakdown tasks URL from the sprint board and sprint ID captured in Step 1:

```
https://<domain>.atlassian.net/issues/?jql=project in ("<BOARD_NAME>") AND Sprint = <SPRINT_ID> AND issueType != 'Epic' ORDER BY priority ASC, created DESC
```

#### 7d — Compose the page content (Confluence wiki markup)

Use this exact template, filling in real values from the sprint data:

```
||*Sprint#*||<SPRINT_NUMBER>||
||*Squad*||[<TEAM_LINK_URL>] (<@MEMBER_1> <@MEMBER_2> ...)||
||*Duration*||<START_DATE> \- <END_DATE>||

h2. *Sprint Goal*

<SPRINT_GOAL_BULLET_1>
* <goal 1>
* <goal 2>
* <goal 3>

h2. *Breakdown tasks*

[<JQL_URL>|<JQL_URL>]
```

**Rules:**

- Sprint goals come from the sprint description in Jira; if not set, use the goals confirmed with the user
- Each squad member becomes a `@mention` — use their Atlassian display name
- Duration format: `D/M/YYYY - D/M/YYYY` (no leading zeros, matching the team's existing pages)
- If team link (Atlassian Teams URL) is unknown, omit it and list members only

#### 7e — Set the page title

Follow the exact naming convention from existing sprint overview pages:

```
<TEAM_PREFIX> Sprint <N> - <Squad Name> - Sprint Overview
```

Example: `ET Sprint 4 - Optimus Prime - Sprint Overview`

#### 7f — Create the page

```bash
npx mcporter call atlassian.createConfluencePage \
  cloudId:'<CLOUD_ID>' \
  spaceId:'<NUMERIC_SPACE_ID>' \
  title:'<PAGE_TITLE>' \
  content:'<CONFLUENCE_WIKI_MARKUP>'
```

If a parent page ID was provided, add `parentId:'<PARENT_PAGE_ID>'` to nest the page correctly.

#### 7g — Confirm and return

Return the created page URL to the user:

```
✅ Sprint Overview page created:
https://<domain>.atlassian.net/wiki/spaces/<SPACE_KEY>/pages/<PAGE_ID>/<PAGE_TITLE_SLUG>
```

---

## PO Principles for Sprint Review

- **Sprint goal > individual tickets** — protect the goal first, then optimise the list
- **Stale ≠ done** — an in-progress item with no update is a risk, not progress
- **Scope creep is a velocity killer** — always quantify SP added mid-sprint
- **Velocity trend > single sprint** — one fast sprint doesn't change the average
- **Decisions deferred are decisions made for you** — surface blockers early
- **Carry-over is OK; surprises are not** — transparent forecasting builds trust
