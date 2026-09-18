# AI delivery measurement model

Use this reference when defining a dataset, joining sources, assessing attribution, or explaining metrics.

## Unit of analysis

The default unit is a durable work artifact, not a person, prompt, session, or line of code. One artifact may have several lifecycle events and several contributors.

Minimum normalized record:

| Field | Meaning |
|---|---|
| `artifact_id` | Stable source identifier plus system namespace |
| `artifact_type` | `pull_request`, `changeset`, `deployment`, `document`, `test`, `automation`, or another explicit type |
| `team` | Team responsible during the reporting period |
| `work_class` | Feature, defect, maintenance, documentation, operational work, or another locally defined class |
| `created_at` | Creation time |
| `accepted_at` | Merge, approval, or publication time |
| `delivered_at` | Production deployment or equivalent release time, if applicable |
| `state` | Draft, reviewed, accepted, delivered, reverted, archived, or source-specific state |
| `parent_ids` | Issue, epic, project, document, PR, or release links used for deduplication and traceability |
| `ai_attribution` | `confirmed`, `probable`, `possible`, or `unknown` |
| `ai_tools` | Zero or more normalized assistant identifiers supported by evidence |
| `ai_modes` | How assistance occurred, such as `completion`, `chat`, `edit`, `agentic`, or `review` |
| `ai_evidence` | Source and event identifiers supporting attribution |
| `provenance_version` | Version of the declaration and normalization rules |
| `quality_signals` | Rework, revert, defect, incident, review, or approval evidence |
| `adoption_signals` | References, reuse, readership, downloads, or downstream usage evidence |

Keep personally identifying fields only when needed to deduplicate or assign the team. Aggregate reporting by team or cohort.

## Attribution hierarchy

- **Confirmed:** artifact-level provenance, such as an AI tool or agent recording the exact PR, commit, file revision, or published document it created or materially changed.
- **Probable:** a strong deterministic join, such as an AI session linked to a branch and commits within a bounded interval, with no contradictory evidence.
- **Possible:** indirect or self-reported evidence that AI contributed, but no artifact-level join.
- **Unknown:** no reliable evidence either way. Unknown does not mean non-AI.

Store the rule version and raw source identifier used for each classification. When multiple rules apply, retain the strongest supported classification and all relevant evidence.

Store multiple assistant identifiers when more than one tool contributed. Normalize known tools to stable lowercase slugs, but retain the declared raw value so new assistants do not require a schema change. Provider-specific branch prefixes, bot accounts, task URLs, or telemetry fields belong in `ai_evidence`, not in the canonical schema.

Never classify from prose style, code style, commit size, job title, license assignment, or tool access alone.

## PR attribution resolution order

Evaluate evidence in this order and stop only when the strongest available classification and tool set are established. Retain additional corroborating evidence even after a match.

1. **Standardized labels — confirmed.** Treat `ai-assisted` as artifact-level attribution. Read every `ai-tool:<slug>` label; multiple assistants may be present. A tool label without `ai-assisted` is still an explicit declaration, but flag the labeling inconsistency.
2. **Structured or explicit PR description — confirmed.** Parse the versioned provenance marker when present. An unambiguous natural-language declaration such as “AI-assisted using Cursor” is explicit evidence, but preserve the original text and note that it is unstructured.
3. **Verified assistant identity or durable task evidence — confirmed or probable.** Match contributors, commit authors, co-author trailers, bot accounts, task URLs, or check-run identities only against an organization-maintained registry of known assistant identities. A normal human contributor is never AI evidence by itself.
4. **Controlled branch convention — probable.** Match branch prefixes only against a maintained registry whose ownership is known, such as a prefix reserved for a particular assistant. A name that merely contains words such as `ai`, `agent`, or a product name is not sufficient without that convention.
5. **PR title or other free text — possible.** Use only explicit assistant attribution, not stylistic guesses or incidental product mentions. Treat this as a last-resort lead and report it separately from confirmed and probable attribution.
6. **No reliable match — unknown.** Do not convert missing evidence into non-AI attribution.

If sources conflict, preserve the conflict and prefer the most direct artifact-level declaration. Do not silently override an explicit label using a branch name or inferred identity. Report the affected artifacts for review when the conflict changes whether or how the PR is attributed.

## Portable PR provenance

For organization-wide collection, prefer a provider-neutral PR declaration plus standardized labels. A compact machine-readable marker can use this shape:

```html
<!-- ai-provenance:v1 {"assisted":true,"tools":["codex","claude"],"modes":["agentic","review"]} -->
```

Recommended labels:

- `ai-assisted`
- `ai-tool:<slug>` for each declared assistant
- `ai-mode:<mode>` when the organization wants mode-level reporting

Accept declared tools that are not yet in the known registry. Normalize their slugs deterministically and flag them for governance review rather than discarding the evidence.

Use provider-specific detectors only to validate or supplement the declaration. Examples include controlled branch prefixes, assistant bot accounts, IDE metadata, task links, or vendor telemetry. No single detector is required across every assistant.

When enforcement is requested, recommend repository instructions and PR templates for declaration, backed by a GitHub check or app that validates the marker and applies labels. Instruction files guide compatible assistants but are not enforcement controls.

## Core calculations

Report counts alongside rates and cohort size.

Use organization-generated per-artifact values when they exist. The formulas below define meaning and support validation; they do not authorize silently replacing the canonical source with a fresh calculation from raw events. Preserve the source record, reporting window, and whether the value was generated, enriched, or `github-backfilled` because the generated snapshot captured an unfinished PR.

- Acceptance rate = accepted attributed artifacts / created attributed artifacts.
- Delivery rate = delivered attributed artifacts / accepted attributed artifacts eligible for deployment.
- Median cycle time = median(`accepted_at - created_at`) for comparable artifact types.
- Median delivery lead time = median(`delivered_at - accepted_at`) where the join is known.
- Rework rate = accepted artifacts requiring a material corrective revision inside a declared window / accepted artifacts.
- Reversion rate = reverted delivered artifacts / delivered artifacts.
- Attribution coverage = artifacts with confirmed or probable attribution / artifacts in the scoped cohort.
- High-confidence delivery share = delivered artifacts with confirmed or probable attribution / all delivered artifacts in the scoped cohort.

Define “material corrective revision,” reporting windows, and eligibility in the report. Prefer medians, percentiles, and trends over averages alone.

## Comparison rules

AI-assisted and unknown work are not clean treatment and control groups. Compare them only as descriptive cohorts unless assignment was randomized or a credible causal design exists.

Segment or match by work class, repository, team, size band, and time period where sample size permits. Flag selection effects: complex work may use AI more often, enthusiastic users may differ from non-users, and telemetry coverage can change over time.

Do not collapse delivery, speed, quality, adoption, and attribution confidence into a single score unless the user supplies a governance-approved weighting model. Even then, show the underlying measures.

## Source joins

For the Compass weekly report, enrich only PRs explicitly listed in the selected generated metrics issues. The repository-plus-PR-number pairs parsed from those issues form an exact allowlist. Do not add PRs discovered through merged searches, repository activity, authors, branches, releases, or fallback evidence. Releases remain a separate repository-level source and do not expand the PR cohort.

Prefer stable identifiers in this order:

1. Explicit artifact link recorded by the AI tool or agent.
2. PR, commit, deployment, document, or issue identifiers shared across systems.
3. Repository plus branch plus bounded timestamps.
4. Actor plus bounded timestamps, only as weak evidence and never as confirmed attribution.

When an analytics layer is available, obtain the lowest-level evidence permitted. Preserve aggregate activity metrics separately, map underlying events to normalized artifacts, and quantify events that cannot be matched. Never reverse-engineer confident artifact attribution from an aggregate utilization percentage.

## Recommended scorecard shape

For each reporting period and cohort, show:

| Dimension | Measures |
|---|---|
| Delivered work | Merged PRs, production releases, published documents, accepted automations |
| Flow | Creation-to-acceptance and acceptance-to-delivery percentiles |
| Quality | Rework, reversion, defects, incidents, approval outcomes |
| Adoption | Reuse, references, readership, downstream consumption |
| Evidence | Confirmed/probable/possible/unknown mix, join coverage, unmatched AI events |

Add short artifact examples with links when permitted. Examples make the analysis auditable; they should not become an individual ranking.

Include a source ledger beneath the scorecard. For each measure, identify the generated GitHub issue, its coverage window, exact issue-listed PR count, missing observations, batched GitHub enrichment fields, deeper attribution lookups, and any disclosed `github-backfilled` calculation.
