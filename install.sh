#!/usr/bin/env bash
set -euo pipefail

# landing skill installer
# Copies the skill files into the target tool's skill directory.
#
# Local mode:  ./install.sh [OPTIONS]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/landing/main/install.sh)

REPO_URL="${LANDING_REPO_URL:-https://github.com/kiso-run/landing.git}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
CLEANUP_DIR=""

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Install the `landing` skill into ~/.claude/skills/landing/.

OPTIONS:
  --force   Overwrite existing installation without prompting
  --help    Show this help message

REMOTE INSTALL (no clone needed):
  bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/landing/main/install.sh)

ENVIRONMENT:
  LANDING_REPO_URL   Override the repo URL used in remote mode
                     (default: https://github.com/kiso-run/landing.git)
EOF
}

# --- Parse arguments ---

for arg in "$@"; do
    case "$arg" in
        --force)  FORCE=true ;;
        --help)   usage; exit 0 ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# --- Detect local vs remote mode ---

if [ -d "$SCRIPT_DIR/skill" ]; then
    SRC_ROOT="$SCRIPT_DIR"
else
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is required for remote install." >&2
        exit 1
    fi
    CLEANUP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/landing-install-XXXXXX")"
    echo "Cloning landing into temporary directory..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLEANUP_DIR/repo"
    SRC_ROOT="$CLEANUP_DIR/repo"
    if [ ! -d "$SRC_ROOT/skill" ]; then
        echo "Error: skill/ directory not found in the cloned repo." >&2
        exit 1
    fi
fi

SRC="$SRC_ROOT/skill"
DEST="$HOME/.claude/skills/landing"

# --- Confirm overwrite if not --force ---

if [ -d "$DEST" ] && [ "$FORCE" != true ]; then
    printf "landing skill already exists at %s\nOverwrite? [y/N] " "$DEST"
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# --- Install ---

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -r "$SRC" "$DEST"

echo ""
echo "Installed landing skill → $DEST"
echo ""
echo "Pipeline (run in the order below, from the project directory):"
echo "  /landing vp    — discover positioning; writes value-proposition.md"
echo "  /landing copy  — turn it into Dunford-style copy; writes copywriting.md"
echo "  /landing html  — assemble a standalone landing page; writes index.html"
echo ""
echo "Run /landing without arguments to see the menu."
