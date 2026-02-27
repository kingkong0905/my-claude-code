# Section Guidelines

Detailed writing instructions for each of the 9 proposal sections.
Reference this from Step 4 in [SKILL.md](SKILL.md).

---

## Section 1 — Title & Summary

- Write last, place first
- Action-oriented title (e.g. "Modernise Job Matching Engine", "AI Billing Slice 2 – Credit Limits & Alerts")
- 1–3 bullet summary: Problem (1 line) → Solution (1–2 lines) → Expected impact with numbers
- Avoid jargon in the first 3 bullets — add technical detail in later sections

## Section 2 — Problem & Context

- _Current state_: short description + 2–5 key constraint bullets
- _Pain points_: one clear pain per bullet with a metric where possible
  - Bad: "System is slow."
  - Better: "P95 response time is 2.4s vs target 800ms; causes drop-off in job views and recruiter complaints."
- _Why now_: deadlines, dependencies, opportunity cost, strategic alignment

## Section 3 — Objectives & Non-Goals

- 3–5 measurable objectives (e.g. "Reduce P95 latency from 2s → <800ms for /search endpoint")
- 3–5 explicit non-goals (e.g. "Does not redesign UI for job posting flow")

## Section 4 — Proposed Solution (Overview)

- _Approach_: 1–2 short paragraphs or 3–6 bullets — accessible to non-technical readers
- _Key components_: 3–7 bullets listing main components/changes
- _Rationale_: 3–5 bullets on why this direction vs obvious alternatives
- Keep deep implementation detail for Section 5 (Architecture)

## Section 5 — Architecture & Design Details

Section 5 is the most technically demanding section. Every subsection must contain real, implementation-level detail drawn from codebase research — no placeholders, no vague descriptions.

- _5.1 High-level architecture_: short text + Mermaid `flowchart` showing top-level components and their relationships. Use exact service/module names from the codebase.
- _5.2 Core flows_: ALWAYS draw a Mermaid diagram for each primary flow — use `flowchart` for process/data flows, `sequenceDiagram` for request/response interactions. Include actual method/endpoint names.
- _5.3 Data model_: ALWAYS draw a Mermaid `erDiagram` for any entity relationships, new tables, fields, or schema changes. Include column names, types, PKs, FKs.
- _5.4 Failure modes & recovery_: downtime, partial failure, data corruption handling. Specify detection mechanism (alert/log/monitor) and recovery procedure.
- _5.5 Tech decisions_: notable library, infra, or pattern choices — 2–3 bullet justification each. Cite alternatives considered.

### 5.6 API Contracts & Interface Changes

Required for any proposal that adds, changes, or removes an API endpoint or inter-service interface:

- List every endpoint added/changed/removed: `METHOD /path` → request schema → response schema
- Include HTTP status codes, auth requirements, rate limits
- For gRPC: show proto message definitions
- For events/messages: show topic name, schema, producer, consumer
- Flag any breaking changes and the migration path for existing consumers

Example (REST):

```
POST /api/v2/jobs/search
Auth: Bearer token (employer scope)
Request:  { query: string, filters: { location?: string, salary_min?: number }, page: number }
Response: 200 { results: Job[], total: number, cursor: string }
          400 { error: "INVALID_FILTER", field: string }
          429 { retry_after: number }
```

### 5.7 Database & Infrastructure Changes

Required for any proposal that modifies data storage or infrastructure:

- Schema changes: show SQL DDL (or ORM migration equivalent) for new/modified tables, columns, indexes
- Migration strategy: forward-only or reversible; zero-downtime approach (backfill, dual-write, feature flag)
- New infrastructure: service name, hosting (e.g. AWS region, ECS task), estimated cost/month, scaling policy
- Config/environment variables added or changed — include key name, type, where it's set
- Dependency additions: package/service name + version + justification

Example (migration):

```sql
-- Migration: add search_vector column with GIN index for full-text search
ALTER TABLE jobs ADD COLUMN search_vector tsvector;
CREATE INDEX CONCURRENTLY idx_jobs_search_vector ON jobs USING GIN(search_vector);
-- Backfill: run as background job, ~4h for 10M rows at 500 rows/s
UPDATE jobs SET search_vector = to_tsvector('english', title || ' ' || description)
WHERE search_vector IS NULL;
```

### 5.8 Observability & Monitoring

Required for every proposal — new systems must be observable from day one:

- _Metrics_: list new metrics to emit (name, type: counter/gauge/histogram, label set)
- _Logs_: key log events and their structured fields (e.g. `job_search_executed { query_id, duration_ms, result_count }`)
- _Traces_: new spans added to distributed traces; parent–child relationships
- _Alerts_: at least one alert per risk identified in Section 7 — threshold, severity, on-call runbook link
- _Dashboards_: describe what the on-call engineer would look at to confirm the system is healthy

### 5.9 Testing Strategy

Required for every proposal:

- _Unit tests_: which new classes/functions need unit tests; notable edge cases
- _Integration tests_: which service boundaries need integration coverage; test environment requirements
- _E2E / contract tests_: critical user flows to cover; consumer-driven contract tests for API changes
- _Load / performance tests_: baseline and target metrics from Section 6; tool (k6, Gatling, etc.); acceptance threshold
- _Rollback test_: how the team will verify the rollback procedure works before going to production

### 5.10 Change Impact Assessment

Required for every proposal. Map every factor the proposal touches and rate its impact severity.

**Impact levels:**

| Level    | Definition                                                                                                   |
| -------- | ------------------------------------------------------------------------------------------------------------ |
| Critical | Breaking change, data loss risk, or system outage possible — requires dedicated mitigation plan and sign-off |
| High     | Significant behaviour change for users or downstream systems — requires thorough testing and staged rollout  |
| Medium   | Noticeable change but contained in scope — standard testing and monitoring sufficient                        |
| Low      | Minimal or no observable change — cosmetic, additive only, or fully backward-compatible                      |

**Factor categories to evaluate** — assess every row; write "Not affected" only when you have confirmed it is unchanged:

| Factor                      | Affected component(s)                       | Nature of change                                   | Impact level                   | Explanation & mitigation                                  |
| --------------------------- | ------------------------------------------- | -------------------------------------------------- | ------------------------------ | --------------------------------------------------------- |
| User flows                  | [flow names]                                | [added / changed / removed]                        | Critical / High / Medium / Low | [what breaks or changes for the user; rollback plan]      |
| Data model / ERD            | [entity names]                              | [new table / column / relationship / removed]      | ...                            | [schema delta; data migration risk]                       |
| Database                    | [table / index / query names]               | [DDL change / query pattern / volume]              | ...                            | [performance risk; lock risk; backfill estimate]          |
| API / service interface     | [endpoint or service name]                  | [added / changed / deprecated / removed]           | ...                            | [consumer impact; versioning strategy]                    |
| Background jobs / queues    | [job or queue name]                         | [new / changed payload / removed]                  | ...                            | [in-flight message handling; idempotency]                 |
| Infrastructure / deployment | [service / config / env var]                | [new dependency / scaling change / cost]           | ...                            | [rollout sequence; infra provisioning lead time]          |
| Security & auth             | [auth scope / permission / data boundary]   | [new access / changed scope / data exposure]       | ...                            | [security review required? blast radius if misconfigured] |
| Performance & scalability   | [endpoint / query / job]                    | [added load / changed complexity / new bottleneck] | ...                            | [p95 latency delta; throughput change; load test result]  |
| External integrations       | [third-party service / webhook / event bus] | [new contract / changed payload / removed]         | ...                            | [partner notification required? SLA impact]               |
| Operations / on-call        | [runbook / alert / dashboard]               | [new alert / changed threshold / new runbook]      | ...                            | [on-call burden delta; training needed?]                  |

> Ground every rating in evidence from the codebase research (Serena blast radius, Jira tickets, recent commits). A "Low" rating with no explanation is rejected at review. If a factor is genuinely not affected, state why in the explanation column.

Embed Mermaid diagrams using the Confluence Mermaid macro:

```
{mermaid}
<mermaid content here>
{mermaid}
```

For code samples, use Confluence code blocks with the language specified — complete, runnable examples only, no placeholders:

```javascript
// complete, executable example — no placeholders
const result = await client.search({ query, limit: 50 });
console.log(result.hits); // Output: [{ id: '123', score: 0.98 }, ...]
```

## Section 6 — Impact

- _Business impact_: revenue, margin, conversion, retention, customer experience, operational efficiency
- _Technical impact_: reliability (error rate, MTTR), scalability, maintainability, tech debt reduction
- _Metrics table_: Metric | Current | Target — label estimates and state how you'll validate

## Section 7 — Risks, Trade-offs, Alternatives

- _Risks_: 3–10 items — Risk | Likelihood (L/M/H) | Impact (L/M/H) | Mitigation
- _Trade-offs_: 3–5 "We trade X for Y" bullets (e.g. "Higher infra cost for lower latency")
- _Alternatives_: each with 1–2 line description, pros, cons, why not selected
- Do not hide real risks — this section builds trust with reviewers

## Section 8 — Plan, Timeline, Resources

Phases:

- Phase 0 – Discovery / Spike
- Phase 1 – Core infra + happy path
- Phase 2 – Edge cases + hardening
- Phase 3 – Rollout & monitoring

Each phase: outcomes, key tasks, success criteria.

Timeline: weeks/sprints, not exact dates if uncertain; highlight critical dependencies.

Resources:

- _People_: roles + rough allocation (e.g. "2× BE, 1× FE, 0.5× DevOps for 2 sprints")
- _Tools/infra_: new services, licenses, storage, additional spend
- _Cross-team_: which teams involved and when

## Section 9 — Decision Required

- "We are asking for approval to:" + 2–5 clear action/commitment bullets
- If options: Option A (minimal/low-risk), Option B (full scope/higher impact), Option C (do nothing/baseline)

---

## Mermaid Diagram Guide

Always use Mermaid for flows and entity relationships. Embed with the Confluence `{mermaid}` macro.

### When to use each diagram type

| Section                       | Scenario                                    | Diagram type                     |
| ----------------------------- | ------------------------------------------- | -------------------------------- |
| 5.1 High-level architecture   | Component topology, service boundaries      | `flowchart TD` or `flowchart LR` |
| 5.2 Core flows — process      | Data transformation, pipeline, job steps    | `flowchart TD`                   |
| 5.2 Core flows — interactions | API calls, service-to-service, user actions | `sequenceDiagram`                |
| 5.3 Data model                | Tables, relationships, cardinality          | `erDiagram`                      |

### Flowchart (architecture overview or process flow)

```mermaid
%% Search Service Architecture
flowchart TD
Client([Client]) --> GW[API Gateway]
GW --> SVC[Search Service]
SVC --> IDX[(Search Index)]
SVC --> CACHE[(Redis Cache)]
IDX --> DB[(PostgreSQL)]
```

**Node shapes** (per [Mermaid flowchart docs](https://mermaid.js.org/syntax/flowchart.html)):

| Shape      | Syntax      | Use for                      |
| ---------- | ----------- | ---------------------------- |
| Rectangle  | `[Label]`   | Service / component          |
| Stadium    | `([Label])` | External actor / entry point |
| Cylinder   | `[(Label)]` | Database / data store        |
| Rhombus    | `{Label}`   | Decision / branch            |
| Circle     | `((Label))` | Event / endpoint             |
| Hexagon    | `{{Label}}` | Process / transform          |
| Subroutine | `[[Label]]` | Subprocess / reusable block  |

**Link types:**

| Arrow            | Syntax            | Meaning                  |
| ---------------- | ----------------- | ------------------------ |
| Solid with head  | `A --> B`         | Standard directed flow   |
| Open / no arrow  | `A --- B`         | Association              |
| Dotted with head | `A -.-> B`        | Optional / async flow    |
| Thick with head  | `A ==> B`         | Critical / emphasis path |
| Labeled edge     | `A -- text --> B` | Annotated edge           |

**Direction:** `TD` / `TB` top-down (same; default), `LR` left-right (wide pipelines), `BT` bottom-up, `RL` right-left.

**Comments:** Use `%%` prefix — e.g. `%% This describes the diagram`.

### Sequence diagram (request/response or service interactions)

```mermaid
sequenceDiagram
autonumber
actor User
participant API as API Gateway
participant SVC as Job Service
participant DB as PostgreSQL

    User->>API: POST /jobs
    API->>SVC: createJob(payload)
    SVC->>DB: INSERT INTO jobs
    DB-->>SVC: job_id
    SVC-->>API: 201 Created { id }
    API-->>User: 201 Created { id }
```

**Arrow types** (per [Mermaid sequence diagram docs](https://mermaid.js.org/syntax/sequenceDiagram.html)):

| Syntax | Line   | Arrow | Use for                          |
| ------ | ------ | ----- | -------------------------------- |
| `->>`  | Solid  | Head  | Synchronous call / request       |
| `-->>` | Dotted | Head  | Response / return value          |
| `->`   | Solid  | None  | Signal / one-way message         |
| `-->`  | Dotted | None  | Acknowledgement / weak response  |
| `-)`   | Solid  | Open  | Fire-and-forget / async dispatch |
| `--x`  | Dotted | Cross | Error / rejection                |

Add `autonumber` after `sequenceDiagram` to auto-number all messages.
Use `+` / `-` suffix on arrows to activate / deactivate lifebars: `A->>+B: call` / `B-->>-A: return`.

### ERD (entity relationship diagram)

```mermaid
erDiagram
JOB {
uuid id PK
uuid employer_id FK
string title
string status
timestamp created_at
}
EMPLOYER {
uuid id PK
string name
}
JOB_CANDIDATE {
uuid job_id FK
uuid candidate_id FK
string stage
}
CANDIDATE {
uuid id PK
string name
}

    EMPLOYER ||--o{ JOB : "posts"
    JOB ||--o{ JOB_CANDIDATE : "has"
    CANDIDATE ||--o{ JOB_CANDIDATE : "applies to"
```

**Cardinality notation** (per [Mermaid ERD docs](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)):

| Left marker | Right marker | Meaning      |
| ----------- | ------------ | ------------ |
| `\|o`       | `o\|`        | Zero or one  |
| `\|\|`      | `\|\|`       | Exactly one  |
| `}o`        | `o{`         | Zero or more |
| `}\|`       | `\|{`        | One or more  |

**Relationship line:** `--` identifying (solid), `..` non-identifying (dashed).

Examples:

- `EMPLOYER ||--o{ JOB : "posts"` — one employer to zero-or-more jobs (identifying)
- `JOB }|..o{ TAG : "tagged"` — one-or-more jobs to zero-or-more tags (non-identifying)

### Diagram rules

- Every diagram MUST start with a `%%` title comment (e.g. `%% Job Application Flow`) or be preceded by a named heading
- Keep diagrams focused — one concept per diagram; split if it becomes too wide
- Use meaningful node labels, not abbreviations (e.g. `Job Service` not `JS`)
- Show only what changes or is relevant to the proposal — omit unaffected systems
- Use `%%` for any inline annotation or explanation within a diagram
