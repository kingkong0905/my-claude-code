# Proposal Template (Confluence Wiki Markup)

Copy this template as the starting structure for every proposal.
Fill every section — do not leave placeholder text in the final output.
Used in Step 4 of [SKILL.md](SKILL.md). See [sections.md](sections.md) for writing guidelines per section.

---

{noformat}
h1. <Project / Proposal Title>

{toc:maxLevel=3|minLevel=2|type=list|style=disc|printable=true}

h2. 1. Summary

- _Problem:_
- _Proposed solution:_
- _Expected impact:_

h2. 2. Problem & Context

h3. Current State
[Short description of the system/process today]

- Constraint 1
- Constraint 2

h3. Pain Points

- [Pain with metric]
- [Pain with metric]

h3. Why Now

- [Deadline, dependency, or strategic driver]

h2. 3. Objectives & Non-Goals

h3. Objectives

- [Measurable objective 1]
- [Measurable objective 2]

h3. Non-Goals

- [Explicit exclusion 1]
- [Explicit exclusion 2]

h2. 4. Proposed Solution (Overview)

h3. Approach
[1–2 short paragraphs accessible to non-technical readers]

h3. Key Components

- [Component 1]
- [Component 2]

h3. Rationale

- [Why this direction]
- [Why not the obvious alternative]

h2. 5. Architecture & Design Details

h3. 5.1 High-Level Architecture

[1–2 sentence description of the architecture]

{mermaid}
flowchart TD
A([Client]) --> B[API Gateway]
B --> C[Service]
C --> D[(Database)]
{mermaid}

h3. 5.2 Core Flows

[Brief description of each flow]

{mermaid}
sequenceDiagram
autonumber
actor User
participant API
participant Service
participant DB as Database

    User->>API: [request]
    API->>Service: [call]
    Service->>DB: [query]
    DB-->>Service: [result]
    Service-->>API: [response]
    API-->>User: [response]

{mermaid}

h3. 5.3 Data Model

{mermaid}
erDiagram
ENTITY_A {
uuid id PK
string name
}
ENTITY_B {
uuid id PK
uuid entity_a_id FK
}

    ENTITY_A ||--o{ ENTITY_B : "has"

{mermaid}

h3. 5.4 Failure Modes & Recovery

||Failure scenario||Detection||Recovery||
|[scenario]|[alert / log / monitor]|[procedure]|

h3. 5.5 Key Tech Decisions

- _Decision:_ [choice made]
  ** _Why:_ [justification]
  ** _Alternatives ruled out:_ [option A, option B]

h3. 5.6 API Contracts & Interface Changes

_New / changed endpoints:_

{code:none}
[METHOD] /path/to/endpoint
Auth: [auth scheme + required scope]
Request: { [field]: [type], ... }
Response: [status] { [field]: [type], ... }
[error status] { error: "[CODE]", ... }
{code}

_Breaking changes:_ [list any; migration path for existing consumers]

h3. 5.7 Database & Infrastructure Changes

_Schema changes:_

{code:sql}
-- [description of change]
[SQL DDL or ORM migration snippet]
{code}

_Migration strategy:_ [zero-downtime approach; backfill plan; estimated duration]

_New infrastructure:_

||Component||Hosting||Estimated cost/month||Scaling policy||
|[service]|[platform / region]|[cost]|[policy]|

_New config / environment variables:_

||Key||Type||Default||Where set||
|[KEY_NAME]|[type]|[default]|[location]|

h3. 5.8 Observability & Monitoring

_Metrics:_

||Metric name||Type||Labels||
|[metric_name]|counter / gauge / histogram|[label_key=value, ...]|

_Key log events:_

- `[event_name]` — fields: [field1, field2, ...]

_Alerts:_

||Alert||Threshold||Severity||Runbook||
|[alert name]|[condition]|P1 / P2 / P3|[link or TBD]|

h3. 5.9 Testing Strategy

||Test type||Scope||Tool||Acceptance threshold||
|Unit|[classes / functions]|[framework]|[coverage or pass rate]|
|Integration|[service boundaries]|[framework]|[pass rate]|
|E2E / contract|[critical flows]|[tool]|[pass rate]|
|Load / perf|[endpoint or flow]|[tool]|[target from §6 metrics table]|
|Rollback|[procedure to verify]|Manual|Verified before prod|

h3. 5.10 Change Impact Assessment

||Factor||Affected component(s)||Nature of change||Impact level||Explanation & mitigation||
|User flows|[flow names]|[added / changed / removed]|Critical / High / Medium / Low|[what changes for users; rollback plan]|
|Data model / ERD|[entity names]|[new table / column / relationship / removed]|Critical / High / Medium / Low|[schema delta; migration risk]|
|Database|[table / index / query]|[DDL change / query pattern / volume]|Critical / High / Medium / Low|[lock risk; perf impact; backfill estimate]|
|API / service interface|[endpoint or service]|[added / changed / deprecated / removed]|Critical / High / Medium / Low|[consumer impact; versioning strategy]|
|Background jobs / queues|[job or queue name]|[new / changed payload / removed]|Critical / High / Medium / Low|[in-flight handling; idempotency]|
|Infrastructure / deployment|[service / config / env var]|[new dependency / scaling / cost]|Critical / High / Medium / Low|[rollout sequence; provisioning lead time]|
|Security & auth|[auth scope / permission]|[new access / changed scope / data exposure]|Critical / High / Medium / Low|[security review needed? blast radius]|
|Performance & scalability|[endpoint / query / job]|[added load / changed complexity]|Critical / High / Medium / Low|[p95 delta; throughput change; load test]|
|External integrations|[third-party / webhook / event]|[new contract / changed payload / removed]|Critical / High / Medium / Low|[partner notification; SLA impact]|
|Operations / on-call|[runbook / alert / dashboard]|[new alert / changed threshold]|Critical / High / Medium / Low|[on-call burden delta; training needed]|

h2. 6. Impact

h3. Business Impact

- [+ Revenue / retention / efficiency impact with magnitude]

h3. Technical Impact

- [+ Reliability / scalability / maintainability improvement]

h3. Metrics

||Metric||Current||Target||Notes||
|[Metric name]|[Current value]|[Target value]|[Source or estimate note]|

h2. 7. Risks, Trade-offs, Alternatives

h3. Risks

||Risk||Likelihood||Impact||Mitigation||
|[Risk]|Low/Med/High|Low/Med/High|[Mitigation]|

h3. Trade-offs

- We trade [X] for [Y]

h3. Alternatives Considered

- _[Alternative]:_ [1–2 line description]
  ** _Pros:_
  ** _Cons:_
  \*\* _Why not chosen:_

h2. 8. Plan, Timeline, Resources

h3. Phases

# _Phase 0 – Discovery / Spike:_ [outcomes, key tasks, success criteria]

# _Phase 1 – Core infra + happy path:_ [outcomes, key tasks, success criteria]

# _Phase 2 – Edge cases + hardening:_ [outcomes, key tasks, success criteria]

# _Phase 3 – Rollout & monitoring:_ [outcomes, key tasks, success criteria]

h3. Timeline
[Weeks/sprints — highlight critical dependencies]

h3. Resources

- _People:_ [roles + allocation, e.g. "2× BE, 1× FE, 0.5× DevOps for 2 sprints"]
- _Tools/infra:_ [new services, licenses, storage, additional spend]
- _Cross-team:_ [which teams, when]

h2. 9. Decision Required

We are asking for approval to:

- [Clear action/commitment 1]
- [Clear action/commitment 2]

{panel:title=Options|bgColor=#DEEBFF|borderColor=#4C9AFF}
_Option A (minimal):_ [description]
_Option B (full scope):_ [description]
_Option C (do nothing):_ [baseline risk or cost of inaction]
{panel}

h2. References

||Title||Link||Type||Used in||
|[Title]|[PROJ-XXX or Confluence page title\|url]|Jira / Confluence|[Section and how it was used]|
{noformat}
