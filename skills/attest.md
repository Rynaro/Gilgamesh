---
name: gilgamesh-attest
description: Phase A (Attest) result emission — finalizes the TaskState audit record with evidence-anchored claims, emits the mission result via ECL PROPOSE, and PROPOSEs any typed handoff-request UPWARD (never dispatches). Use when Grind reaches a terminal stop_state; load at the end of a GILGAMESH cycle. Do NOT use during Gauge/Inventory/Lock/Grind.
metadata:
  methodology: Gilgamesh
  phase: A
---

# Attest Skill — Gilgamesh (Phase A result)

## When to use

Load when Grind reaches a terminal `stop_state` (`terminate` or `escalate`). Attest
turns the mission into an audit record and an ECL PROPOSE. Never invoked in Gauge,
Inventory, Lock, or Grind.

The wanderer leaves with no weapons: everything collected during the mission is either
returned here in the Attest record or discarded. Nothing persists (`security.persists:
[]`).

---

## Step 1 — Finalize the TaskState (the audit record)

Complete `schemas/taskstate.v1.json`. Each entry in `claims[]` MUST carry ≥1 external
**evidence** anchor drawn from `verification_outcomes[]` (an oracle result, a
`path:line`, or a diff). A claim with no external anchor is **inadmissible** — the
Excalipoor rule: a proud assertion is worthless if no oracle confirmed the blade.

Record: final `stop_state`, `verification_outcomes`, `changed_artifacts` (sandbox
paths), `unresolved_risks`, and the spent `budget`. This is the mission's single audit
artefact; ship it verbatim.

---

## Step 1a — The report is the attestation (required-lines contract)

When the inbound mission enumerates required labeled report lines, your final
human-readable message is itself part of the audit record, not a separate courtesy
summary. A report missing any required line is an **inadmissible attestation** — the
same Excalipoor rule as an anchor-less claim applies to an omitted line.

**Before emitting:** RE-READ the mission, list every required label, and check each
one off against your draft. Do this even under budget pressure — a terse-but-complete
report beats a longer one that drops a required line.

**Label discipline.** Reproduce each label **exactly** as the mission gives it, one
per line, as `LABEL: value`. A placeholder shown after the label (e.g. `<path:line>`,
`(pass/fail)`) describes the **shape of the value** — it is not additional label text.
Never insert it, or any other parenthetical, between the label and its colon; that
turns a matched line into an unmatched one under mechanical grading.

**Value format.** The value's first whitespace-delimited token must **be** the
answer — a number, `pass`/`fail`, or a `path:line` — with any annotation trailing
after a space. A grader reading the first token should never have to parse prose to
find the answer.

**Anchor discipline.** Cite only `path:line` anchors you have Read and confirmed
resolve to the claimed content; prefer a single line over a range. An anchor you
have not re-checked against the current file is a guess, not evidence.

**Verify routing.** If a required verification line names a check your tool
allowlist cannot run directly, do not treat that as a dead end and do not silently
substitute manual reasoning for an oracle's exit code. Look for an **allowed indirect
route** first (see `skills/grind.md` — externalized verification). Only when no
allowed route reaches the oracle does the line get `VERIFY-<x>: fail`, immediately
followed by the blocker — never a missing line, and never a `pass` you did not
actually observe.

---

## Step 2 — Emit the result (ECL PROPOSE)

On `terminate` (success), emit the mission **result** to the orchestrator:

1. Write the result artefact + compute its `sha256` and `size_bytes`.
2. Compose the ECL v2.0 envelope sidecar (validate against
   `schemas/ecl-envelope.v2.json`):

   ```json
   {
     "envelope_version": "2.0",
     "message_id": "<UUIDv7>",
     "thread_id": "<from inbound envelope>",
     "from": { "eidolon": "gilgamesh", "version": "<version>" },
     "to": { "eidolon": "orchestrator" },
     "performative": "PROPOSE",
     "objective": "<=240-char summary of the result>",
     "artifact": { "kind": "<result-kind>", "schema_version": "1", "path": "<rel>", "sha256": "<hex>", "size_bytes": <N> },
     "ise": {
       "assertion_grade": "validated",
       "provenance": { "methodology_version": "gilgamesh-<version>", "tool_surface": ["Read","Grep","Glob","Bash(eidolons sandbox:*)"], "lateral_consults": [] },
       "receiver_authorization": { "auto_route": true, "auto_merge": false, "auto_deploy": false }
     },
     "integrity": { "method": "sha256", "value": "<hex>" }
   }
   ```

   **`assertion_grade: "validated"`** is earned by construction (§4 pre-completion
   gate), never self-report. **`auto_merge: false`** is load-bearing: the parent
   applies and commits (PROPOSE-only). **`auto_deploy: false`** mirrors the
   never-grantable deploy row. `lateral_consults` records a `forge` consult if one
   informed the result; otherwise empty.

On `escalate`, emit `ESCALATE` instead, carrying the last oracle output.

---

## Step 3 — Emit handoff-request(s) UPWARD (never dispatch)

For any work that crossed an **information / authority / modality** boundary, emit a
typed `handoff-request` (`schemas/handoff-request.v1.json`) as a **PROPOSE to the
orchestrator** — a proposal to route, **not** a dispatch (AC-E09, HC8):

```json
{
  "schema_version": "1",
  "kind": "handoff-request",
  "objective": "<sub-mission goal>",
  "scope": { "paths": ["..."], "mode": "read-write" },
  "deliverables": ["..."],
  "evidence_required": ["<oracle output that will prove it>"],
  "stop_conditions": ["..."],
  "suggested_specialist": "<atlas|kupo|vigil|idg|forge|...>",
  "evidence_of_boundary": {
    "boundary_kind": "authority",
    "rationale": "requires deploy authority Gilgamesh's table denies (never-grantable)"
  }
}
```

**`evidence_of_boundary` is REQUIRED.** Delegation is never justified by "it looks
complex" (digest §5) — it must name the boundary: a **separable information context**, an
**authority Gilgamesh cannot grant itself**, or a **distinct modality Gilgamesh cannot
verify externally**.

**Cross-check the worker-never-router invariant:** `handoffs.downstream: []`. Gilgamesh
invokes **no spawn primitive** and calls no subagent. The orchestrator owns routing;
Gilgamesh only proposes it.

---

## Step 4 — Memory + session end (graceful skip)

After emitting PROPOSE:

- `mcp__crystalium__ingest(envelope, payload)` — record the outbound spine for
  provenance. There is **no post-flight `commit`**: unlike a specialist, Gilgamesh
  grows no durable pattern library (R-032).
- `mcp__crystalium__session_end()` on the terminal exit → Dream consolidation.

All `mcp__crystalium__*` calls are skipped silently when CRYSTALIUM is absent.

---

## Notes

- **Evidence or it did not happen.** Every claim resolves to an oracle result. No
  anchor → drop the claim; it was never real.
- **Result PROPOSE, never commit.** The parent applies and commits with its own
  authority; Gilgamesh holds none.
- **Handoff is a proposal, not a dispatch.** You return the typed request; the
  orchestrator routes it. You never spawn.

---

*Attest Skill — Gilgamesh Phase A: audit record + evidence-anchored PROPOSE + upward handoff-request*
