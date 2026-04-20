#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies the skill source tree layout (M1).
# Run: bash tests/test_structure.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$REPO_ROOT/skill"
PASS=0
FAIL=0

assert_dir() {
    local path="$1"
    if [ -d "$path" ]; then
        echo "  PASS: dir $path"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: dir $path"
        FAIL=$((FAIL + 1))
    fi
}

assert_file() {
    local path="$1"
    if [ -f "$path" ]; then
        echo "  PASS: file $path"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: file $path"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M1: Structure ==="

# Top-level
assert_dir  "$SKILL"
assert_file "$SKILL/SKILL.md"

# vp/
assert_dir  "$SKILL/vp"
assert_file "$SKILL/vp/prompt.md"

# copy/
assert_dir  "$SKILL/copy"
assert_file "$SKILL/copy/prompt.md"
assert_file "$SKILL/copy/questions.md"
assert_file "$SKILL/copy/template.md"

# html/
assert_dir  "$SKILL/html"
assert_file "$SKILL/html/prompt.md"
assert_file "$SKILL/html/mapping.md"
assert_file "$SKILL/html/rules.md"
assert_file "$SKILL/html/skeleton.html"

# html/snippets/
assert_dir  "$SKILL/html/snippets"
for name in nav hero problem features stats testimonial integration faq conversion final-cta footer; do
    assert_file "$SKILL/html/snippets/$name.html"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
