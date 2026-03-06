#!/usr/bin/env bash
#
# Workstation CLI Test Suite
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Cleanup on exit
cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# ============================================================================
# TESTS
# ============================================================================

test_version() {
  test_header "Version Command"
  
  if workstation version | grep -q "Workstation CLI"; then
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
  
  if workstation init "$org_name" > /dev/null 2>&1; then
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
  local seat_id="test-seat"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  if workstation seat create "$seat_id" --role "testing" > /dev/null 2>&1; then
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
    
    if [[ -f "$WORKSTATION_ROOT/${org_name}-SSOT/_seats/$seat_id" ]]; then
      pass "backup directory created"
    else
      fail "backup directory not found"
    fi
  else
    fail "seat create command failed"
  fi
}

test_seat_activate() {
  test_header "Seat Activate Command"
  
  local org_name="TestOrg$$"
  local seat_id="test-seat"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  if workstation seat activate "$seat_id" > /dev/null 2>&1; then
    if [[ -L "$OPENCLAW_HOME/workspace" ]]; then
      pass "workspace symlink created"
    else
      fail "workspace symlink not found"
    fi
    
    local target
    target=$(readlink "$OPENCLAW_HOME/workspace")
    if [[ "$target" == *"workspace-$seat_id"* ]]; then
      pass "symlink points to correct workspace"
    else
      fail "symlink points to wrong location"
    fi
  else
    fail "seat activate command failed"
  fi
}

test_kb_add() {
  test_header "KB Add Command"
  
  local org_name="TestOrg$$"
  
  cd "$WORKSTATION_ROOT/${org_name}-SSOT"
  
  # Create a mock KB repo
  local kb_repo="$TEST_DIR/mock-kb"
  mkdir -p "$kb_repo"
  git init "$kb_repo" > /dev/null 2>&1
  echo "# Mock KB" > "$kb_repo/README.md"
  git -C "$kb_repo" add . > /dev/null 2>&1
  git -C "$kb_repo" commit -m "Initial" > /dev/null 2>&1
  
  if workstation kb add "KB-Mock" "$kb_repo" > /dev/null 2>&1; then
    if [[ -d "$WORKSTATION_ROOT/${org_name}-SSOT/KBs/KB-Mock" ]]; then
      pass "KB directory created"
    else
      fail "KB directory not found"
    fi
    
    if [[ -f "$WORKSTATION_ROOT/${org_name}-SSOT/KBs/KB-Mock/README.md" ]]; then
      pass "KB content cloned"
    else
      fail "KB content not found"
    fi
  else
    fail "kb add command failed"
  fi
}

test_validation() {
  test_header "JSON Validation"
  
  local org_name="TestOrg$$"
  
  if jq empty "$WORKSTATION_ROOT/${org_name}-SSOT/workstation.json" 2>&1; then
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
test_kb_add
test_validation

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
