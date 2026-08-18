#!/usr/bin/env bats
# tests/verify-incoming.bats — blocking, symmetric verify-incoming gate (ECL §6.2.2)
#
# Asserts:
#   1. skills/verify-incoming/SKILL.md exists and declares BLOCKING posture.
#   2. It does NOT declare warn-only / "process anyway".
#   3. install.sh (non-interactive) installs skills/verify-incoming/SKILL.md into the target.
#   4. install.manifest.json records skills/verify-incoming/SKILL.md (files_written + skills[]).
#   5. Version files are correct (EIIS 1.4 / ECL 2.0).
#   6. The methodology schemas parse.

load helpers.bash

INSTALL_TARGET=""

setup() {
  INSTALL_TARGET="$(mktemp -d)"
}

teardown() {
  teardown_install
}

# ── Skill source file assertions ─────────────────────────────────────────────

@test "skills/verify-incoming/SKILL.md exists in the repo" {
  [ -f "${REPO_ROOT}/skills/verify-incoming/SKILL.md" ]
}

@test "skills/verify-incoming/SKILL.md declares BLOCKING posture" {
  run grep -qiE 'REFUSE|SHALL NOT|blocking' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -eq 0 ]
}

@test "skills/verify-incoming/SKILL.md contains 'Do not process' language" {
  run grep -qiE 'Do not process' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -eq 0 ]
}

@test "skills/verify-incoming/SKILL.md does NOT declare warn-only posture as current behaviour" {
  run grep -qiE 'always processes?|shall process|must process|proceed.*anyway|process.*despite' \
    "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -ne 0 ]
}

@test "skills/verify-incoming/SKILL.md does NOT contain 'process the payload anyway'" {
  run grep -qi 'process the payload anyway' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -ne 0 ]
}

@test "skills/verify-incoming/SKILL.md lists both inbound senders" {
  for sender in orchestrator human; do
    run grep -qi "$sender" "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
    [ "$status" -eq 0 ]
  done
}

@test "skills/verify-incoming/SKILL.md lists all 8 failure codes" {
  for code in INTEGRITY_MISMATCH UNVERIFIED SCHEMA_INVALID UNDECLARED_EDGE \
              PERFORMATIVE_NOT_ALLOWED ARTIFACT_KIND_NOT_ALLOWED \
              CONTEXT_OVER_BUDGET MISSING_REQUIRED_SECTION; do
    run grep -q "$code" "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
    [ "$status" -eq 0 ]
  done
}

@test "skills/verify-incoming/SKILL.md has canonical EIIS skill frontmatter" {
  run grep -q '^name: gilgamesh-verify-incoming' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -eq 0 ]
  run grep -q '^description:' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  [ "$status" -eq 0 ]
}

# ── Version assertions ────────────────────────────────────────────────────────

@test "ECL_VERSION file exists and contains 2.0" {
  [ -f "${REPO_ROOT}/ECL_VERSION" ]
  local ver
  ver="$(tr -d '[:space:]' < "${REPO_ROOT}/ECL_VERSION")"
  [ "$ver" = "2.0" ]
}


# ── Schema assertions ─────────────────────────────────────────────────────────

@test "methodology schemas pass jq empty" {
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not available"
  fi
  for s in taskstate.v1.json handoff-request.v1.json mission-contract.v1.json capability-authority.v1.json; do
    run jq empty "${REPO_ROOT}/schemas/${s}"
    [ "$status" -eq 0 ]
  done
}

# ── Install: exit code + file placement ──────────────────────────────────────



@test "installed skills/verify-incoming/SKILL.md content matches source" {
  run_install "${INSTALL_TARGET}"
  run diff "${REPO_ROOT}/skills/verify-incoming/SKILL.md" "${INSTALL_TARGET}/skills/verify-incoming/SKILL.md"
  [ "$status" -eq 0 ]
}

# ── Manifest assertions ───────────────────────────────────────────────────────
