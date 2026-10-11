#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DME="baystation12.dme"
SKIP_TGUI=0

for arg in "$@"; do
	[[ "$arg" == "--skip-tgui" ]] && SKIP_TGUI=1
done

source "$SCRIPT_DIR/wine_byond.sh"
log_to "$SCRIPT_DIR/build.log"

echo "========================================================"
echo " Baystation12SOYH Build Script (Linux)"
echo "========================================================"

if ! find_byond_bin; then
	echo "[ERROR] DreamMaker (dm.exe) not found."
	echo "        Set WINEPREFIX to your BYOND Wine prefix, e.g.:"
	echo "        WINEPREFIX=\$HOME/Games/byond tools/build/build.sh"
	exit 1
fi

echo "Using DreamMaker : $BYOND_BIN/dm.exe"
echo "Using Wine prefix: $BYOND_WINEPREFIX"
echo

if [[ $SKIP_TGUI -eq 0 ]]; then
	if ! find_bun; then
		echo "[ERROR] bun not found. Install from https://bun.sh, or pass --skip-tgui to reuse the existing tgui/public bundles."
		exit 1
	fi
	echo "Using bun        : $BUN"
	echo

	echo "[1/3] Installing TGUI dependencies..."
	echo "--------------------------------------------------------"
	(cd "$REPO_ROOT/tgui" && "$BUN" install --frozen-lockfile)
	echo "[1/3] Done."
	echo

	echo "[2/3] Building TGUI..."
	echo "--------------------------------------------------------"
	(cd "$REPO_ROOT/tgui" && "$BUN" run tgui:build)
	echo "[2/3] Done."
	echo
else
	echo "[1/3] Skipping TGUI install (--skip-tgui)."
	echo "[2/3] Skipping TGUI build (--skip-tgui)."
	echo
fi

echo "[3/3] Compiling $DME..."
echo "--------------------------------------------------------"
cd "$REPO_ROOT"
WINEPREFIX="$BYOND_WINEPREFIX" "$WINE" "$BYOND_BIN/dm.exe" "$DME"
echo "[3/3] Done."

echo
echo "========================================================"
echo " BUILD SUCCESSFUL"
echo "========================================================"
