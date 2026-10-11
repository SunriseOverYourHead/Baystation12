#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/wine_byond.sh"
log_to "$SCRIPT_DIR/build_and_host.log"

echo "========================================================"
echo " Baystation12SOYH Build & Host Script (Linux / Wine)"
echo "========================================================"

ensure_byond_launcher_running

"$SCRIPT_DIR/build.sh" "$@"
echo
"$SCRIPT_DIR/host.sh"
