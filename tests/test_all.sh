#!/usr/bin/env bash
set -euo pipefail

# Run all test suites sequentially. Exits non-zero on the first failure.

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run() {
    local script="$1"
    echo ""
    echo "┄┄┄ $script ┄┄┄"
    bash "$TESTS_DIR/$script"
}

run test_structure.sh
run test_skill.sh
run test_vp.sh
run test_copy.sh
run test_html.sh
run test_install.sh

echo ""
echo "✅ All suites green."
