# Installing Gilgamesh

Gilgamesh installs into any project as a self-contained agent directory.

## Prerequisites

- `bash` 3.2+ (macOS ships with bash 3.2; no upgrade required)
- `git` (for clone method)
- `jq` (for manifest validation; auto-installed by the nexus CLI if absent)

## Quick Install

```bash
git clone https://github.com/Rynaro/Gilgamesh
cd your-project
bash ../Gilgamesh/install.sh
```

Default target: `./.eidolons/gilgamesh`. Then wire your AI tooling (see host sections below).

## Options

```
bash install.sh [OPTIONS]

  --target DIR          Target install dir (default: ./.eidolons/gilgamesh)
  --hosts LIST          claude-code,copilot,cursor,opencode,codex,all,auto,none (default: auto)
  --shared-dispatch     Compose a marker-bounded section in root AGENTS.md / CLAUDE.md / copilot
  --no-shared-dispatch  Skip root dispatch files (default)
  --force               Overwrite existing install
  --dry-run             Print actions, no writes
  --non-interactive     No prompts; fail on ambiguity (meta-installer mode)
  --manifest-only       Only emit install.manifest.json
  --version             Print Gilgamesh version
  -h, --help            Show help
```

Exit codes: `0` ok · `2` bad args · `3` already-installed (no --force) · `4` token budget exceeded.

---

## Claude Code

**Install:**
```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts claude-code
```

**Wire:**
Add to your project's `CLAUDE.md`:
```
@.eidolons/gilgamesh/agent.md
```

**Verify:**
Open a session and dispatch a fallthrough mission that fits no specialist:
```
"Using Gilgamesh: no specialist fits — set up a reproducible test harness for module X.
 Verifier: the project test suite exits 0. Propose a verified result."
```

Expected: Gilgamesh runs Gauge (validates the mission, instantiates the authority
table), Inventory (gathers context + names the oracle), Lock (freezes the plan +
budget), Grind (sandbox edits gated by the test suite), Attest (evidence-anchored
PROPOSE). The real tree is unchanged — the parent commits.

---

## GitHub Copilot

**Install:**
```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts copilot
```

**Wire:**
The installer writes per-skill instruction files under `.github/instructions/`. With
`--shared-dispatch`, a marker-bounded section is added to
`.github/copilot-instructions.md` pointing at `.eidolons/gilgamesh/agent.md`.

---

## Cursor

**Install:**
```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts cursor
```

**Wire:**
The installer writes per-skill rules under `.cursor/rules/`. Activate in Cursor's rules panel.

---

## OpenCode

**Install:**
```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts opencode
```

**Wire:**
The installer creates `.opencode/agents/gilgamesh.md`. OpenCode picks this up automatically.

---

## Codex

**Install:**
```bash
bash install.sh --target ./.eidolons/gilgamesh --hosts codex
```

**Wire:**
The installer creates `.codex/agents/gilgamesh.md` and a marker-bounded section in root
`AGENTS.md`.

---

## All Hosts at Once

```bash
bash install.sh --hosts all
```

---

## Raw API / Any LLM

Copy `.eidolons/gilgamesh/agent.md` (compact, ≤ 900 tokens) as the system prompt.
Load `.eidolons/gilgamesh/SPEC.md` for the full methodology. Load skills on-demand.

---

## Uninstall

```bash
rm -rf .eidolons/gilgamesh
```

Then remove the dispatch lines / marker blocks added to `CLAUDE.md`,
`.github/copilot-instructions.md`, `AGENTS.md`, etc.
