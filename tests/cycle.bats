#!/usr/bin/env bats
# tests/cycle.bats — GILGAMESH methodology invariants (schema + spec shape).
#
# Asserts the machine-checkable methodology claims: the four-state stopping policy,
# the six-row capability-authority table, the bounded loop budget, externalized
# verification, and the worker-never-router posture.

load helpers.bash

# ── Stopping policy — exactly {continue, recover, escalate, terminate} ────────

@test "taskstate stop_state enum is exactly the four states" {
  if ! command -v jq >/dev/null 2>&1; then skip "jq not available"; fi
  run jq -e '.properties.stop_state.enum | sort == ["continue","escalate","recover","terminate"]' \
    "${REPO_ROOT}/schemas/taskstate.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

@test "SPEC.md and PERSONA.md enumerate the four stop states" {
  for f in SPEC.md PERSONA.md; do
    for state in continue recover escalate terminate; do
      run grep -q "$state" "${REPO_ROOT}/$f"
      [ "$status" -eq 0 ]
    done
  done
}

# ── Capability-authority table — six rows, deploy never-grantable ────────────

@test "capability-authority schema requires the six rows" {
  if ! command -v jq >/dev/null 2>&1; then skip "jq not available"; fi
  run jq -e '.properties.rows.required | sort == ["deploy","exec","network","read","secrets","write"]' \
    "${REPO_ROOT}/schemas/capability-authority.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

@test "each authority row carries default and escalation columns" {
  if ! command -v jq >/dev/null 2>&1; then skip "jq not available"; fi
  run jq -e '(."$defs".row.required | sort) == ["default","escalation"]' \
    "${REPO_ROOT}/schemas/capability-authority.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

@test "SPEC.md declares deploy never-grantable" {
  run grep -qi 'never-grantable' "${REPO_ROOT}/SPEC.md"
  [ "$status" -eq 0 ]
}

# ── Bounded loop budget — time / turns / tokens in TaskState ──────────────────

@test "taskstate budget requires time, turns, tokens" {
  if ! command -v jq >/dev/null 2>&1; then skip "jq not available"; fi
  run jq -e '.properties.budget.required | sort == ["time","tokens","turns"]' \
    "${REPO_ROOT}/schemas/taskstate.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

# ── Delegation contract — the five typed fields + evidence_of_boundary ────────

@test "handoff-request carries the five delegation fields plus evidence_of_boundary" {
  if ! command -v jq >/dev/null 2>&1; then skip "jq not available"; fi
  run jq -e '.required as $r | (["objective","scope","deliverables","evidence_required","stop_conditions","evidence_of_boundary"] | all(. as $f | $r | index($f)))' \
    "${REPO_ROOT}/schemas/handoff-request.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

# ── Externalized verification (AC-E05) ────────────────────────────────────────

@test "SPEC.md names external oracles as the result gate (never self-report)" {
  run grep -qiE 'test|parser|diff|env-feedback' "${REPO_ROOT}/SPEC.md"
  [ "$status" -eq 0 ]
  run grep -qi 'never self-report\|never self-critique\|never LLM-as-judge' "${REPO_ROOT}/SPEC.md"
  [ "$status" -eq 0 ]
}

# ── Worker, never router (AC-E09) ─────────────────────────────────────────────

@test "PERSONA.md declares downstream: [] (worker-never-router)" {
  run grep -q 'downstream: \[\]' "${REPO_ROOT}/PERSONA.md"
  [ "$status" -eq 0 ]
}

@test "SPEC.md forbids DELEGATE/DECIDE/CRITIQUE/REQUEST and spawn" {
  run grep -qi 'never emit .*DELEGATE\|NEVER emit' "${REPO_ROOT}/SPEC.md"
  [ "$status" -eq 0 ]
}

# ── PERSONA.md references exactly the five installed skills ─────────────────────

@test "PERSONA.md references all five skills and no legacy spec basename" {
  for s in verify-incoming gauge grind attest esl-hop; do
    run grep -q "skills/${s}/SKILL.md" "${REPO_ROOT}/PERSONA.md"
    [ "$status" -eq 0 ]
  done
  run grep -qi 'gilgamesh\.md' "${REPO_ROOT}/PERSONA.md"
  [ "$status" -ne 0 ]
}

# ── Sample manifest validates against the vendored EIIS schema ───────────────
