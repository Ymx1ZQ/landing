#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies install.sh (M6).
# Run: bash tests/test_install.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
PASS=0
FAIL=0

# --- helpers ---

setup_fake_home() { mktemp -d; }
cleanup()         { rm -rf "$1"; }

create_snapshot_repo() {
    local snapshot_root snapshot_repo
    snapshot_root="$(mktemp -d)"
    snapshot_repo="$snapshot_root/repo"
    cp -R "$REPO_ROOT" "$snapshot_repo"
    rm -rf "$snapshot_repo/.git"
    (
        cd "$snapshot_repo"
        git init -q
        git config user.name "landing-test"
        git config user.email "landing-test@example.com"
        git add -A
        git commit -qm "snapshot"
    )
    echo "$snapshot_root"
}

assert_dir()   { [ -d "$1" ] && { echo "  PASS: dir $1";  PASS=$((PASS+1)); } || { echo "  FAIL: dir missing $1";  FAIL=$((FAIL+1)); }; }
assert_file()  { [ -f "$1" ] && { echo "  PASS: file $1"; PASS=$((PASS+1)); } || { echo "  FAIL: file missing $1"; FAIL=$((FAIL+1)); }; }
assert_equal() {
    local got="$1" want="$2" label="$3"
    if [ "$got" = "$want" ]; then echo "  PASS: $label"; PASS=$((PASS+1))
    else echo "  FAIL: $label (got='$got' want='$want')"; FAIL=$((FAIL+1)); fi
}

# --- tests ---

if [ ! -f "$INSTALL_SH" ]; then
    echo "  FAIL: install.sh not present"
    exit 1
fi

echo "=== T1: local install creates target tree ==="
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force >/dev/null
TARGET="$FAKE_HOME/.claude/skills/landing"
assert_dir  "$TARGET"
assert_file "$TARGET/SKILL.md"
assert_file "$TARGET/vp/prompt.md"
assert_file "$TARGET/copy/prompt.md"
assert_file "$TARGET/copy/questions.md"
assert_file "$TARGET/copy/template.md"
assert_file "$TARGET/html/prompt.md"
assert_file "$TARGET/html/mapping.md"
assert_file "$TARGET/html/rules.md"
assert_file "$TARGET/html/skeleton.html"
assert_file "$TARGET/review/prompt.md"
for name in nav hero problem features stats testimonial integration faq conversion final-cta footer; do
    assert_file "$TARGET/html/snippets/$name.html"
done
cleanup "$FAKE_HOME"

echo ""
echo "=== T2: --force overwrites existing target without prompt ==="
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force >/dev/null
# Put a stale file that should get removed by the overwrite
echo "stale" > "$FAKE_HOME/.claude/skills/landing/STALE.txt"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force >/dev/null
if [ -f "$FAKE_HOME/.claude/skills/landing/STALE.txt" ]; then
    echo "  FAIL: stale file survived --force overwrite"
    FAIL=$((FAIL+1))
else
    echo "  PASS: stale file removed on --force overwrite"
    PASS=$((PASS+1))
fi
assert_file "$FAKE_HOME/.claude/skills/landing/SKILL.md"
cleanup "$FAKE_HOME"

echo ""
echo "=== T3: --help prints usage and exits 0 ==="
HELP_OUT="$(bash "$INSTALL_SH" --help 2>&1)"
HELP_RC=$?
assert_equal "$HELP_RC" "0" "--help exit code is 0"
if echo "$HELP_OUT" | grep -qiE 'usage|options|--force|--help'; then
    echo "  PASS: --help output contains usage info"
    PASS=$((PASS+1))
else
    echo "  FAIL: --help output missing usage info"
    FAIL=$((FAIL+1))
fi

echo ""
echo "=== T4: remote mode clones and installs ==="
if ! command -v git >/dev/null; then
    echo "  SKIP: git not available"
else
    SNAPSHOT="$(create_snapshot_repo)"
    FAKE_HOME="$(setup_fake_home)"
    ISOLATED="$(mktemp -d)"
    cp "$INSTALL_SH" "$ISOLATED/install.sh"
    HOME="$FAKE_HOME" LANDING_REPO_URL="$SNAPSHOT/repo" bash "$ISOLATED/install.sh" --force >/dev/null
    assert_dir  "$FAKE_HOME/.claude/skills/landing"
    assert_file "$FAKE_HOME/.claude/skills/landing/SKILL.md"
    assert_file "$FAKE_HOME/.claude/skills/landing/html/skeleton.html"
    cleanup "$FAKE_HOME"
    cleanup "$ISOLATED"
    cleanup "$SNAPSHOT"
fi

echo ""
echo "=== T5: README.md present and mentions pipeline ==="
README="$REPO_ROOT/README.md"
if [ -f "$README" ]; then
    echo "  PASS: README.md exists"
    PASS=$((PASS+1))
    for term in 'vp' 'copy' 'html' 'value-proposition\.md' 'copywriting\.md' 'index\.html' 'install'; do
        if grep -qiE "$term" "$README"; then
            echo "  PASS: README mentions $term"
            PASS=$((PASS+1))
        else
            echo "  FAIL: README missing mention of $term"
            FAIL=$((FAIL+1))
        fi
    done
else
    echo "  FAIL: README.md missing"
    FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
