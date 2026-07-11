# Changelog

All notable changes to Gilgamesh are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/); this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] — 2026-07-11

`in_construction` — gate-fail remediation. Gilgamesh v0.1.0 measured 53.3/33.3/40.0%
verified-completion under ESL change `generalist-eidolon`'s Arm-1 gate (an 80%
pass³ floor), FAIL. Failure review of the run corpus surfaced three durable,
mission-agnostic defects in the attestation discipline itself (not in any one
mission), all addressed here without touching the frozen gate corpus:

### Fixed

- **Incomplete / mislabeled attestations.** The dominant failure mode: terse final
  reports omitting mission-required labeled lines, and — even when a line was
  present — labels corrupted by folding a value-shape placeholder (e.g.
  `<path:line>`, `(pass/fail)`) into the label itself before the colon, which a
  mechanical grader reads as a different, unmatched label. `agent.md`'s P0 section
  and `skills/attest.md` now carry an explicit **required-lines contract**: re-read
  the mission, checklist every required label before emitting, reproduce each label
  verbatim, and put the answer as the value's first token. An incomplete or
  mislabeled report is now named as an inadmissible attestation, the same bar
  already applied to anchor-less claims.
- **Verification reported as blocked instead of routed.** Some runs correctly found
  an allowed indirect route to a verification outside the tool allowlist (a test
  target wrapping the same check); others gave up and either reported the check
  blocked with no further attempt, or silently substituted manual reasoning for an
  oracle's exit code. `skills/grind.md`'s externalized-verification section and
  `agent.md`'s P0 section now require checking for an allowed indirect route
  (`bats`/`make`/the project's own runner, or `eidolons sandbox`) before reporting
  a check unreachable, and forbid presenting hand-derived reasoning as an oracle
  result.
- **Unresolved `path:line` anchors.** A handful of cited anchors did not resolve
  against the file at that line. `agent.md`, `skills/attest.md`, and `SPEC.md`'s
  Attest section now require Reading and confirming an anchor before citing it, and
  prefer single lines over ranges.

No schema, cycle phase, stopping-policy state, or capability-authority row changed.
This is a P0-content-only patch to the Attest and Grind skills plus the always-loaded
`agent.md`; still gated on a re-run of the two-arm measurement gate before any
`shipped` flip.

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

[0.1.1]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.1.1
[0.1.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.1.0
