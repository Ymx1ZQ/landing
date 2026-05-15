#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies SKILL.md contracts (M2).
# Run: bash tests/test_skill.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_MD="$REPO_ROOT/skill/SKILL.md"
PASS=0
FAIL=0

assert_grep() {
    local pattern="$1" label="$2" file="${3:-$SKILL_MD}"
    if grep -qE "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

assert_frontmatter() {
    # Must start with --- and contain name: and description: inside first block
    local first_fence second_fence
    first_fence=$(head -1 "$SKILL_MD")
    if [ "$first_fence" != "---" ]; then
        echo "  FAIL: frontmatter must start with --- on line 1"
        FAIL=$((FAIL + 1))
        return
    fi
    echo "  PASS: frontmatter opens with ---"
    PASS=$((PASS + 1))

    # find closing --- line number (first occurrence after line 1)
    second_fence=$(awk 'NR>1 && /^---$/{print NR; exit}' "$SKILL_MD")
    if [ -z "$second_fence" ]; then
        echo "  FAIL: frontmatter has no closing ---"
        FAIL=$((FAIL + 1))
        return
    fi
    echo "  PASS: frontmatter closes with ---"
    PASS=$((PASS + 1))

    local fm
    fm=$(sed -n "2,$((second_fence - 1))p" "$SKILL_MD")
    if echo "$fm" | grep -qE '^name:[[:space:]]*landing[[:space:]]*$'; then
        echo "  PASS: frontmatter declares name: landing"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: frontmatter missing 'name: landing'"
        FAIL=$((FAIL + 1))
    fi
    if echo "$fm" | grep -qE '^description:[[:space:]]*.+'; then
        echo "  PASS: frontmatter declares non-empty description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: frontmatter missing description"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M2: SKILL.md ==="

if [ ! -s "$SKILL_MD" ]; then
    echo "  FAIL: SKILL.md is empty or missing"
    FAIL=$((FAIL + 1))
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

assert_frontmatter

# Language rules
assert_grep '[Ll]anguage' "body mentions language"
assert_grep '[Cc]hat' "body mentions chat language rule"
assert_grep '[Aa]rtifact' "body mentions artifact language rule"
assert_grep '[Ee]nglish' "body mentions English default"

# Routing — each subcommand must be explicitly routed
assert_grep '\bvp\b' "routes vp"
assert_grep '\bcopy\b' "routes copy"
assert_grep '\bhtml\b' "routes html"
assert_grep '\breview\b' "routes review (M13)"
assert_grep 'vp/prompt\.md' "points to vp/prompt.md"
assert_grep 'copy/prompt\.md' "points to copy/prompt.md"
assert_grep 'html/prompt\.md' "points to html/prompt.md"
assert_grep 'review/prompt\.md' "points to review/prompt.md (M13)"

# Fallback for missing / unknown arg
assert_grep '[Nn]o arg|no argument|missing|unknown|menu' "handles missing/unknown arg"

# Pipeline artifact filenames
assert_grep 'value-proposition\.md' "mentions value-proposition.md artifact"
assert_grep 'copywriting\.md' "mentions copywriting.md artifact"
assert_grep 'index\.html' "mentions index.html artifact"
assert_grep 'copy-review\.md' "mentions copy-review.md artifact (M13)"

# CWD reference
assert_grep '[Cc]urrent working directory|CWD|cwd' "references CWD for artifacts"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
