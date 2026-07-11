# Changelog

All notable changes to Gilgamesh are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/); this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-07-11

Shipped release. Methodology identical to 0.3.0; promoted to 1.0.0 after clearing
the generalist-eidolon two-arm measurement gate (Arm-1 pass³ 93.3/93.3/100.0,
Arm-2 0 over-capture, independently attested) — status `in_construction` →
`shipped`.

## [0.3.0] — 2026-07-11

`in_construction` — anchor-precision: mandatory pre-emit anchor re-read (quoted
fragment must be present at the cited line) + repo-only anchor rule; closes the
sole residual Arm-1 failure mode measured in gate attempt 5 (100/73/67, misses
pass³ on anchor drift).

Attempt 5 was the first valid v0.2.0 measurement (prior attempts were discarded —
spend-limit and grader defects, not methodology defects). Under a faithful
grader it scored 100% / 73.3% / 66.7% verified-completion — mean exactly 80%,
but two of three runs land below the 80% pass³ floor. Every residual failure
across all three runs is a single class: an `EVIDENCE-<key>:` or
`PROPOSAL-TARGET:` anchor citing a `path:line` where the line doesn't resolve
(right file, wrong/empty/out-of-range line), plus one case citing an ephemeral
command-output path (`/tmp/tbc_out.txt:2`) instead of a repo file. Run 1 resolved
every anchor cleanly, so the discipline is achievable — v0.2.0's quoted-anchor
rule (cite a verbatim fragment) was necessary but not sufficient: an agent can
copy a fragment at write-time and still have it drift off the cited line by
report-assembly time, or cite a scratch file instead of the repo source it came
from.

### Fixed

- **Pre-emit anchor re-read rule (mechanical, not exhortative).** Before writing
  ANY `path:line` anchor into the final report, Gilgamesh now MUST Read that
  exact line number in that file and confirm the line's text contains the
  verbatim fragment being quoted. If it does not (drifted, empty, or
  out-of-range), the anchor is wrong — Grep the fragment and cite the corrected
  line. An anchor not re-read at that exact line in this same mission is
  inadmissible, the Excalipoor rule applied to line numbers: a citation you
  cannot re-read is a fake blade.
- **Repo-only anchor rule.** `EVIDENCE-<key>` and `PROPOSAL-TARGET` anchors now
  MUST resolve to a repo-relative path that exists in the working checkout —
  never an ephemeral, temp, sandbox-scratch, or command-output path (`/tmp/*`,
  redirected stdout, etc.). A fact produced by running a command is recorded on
  its `VERIFY-<name>` line; the anchor instead cites the repo file or script the
  fact derives from.
- Both rules are embedded verbatim in every surface the eval harness actually
  loads, per the v0.1.1→v0.2.0 forensic lesson: the `.claude/agents/gilgamesh.md`
  heredoc body in `install.sh`, and `agent.md`'s P0 section (which stays within
  its token budget — 901 tokens, trimmed elsewhere to make room). `skills/
  attest.md` and `skills/grind.md` carry the same two rules in full detail as
  the deep on-demand reference; `SPEC.md` and `hosts/claude-code.md` document
  them.

No schema, cycle phase, stopping-policy state, or capability-authority row
changed. Still gated on a re-run of the two-arm measurement gate before any
`shipped` flip.

## [0.2.0] — 2026-07-11

`in_construction` — concentrate mechanical attestation discipline into host-loaded
surfaces; forensics showed v0.1.1 landed only in non-loaded skill files. The v0.1.1
remediation text was correct but misplaced: `skills/attest.md` and `skills/grind.md`
are on-demand deep references the P4 gate harness never loads, and the Claude Code
subagent dispatch file `install.sh` writes to `.claude/agents/gilgamesh.md` only
pointed at `agent.md`/`SPEC.md` by reference rather than carrying the contract
itself. The gate failed a second time on the same defect class.

### Fixed

- **Contract now lives verbatim in every surface the harness actually loads.** The
  `.claude/agents/gilgamesh.md` heredoc in `install.sh` now embeds the full mission
  report protocol directly in its body — the `REQUIRED-LABELS:` enumeration rule,
  the verbatim `LABEL: value` format, the quoted-anchor rule, and the three-rung
  verify-routing ladder — rather than only referencing `agent.md`. Frontmatter
  (`name`/`description`/`model`/`tools`/`x-eidolons-mcp-wired`) is unchanged.
  `agent.md`'s P0 section carries the same contract, tightened to stay within its
  existing token budget (897 tokens, unchanged).
- **Quoted-anchor rule made mechanical.** Every cited `path:line` anchor must now be
  followed by a short double-quoted verbatim fragment (3–6 words) of that exact
  line, copied after Reading it — closing the gap where an anchor could be cited
  without having actually been read.
- **Verify-routing ladder made explicit and numbered.** (1) run an allowlisted
  command directly; (2) otherwise route through `eidolons sandbox run
  --allow-unsafe-host -- <cmd>`; (3) only then emit `fail` + blocker. `skills/
  attest.md` and `skills/grind.md` now state the same three rungs in the same
  order, so the deep reference and the always-loaded surfaces cannot drift.
- `hosts/claude-code.md` documents the embedded contract and the updated
  frontmatter version.

No schema, cycle phase, stopping-policy state, or capability-authority row changed.
Still gated on a re-run of the two-arm measurement gate before any `shipped` flip.

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

[1.0.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v1.0.0
[0.3.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.3.0
[0.2.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.2.0
[0.1.1]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.1.1
[0.1.0]: https://github.com/Rynaro/Gilgamesh/releases/tag/v0.1.0
