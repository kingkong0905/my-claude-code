# Common Mistakes

The pattern for every mistake is the same: _vague/unmeasurable → specific/verifiable_.
Use these as a checklist when reviewing each section before delivery.
Referenced from [SKILL.md](SKILL.md) Writing Rules.

---

## Section 1 — Title

| Bad                          | Good                                                           |
| ---------------------------- | -------------------------------------------------------------- |
| "Search Improvement Project" | "Rebuild Job Search Index to Cut P95 Latency Below 800ms"      |
| "Database Changes Q3"        | "Zero-Downtime PostgreSQL → Aurora Migration for Jobs Service" |
| "AI Feature"                 | "AI Credit Limits & Alerts – Billing Slice 2"                  |

_Rules:_ Action verb + system name + measurable outcome. Avoid "project", "changes", "improvement".

---

## Section 1 — Summary bullets

Bad:

- Problem: The search is too slow and users are complaining.
- Solution: We will rebuild search using a new technology.
- Impact: Better user experience and performance.

Good:

- Problem: Job search P95 latency is 2.4s (target 800ms); 18% of searches time out, driving a 12% drop in job views week-over-week.
- Solution: Replace the current Elasticsearch 6 cluster with an Elasticsearch 8 cluster with per-tenant index sharding and Redis query cache.
- Impact: P95 latency to <800ms, timeout rate to <0.5%, estimated +8% recovery in job view conversion within 30 days.

---

## Section 2 — Pain points

| Bad                                 | Good                                                                                                                                   |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| "The system is slow."               | "Job search P95 is 2.4s vs 800ms target; every 100ms above target correlates with ~0.7% drop in apply-click rate (internal A/B data)." |
| "Users are unhappy."                | "CS received 340 recruiter tickets in the last 30 days citing slow search; 22 enterprise accounts flagged it as a renewal risk."       |
| "The codebase is hard to maintain." | "The search service has no owner, 0% test coverage on the ranking module, and takes 4+ hours to onboard a new engineer."               |
| "We have tech debt."                | "Schema migrations require 6-hour downtime windows, blocking the team from shipping changes more than once per sprint."                |

---

## Section 3 — Objectives

| Bad                          | Good                                                                                   |
| ---------------------------- | -------------------------------------------------------------------------------------- |
| "Improve search performance" | "Reduce job search P95 latency from 2.4s → <800ms on the `{{/search}}` endpoint"       |
| "Better reliability"         | "Reduce search timeout rate from 18% → <0.5%"                                          |
| "Reduce manual work"         | "Cut manual data reconciliation from 1 day/month to <1 hour/month"                     |
| "Make it scalable"           | "Support 3× current peak query load (9k → 27k QPS) without horizontal scaling changes" |

_Rules:_ Every objective = metric name + current value + target value + scope.

---

## Section 3 — Non-goals

| Bad                           | Good                                                                                              |
| ----------------------------- | ------------------------------------------------------------------------------------------------- |
| "Out of scope: UI changes"    | "Does not change the job posting creation flow or the recruiter UI"                               |
| "Not doing everything now"    | "Does not migrate the legacy candidate search index (separate workstream, tracked in [PROJ-456])" |
| "Performance is not in scope" | "Does not address slow report generation endpoints (separate bottleneck, tracked separately)"     |

_Rules:_ Non-goals prevent scope creep. Each one should name the specific thing excluded and, where possible, where it IS being tracked.

---

## Section 6 — Impact statements

| Bad                        | Good                                                                                                      |
| -------------------------- | --------------------------------------------------------------------------------------------------------- |
| "Will improve performance" | "+ Reduces P95 job search latency from 2.4s → <800ms (confirmed via load test on staging)"                |
| "Better user experience"   | "+ Estimated +8% recovery in job view conversion rate, based on correlation analysis from prior A/B test" |
| "Saves engineering time"   | "+ Eliminates 1 day/month of manual data reconciliation (2 engineers × 4 hours each)"                     |
| "Less risk"                | "− Increases infrastructure cost by ~$1,200/month for the additional replica nodes"                       |

_Rules:_ Prefix with `+` (benefit) or `−` (cost/trade-off). Always include direction, magnitude, and the basis for the estimate.

---

## Section 6 — Metrics table

Bad:

| Metric      | Current | Target |
| ----------- | ------- | ------ |
| Performance | Slow    | Fast   |
| Reliability | Low     | High   |

Good:

| Metric                     | Current     | Target        | Notes                                     |
| -------------------------- | ----------- | ------------- | ----------------------------------------- |
| Job search P95 latency     | 2.4s        | <800ms        | Measured via Datadog APM on `{{/search}}` |
| Search timeout rate        | 18%         | <0.5%         | Measured over 7-day rolling window        |
| Manual reconciliation time | 1 day/month | <1 hour/month | Estimate; will validate in Phase 1        |
| Monthly infra cost         | $4,200      | ~$5,400       | Increase for additional replica nodes     |

---

## Section 7 — Risks

Bad:

| Risk                 | Likelihood | Impact | Mitigation  |
| -------------------- | ---------- | ------ | ----------- |
| Something goes wrong | High       | High   | Be careful  |
| Downtime             | Medium     | High   | Have a plan |

Good:

| Risk                                                        | Likelihood | Impact | Mitigation                                                                                                        |
| ----------------------------------------------------------- | ---------- | ------ | ----------------------------------------------------------------------------------------------------------------- |
| Reindex job during peak traffic causes query latency spike  | Med        | High   | Schedule reindex during off-peak window (Sunday 2–6am AEST); add circuit breaker to fall back to existing cluster |
| Elasticsearch 8 query syntax breaks existing saved searches | Med        | Med    | Audit all 14 query templates before cutover; run parallel queries in shadow mode for 1 week                       |
| Redis cache invalidation bug causes stale search results    | Low        | High   | Cache TTL capped at 60s; add cache-bypass header for QA validation; monitor cache hit rate in Datadog             |

---

## Section 7 — Trade-offs

| Bad                                   | Good                                                                                                                                                                    |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "We are trading simplicity for speed" | "We trade a simpler single-cluster setup for per-tenant index sharding, which increases operational complexity but eliminates cross-tenant query interference"          |
| "Higher cost"                         | "We trade ~$1,200/month in additional infra spend for the ability to scale search independently of the write path"                                                      |
| "More complexity"                     | "We trade a synchronous write path for an async event-driven index update, which adds eventual consistency (< 2s lag) but removes write contention on the search index" |

---

## Section 8 — Phase descriptions

| Bad                        | Good                                                                                                                                                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Phase 1: Build the thing" | _Phase 1 — Core infrastructure (Weeks 1–3):_ Provision ES8 cluster, migrate index schema, implement dual-write from jobs service. _Success criteria:_ New cluster serving shadow traffic with P95 < 800ms in staging.         |
| "Phase 2: Test it"         | _Phase 2 — Validation & cutover (Weeks 4–5):_ Run 10% canary traffic on new cluster, monitor error rate and latency. _Success criteria:_ 7-day canary with <0.1% error rate and P95 consistently < 800ms before full cutover. |
