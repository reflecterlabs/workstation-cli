#!/usr/bin/env bash
#
# Workstation CLI Test Suite v3.0
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test utilities
pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((TESTS_PASSED++)) || true
}

fail() {
  echo -e "${RED}✗${NC} $1"
  ((TESTS_FAILED++)) || true
}

test_header() {
  echo ""
  echo -e "${BLUE}=== $1 ===${NC}"
}

# Setup
TEST_DIR=$(mktemp -d)
export WORKSTATION_ROOT="$TEST_DIR/workstation"
export OPENCLAW_HOME="$TEST_DIR/openclaw"
export PATH="$(dirname "$0")/../bin:$PATH"

mkdir -p "$WORKSTATION_ROOT" "$OPENCLAW_HOME"

# Cleanup
cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# ============================================================================
# TESTS
# ============================================================================

test_version() {
  test_header "Version Command"
  
  if workstation version 2>/dev/null | grep -q "Workstation CLI"; then
    pass "version command works"
  else
    fail "version command failed"
  fi
}

test_doctor() {
  test_header "Doctor Command"
  
  if workstation doctor 2>&1 | grep -q "Checking"; then
    pass "doctor command runs"
  else
    fail "doctor command failed"
  fi
}

test_init() {
  test_header "Init Command"
  
  local org_name="TestOrg$$"
  
  if workstation init "$org_name" >/dev/null 2>&1; then
    if [[ -d "$WORKSTATION_ROOT/${org_name}-SSOT" ]]; then
      pass "organization directory created"
    else
      fail "organization directory not found"
    fi
    
    if [[ -f "$WORKSTATION_ROOT/${org_name}-SSOT/workstation.json" ]]; then
      pass "workstation.json created"
    else
      fail "workstation.json not found"
    fi
    
    if [[ -d "$WORKSTATION_ROOT/${org_name}-SSOT/.git" ]]; then
      pass "git repository initialized"
    else
      fail "git repository not initialized"
    fi
  else
    fail "init command failed"
  fi
}

test_seat_create() {
  test_header "Seat Create Command"
  
  local org_name="TestOrg$$"
  local seat_id="testseat"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  if workstation seat create "$seat_id" --role "testing" >/dev/null 2>&1; then
    if [[ -d "$OPENCLAW_HOME/workspace-$seat_id" ]]; then
      pass "workspace directory created"
    else
      fail "workspace directory not found"
    fi
    
    if [[ -f "$OPENCLAW_HOME/workspace-$seat_id/BOOTSTRAP.md" ]]; then
      pass "BOOTSTRAP.md copied"
    else
      fail "BOOTSTRAP.md not found"
    fi
  else
    fail "seat create command failed"
  fi
}

test_seat_activate() {
  test_header "Seat Activate Command"
  
  local org_name="TestOrg$$"
  local seat_id="testseat"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  if workstation seat activate "$seat_id" >/dev/null 2>&1; then
    if [[ -L "$OPENCLAW_HOME/workspace" ]]; then
      pass "workspace symlink created"
    else
      fail "workspace symlink not found"
    fi
  else
    fail "seat activate command failed"
  fi
}

test_claim() {
  test_header "Claim Command"
  
  local org_name="TestOrg$$"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  # Create a test file
  touch testfile.txt
  
  if workstation claim testfile.txt --reason "Testing" >/dev/null 2>&1; then
    pass "claim created successfully"
    
    if workstation claims 2>/dev/null | grep -q "testfile.txt"; then
      pass "claim appears in claims list"
    else
      fail "claim not in claims list"
    fi
    
    if workstation release testfile.txt >/dev/null 2>&1; then
      pass "claim released successfully"
    else
      fail "release command failed"
    fi
  else
    fail "claim command failed"
  fi
}

test_validation() {
  test_header "Input Validation"
  
  local org_name="TestOrg$$"
  
  # Test invalid characters
  if ! workstation init "invalid/name" 2>/dev/null; then
    pass "rejects invalid org name with slash"
  else
    fail "should reject invalid org name"
  fi
  
  # Test empty name
  if ! workstation init "" 2>/dev/null; then
    pass "rejects empty org name"
  else
    fail "should reject empty org name"
  fi
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  # Test invalid seat name
  if ! workstation seat create "Invalid Seat" 2>/dev/null; then
    pass "rejects invalid seat name with space"
  else
    fail "should reject invalid seat name"
  fi
}

test_json_validation() {
  test_header "JSON Validation"
  
  local org_name="TestOrg$$"
  
  if jq empty "$WORKSTATION_ROOT/${org_name}-SSOT/workstation.json" 2>/dev/null; then
    pass "workstation.json is valid JSON"
  else
    fail "workstation.json is invalid"
  fi
}

# ============================================================================
# MAIN
# ============================================================================

echo "======================================"
echo "Workstation CLI Test Suite"
echo "======================================"
echo ""
echo "Test Directory: $TEST_DIR"
echo ""

# Run tests
test_version
test_doctor
test_init
test_seat_create
test_seat_activate
test_claim
test_validation
test_json_validation

# Summary
echo ""
echo "======================================"
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"
echo "======================================"

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
else
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
fi
