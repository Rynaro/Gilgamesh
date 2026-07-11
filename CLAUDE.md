# Claude Code — Gilgamesh

Load order for this repository:

1. `agent.md` — entry point, always loaded (roster entry budget ≤ 900 tokens)
2. `SPEC.md` — full methodology specification
3. `skills/<skill>.md` — on-demand per phase (flat layout)
4. `schemas/mission-contract.v1.json` — load on demand to validate an inbound mission-contract
5. `schemas/taskstate.v1.json` — load on demand to finalize the mission audit record
6. `schemas/handoff-request.v1.json` — load on demand to emit an upward delegation
7. `schemas/capability-authority.v1.json` — load on demand to instantiate the authority table
8. `schemas/ecl-envelope.v2.json` — load on demand to validate an outbound PROPOSE envelope (`schemas/ecl-envelope.v1.json` is retained for the ECL §7.3 back-compat window)

## Consumer Project Usage

After installing this Eidolon into a consumer project (`bash install.sh`), Claude Code will find the installed agent at `.eidolons/gilgamesh/agent.md`.

Add to the consumer project's `CLAUDE.md`:

```
@.eidolons/gilgamesh/agent.md
```
