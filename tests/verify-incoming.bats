#!/usr/bin/env bats
# tests/verify-incoming.bats — blocking, symmetric verify-incoming gate (ECL §6.2.2)
#
# Asserts:
#   1. skills/verify-incoming.md exists and declares BLOCKING posture.
#   2. It does NOT declare warn-only / "process anyway".
#   3. install.sh (non-interactive) installs skills/verify-incoming.md into the target.
#   4. install.manifest.json records skills/verify-incoming.md (files_written + skills[]).
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

@test "skills/verify-incoming.md exists in the repo" {
  [ -f "${REPO_ROOT}/skills/verify-incoming.md" ]
}

@test "skills/verify-incoming.md declares BLOCKING posture" {
  run grep -qiE 'REFUSE|SHALL NOT|blocking' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -eq 0 ]
}

@test "skills/verify-incoming.md contains 'Do not process' language" {
  run grep -qiE 'Do not process' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -eq 0 ]
}

@test "skills/verify-incoming.md does NOT declare warn-only posture as current behaviour" {
  run grep -qiE 'always processes?|shall process|must process|proceed.*anyway|process.*despite' \
    "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -ne 0 ]
}

@test "skills/verify-incoming.md does NOT contain 'process the payload anyway'" {
  run grep -qi 'process the payload anyway' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -ne 0 ]
}

@test "skills/verify-incoming.md lists both inbound senders" {
  for sender in orchestrator human; do
    run grep -qi "$sender" "${REPO_ROOT}/skills/verify-incoming.md"
    [ "$status" -eq 0 ]
  done
}

@test "skills/verify-incoming.md lists all 8 failure codes" {
  for code in INTEGRITY_MISMATCH UNVERIFIED SCHEMA_INVALID UNDECLARED_EDGE \
              PERFORMATIVE_NOT_ALLOWED ARTIFACT_KIND_NOT_ALLOWED \
              CONTEXT_OVER_BUDGET MISSING_REQUIRED_SECTION; do
    run grep -q "$code" "${REPO_ROOT}/skills/verify-incoming.md"
    [ "$status" -eq 0 ]
  done
}

@test "skills/verify-incoming.md has canonical EIIS skill frontmatter" {
  run grep -q '^name: gilgamesh-verify-incoming' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -eq 0 ]
  run grep -q '^description:' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$status" -eq 0 ]
}

# ── Version assertions ────────────────────────────────────────────────────────

@test "ECL_VERSION file exists and contains 2.0" {
  [ -f "${REPO_ROOT}/ECL_VERSION" ]
  local ver
  ver="$(tr -d '[:space:]' < "${REPO_ROOT}/ECL_VERSION")"
  [ "$ver" = "2.0" ]
}

@test "EIIS_VERSION file exists and contains 1.4" {
  [ -f "${REPO_ROOT}/EIIS_VERSION" ]
  local ver
  ver="$(tr -d '[:space:]' < "${REPO_ROOT}/EIIS_VERSION")"
  [ "$ver" = "1.4" ]
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

@test "install.sh exits 0 with --hosts none" {
  run_install "${INSTALL_TARGET}"
  [ "$INSTALL_STATUS" -eq 0 ]
}

@test "install.sh writes skills/verify-incoming.md into target" {
  run_install "${INSTALL_TARGET}"
  [ -f "${INSTALL_TARGET}/skills/verify-incoming.md" ]
}

@test "installed skills/verify-incoming.md content matches source" {
  run_install "${INSTALL_TARGET}"
  run diff "${REPO_ROOT}/skills/verify-incoming.md" "${INSTALL_TARGET}/skills/verify-incoming.md"
  [ "$status" -eq 0 ]
}

# ── Manifest assertions ───────────────────────────────────────────────────────

@test "install.manifest.json is generated" {
  run_install "${INSTALL_TARGET}"
  [ -f "${INSTALL_TARGET}/install.manifest.json" ]
}

@test "install.manifest.json records skills/verify-incoming.md in files_written" {
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not available"
  fi
  run_install "${INSTALL_TARGET}"
  run jq -e '[.files_written[] | select(.path == "skills/verify-incoming.md")] | length > 0' \
    "${INSTALL_TARGET}/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

@test "install.manifest.json records verify-incoming in skills[]" {
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not available"
  fi
  run_install "${INSTALL_TARGET}"
  run jq -e '[.skills[] | select(.name == "verify-incoming")] | length > 0' \
    "${INSTALL_TARGET}/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "true" ]]
}

@test "manifest files_written[verify-incoming].sha256 matches installed file" {
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not available"
  fi
  run_install "${INSTALL_TARGET}"
  local declared_sha actual_sha
  declared_sha="$(jq -r '[.files_written[] | select(.path == "skills/verify-incoming.md")][0].sha256' "${INSTALL_TARGET}/install.manifest.json")"
  actual_sha="$(sha256_of "${INSTALL_TARGET}/skills/verify-incoming.md")"
  [[ "$declared_sha" == "$actual_sha" ]]
}
