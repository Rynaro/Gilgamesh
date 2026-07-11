# Changelog

All notable changes to Gilgamesh are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/); this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-07-11

`in_construction` — the first authored cut of the Gilgamesh member repo, produced under
ESL change `generalist-eidolon` (Track E). Not yet shipped: the `shipped` flip is gated
on the two-arm measurement gate (capability-expansion + no-over-capture) and a human
go/no-go.

### Added

- **GILGAMESH methodology** — the `Gauge → Inventory → Lock → Grind → Attest`
  (G→I→L→G→A) cycle for a bounded-authority, specialist-preferring fallthrough
  generalist. Full spec in `SPEC.md`; always-loaded P0 rules in `agent.md`
  (≤ 900-token roster entry budget).
- **Structured TaskState** (`schemas/taskstate.v1.json`) — objective, acceptance
  criteria, env snapshot ref, plan+deps, evidenced claims, changed artefacts,
  externalized verification outcomes, unresolved risks, bounded loop budget
  (time/turns/tokens), the capability-authority table state, and the terminal
  stop_state. The single audit record of a mission.
- **Typed delegation contract** (`schemas/handoff-request.v1.json`) — `{objective,
  scope(paths,mode), deliverables, evidence_required, stop_conditions}` plus
  `suggested_specialist` and a REQUIRED `evidence_of_boundary` (delegation crosses an
  information/authority/modality boundary, never "it looks complex").
- **Capability-authority table** (`schemas/capability-authority.v1.json`) — six rows
  (read/write/exec/network/secrets/deploy) × two columns (default/escalation); deploy is
  never-grantable.
- **Inbound mission-contract** (`schemas/mission-contract.v1.json`) — the typed mission
  Gilgamesh consumes; validated in Gauge.
- **Stopping policy** — the mechanical `{continue, recover, escalate, terminate}` set,
  driven by the loop budget and the consecutive-failure counter.
- **Skills** — `verify-incoming` (blocking symmetric ECL receiver gate), `gauge`
  (intake/refusal/authority), `grind` (external-verify loop + stopping policy + budget),
  `attest` (result + handoff-request emission), `esl-hop` (Gilgamesh as MAKER;
  never self-verifies; fail-open without tonberry).
- **ECL v2.0 composition** — consumes `mission-contract`; emits `handoff-request` +
  result artefacts; ISE `assertion_grade: validated` earned by the pre-completion
  external-oracle gate; `auto_merge: false` / `auto_deploy: false`.
- **EIIS v1.4 installer** — marker-bounded host sections, cwd-only writes, idempotent
  (byte-identical re-run except `installed_at`), bash 3.2 compatible, canonical
  inventory sweep, per-skill dual-write, Codex + OpenCode + Cursor + Copilot wiring.
- Vendored `ecl-envelope.v1.json`, `ecl-envelope.v2.json`, `ecl-base-profile.v1.json`,
  `install.manifest.v1.json`; per-edge ECL contracts; canary missions; host notes; bats
  tests.

### Security

- `writes_repo: false` (real tree — the parent commits); `reads_network: false`;
  `persists: []` (no permanent memory — the wanderer leaves with no weapons).

[0.1.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.1.0
