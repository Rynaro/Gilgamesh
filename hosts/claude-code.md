# Wiring Gilgamesh into Claude Code

## 1. Install

```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts claude-code
```

Or install all hosts at once:

```bash
bash install.sh --hosts all
```

## 2. Config

Add to your consumer project's `CLAUDE.md`:

```markdown
@.eidolons/gilgamesh/agent.md
```

Claude Code loads `agent.md` into every session. Skills load on-demand when Gilgamesh
requests them (triggered by phase entry or envelope detection).

### Frontmatter (agent.md)

```yaml
---
name: gilgamesh
version: 0.1.1
methodology: GILGAMESH
methodology_version: 0.1.1
role: generalist — bounded-authority, specialist-preferring fallthrough worker
---
```

### Subagent dispatch (`.claude/agents/gilgamesh.md`)

When installed with `--hosts claude-code`, the installer writes a Claude Code subagent
dispatch file at `.claude/agents/gilgamesh.md`:

```yaml
---
name: gilgamesh
description: Bounded-authority, specialist-preferring fallthrough generalist. Dispatched only when no specialist scores >= tau AND the Step-2(a) mechanical predicate resolves actionable; sandbox-first, PROPOSE-only (never the real tree).
model: sonnet
tools: Read, Grep, Glob, Bash(eidolons sandbox:*), Bash(make:*), Bash(bats:*), Bash(rspec:*), Bash(jest:*), Bash(pytest:*), Bash(go test:*), Bash(shellcheck:*), Bash(shasum:*), Bash(wc:*), mcp__atlas-aci__*, mcp__crystalium__*, mcp__tonberry__*
x-eidolons-mcp-wired: [atlas-aci, crystalium, tonberry]
---
You are GILGAMESH. Read these two files in order at session start:
1. `./.eidolons/gilgamesh/agent.md` — always-loaded P0 rules.
2. `./.eidolons/gilgamesh/SPEC.md` — deep on-demand methodology spec.
Skills live at `./.eidolons/gilgamesh/skills/<skill>.md` (load on demand).
```

The installed `agent.md`'s P0 section (and `skills/attest.md` / `skills/grind.md` in
full detail) carries the **attest contract**: when a mission enumerates required
labeled report lines, every one must appear in the final message with its label
reproduced verbatim (`LABEL: value`, answer first — a placeholder like `<path:line>`
describes the value's shape, never additional label text); a verification the tool
allowlist can't run directly is routed through an allowed indirect channel (`bats`,
`make`, `eidolons sandbox`) before ever being reported blocked; and every cited
`path:line` anchor is Read and confirmed before it is cited. This is what the
subagent dispatch file above is scoped to enforce — the tool allowlist stays narrow
on purpose (§ below), so the contract's job is to make sure narrow tools still yield
a complete, honestly-labeled report.

The `model: sonnet` frontmatter runs Gilgamesh at the **standard** tier (R-010): the
residual-hardest fallthrough missions are cost-sensitive, and any capability shortfall
is caught by the two-arm gate's Arm-1. The tool allowlist is **scoped** — no generic
`Bash(*)`; the MCP surfaces (atlas-aci for read, crystalium for per-mission recall,
tonberry for the opt-in ESL hop) are the only wildcarded grants.

## 3. Verify

Open a Claude Code session in your project and dispatch a fallthrough mission:

```
"Using Gilgamesh: no specialist fits — set up a reproducible test harness for module X.
 Verifier: the project test suite exits 0. Propose a verified result."
```

Expected behavior:
1. Gilgamesh loads `skills/verify-incoming.md` — envelope passes (`verify_pass`).
2. Phase G (Gauge): validates the mission-contract, confirms no specialist fit,
   instantiates the authority table.
3. Phase I (Inventory): atlas-aci gathers context; names the test suite as the oracle.
4. Phase L (Lock): freezes acceptance signals, loop budget, verification plan.
5. Phase G (Grind): sandbox edits gated by the test suite; the stopping policy runs.
6. Phase A (Attest): emits an evidence-anchored result PROPOSE + finalized TaskState.
7. The parent applies the result to the real tree and commits.

## 4. Troubleshooting

**Gilgamesh not responding to `@.eidolons/gilgamesh/agent.md`**
- Verify `.eidolons/gilgamesh/agent.md` exists: `ls .eidolons/gilgamesh/agent.md`
- Verify the `@` path in `CLAUDE.md` is correct relative to the project root.

**Gilgamesh accepting a mission that belongs to a specialist**
- Check Phase G triage in `skills/gauge.md`. Gilgamesh is fallthrough-only; a clean
  specialist fit must REFUSE with a `suggested_specialist`.

**Gilgamesh trying to write the real tree**
- It must not. `security.writes_repo: false`; the only mutation path is
  `eidolons sandbox apply`. The parent applies the verified result and commits.

**PROPOSE not being applied**
- Gilgamesh never applies or commits. The parent (orchestrator / human) applies the
  result to the real tree, and routes any `handoff-request` to the suggested specialist.
