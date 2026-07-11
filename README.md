# Gilgamesh — Bounded-Authority Fallthrough Generalist

A deliberately boring general-purpose Eidolon in the
[Eidolons](https://github.com/Rynaro/eidolons) hierarchy. When the router's dispatch
predicate finds no specialist scoring ≥ τ but the prompt is actionable, the
orchestrator delegates a typed **mission-contract** to Gilgamesh. Gilgamesh gauges the
mission, gathers its context, locks a plan, grinds it out under external-only
verification, and returns an evidence-anchored result.

> Gilgamesh is a worker, not a router. The parent always commits — Gilgamesh proposes.

> **Constitutional lore.** Gilgamesh famously cannot tell Excalibur from Excalipoor — he
> once proudly wielded the fake. So self-assessment is constitutionally distrusted: a
> result is real only when an external oracle says so. And the wanderer leaves with no
> weapons: no permanent memory, no deploy authority, no cross-task policy.

## Quick Start

```bash
git clone https://github.com/Rynaro/Gilgamesh
cd your-project
bash ../Gilgamesh/install.sh
```

Default install target: `./.eidolons/gilgamesh`. Then wire Claude Code:

```
# Add to your project's CLAUDE.md:
@.eidolons/gilgamesh/agent.md
```

## The G→I→L→G→A Cycle

```
G ──▶ I ──▶ L ──▶ G ──▶ A ──┬──▶ PROPOSE (evidence-anchored result)
                            └──▶ ESCALATE / REFUSE
```

| Phase | Role |
|---|---|
| **G** Gauge | Verify the envelope; validate the mission-contract; instantiate the authority table; REFUSE specialist-fit or over-authority |
| **I** Inventory | Read-only, budget-metered gather — "collect the weapons": context map, acceptance signals, available oracles, unknowns |
| **L** Lock | Freeze acceptance signals, loop budget, verification plan (an oracle per deliverable), risk ledger. After Lock, scope only shrinks |
| **G** Grind | Externally-verified work loop within authority; sandbox-first, PROPOSE-only; the stopping policy runs each iteration |
| **A** Attest | Emit the evidence-anchored result + any handoff-request(s) + ECL envelope; finalize TaskState as the audit record |

## Stopping Policy (mechanical, four closed states)

`{continue, recover, escalate, terminate}` — each Grind iteration resolves to exactly
one, driven by the loop budget and the consecutive-failure counter. No fifth option, no
"just one more" beyond a wall.

## Capability-Authority Table

Instantiated per mission (default column plus an escalation column):

| Capability | Default | Escalation |
|---|---|---|
| read | scoped repo + tool output | broaden scope (approved) |
| write | **sandbox only** | none — PROPOSE-only is constitutional |
| exec | named oracle commands in sandbox | more oracle commands (approved, sandboxed) |
| network | none | proxied read via broker (approved) |
| secrets | none | broker-issued, single-use, mission-scoped |
| deploy | none | **never-grantable** |

## Design Principles

**Harness over model.** Generality is a system/harness property, not a persona property
(research digest §1). Gilgamesh wins by owning a fixed cycle with a small action
substrate, structured task-state, externalized verification, and an explicit stopping
policy — not an open-ended ReAct loop.

**External-only verify.** Verification is externalized, never self-reported (digest §4):
tests, parsers, diffs, typecheck, compile, schema-validate, environment feedback. Your
blade might be Excalipoor — let the oracle tell you.

**Deliberately boring worker.** Explore, form a local plan, act only within authority,
run validations, return a structured result. Owns no permanent memory, no deploy
authority, no cross-task policy (digest reference design).

**Delegation crosses a boundary, never complexity.** A delegation need is emitted as a
typed `handoff-request` PROPOSEd *upward* — with `evidence_of_boundary` naming the
information / authority / modality boundary crossed. Never "it looks complex." The
orchestrator routes; Gilgamesh never spawns.

## Architecture

```
Gilgamesh/
├── install.sh                        # Install into any project (EIIS-conformant)
├── agent.md                          # Always-loaded entry point (≤900 tokens)
├── SPEC.md                           # Full GILGAMESH methodology specification
├── ECL_VERSION                       # 2.0
├── EIIS_VERSION                      # 1.4
├── skills/
│   ├── verify-incoming.md            # BLOCKING ECL gate (ECL §6.2.2)
│   ├── gauge.md                      # Phase G — intake / refusal / authority
│   ├── grind.md                      # Phase Grind — external-verify loop + stopping policy
│   ├── attest.md                     # Phase A — result + handoff-request emission
│   └── esl-hop.md                    # ESL lifecycle hop — Gilgamesh as MAKER (opt-in)
├── schemas/
│   ├── taskstate.v1.json             # Structured TaskState (audit record)
│   ├── handoff-request.v1.json       # Typed upward delegation contract
│   ├── mission-contract.v1.json      # Inbound mission-contract (consumed)
│   ├── capability-authority.v1.json  # Six-row authority table (default/escalation)
│   ├── ecl-envelope.v1.json          # Vendored ECL envelope schema (v1 — §7.3 window)
│   ├── ecl-envelope.v2.json          # Vendored ECL envelope schema (v2 — outbound)
│   ├── ecl-base-profile.v1.json      # Vendored ECL base profile
│   └── install.manifest.v1.json      # Vendored EIIS manifest schema
├── contracts/                        # ECL per-edge contracts (inbound + upward + lateral)
├── hosts/                            # Per-host wiring notes
├── evals/                            # Canary missions
└── examples/                         # Sample install.manifest.json
```

## Standards

- [EIIS v1.4](https://github.com/Rynaro/eidolons-eiis) — install contract
- [ECL v2.0](https://github.com/Rynaro/eidolons-ecl) — communication contract

## Status

`v1.0.0` — `shipped`. Gilgamesh cleared the two-arm measurement gate under ESL change
`generalist-eidolon` (Arm-1 pass³ 93.3/93.3/100.0, Arm-2 zero over-capture,
independently attested) and the human go/no-go; promoted from `in_construction`.

---

*Gilgamesh — your blade might be Excalipoor; let the oracle tell you.*
