#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DME="${DME:-baystation12}"
PORT="${PORT:-5000}"
TRUSTED="${TRUSTED:-1}"

source "$SCRIPT_DIR/wine_byond.sh"
log_to "$SCRIPT_DIR/host.log"

echo "========================================================"
echo " Baystation12SOYH Host Script (Wine / DreamDaemon)"
echo "========================================================"

if ! find_byond_bin; then
	echo "[ERROR] DreamDaemon (dreamdaemon.exe) not found."
	echo "        Set WINEPREFIX to your BYOND Wine prefix, e.g.:"
	echo "        WINEPREFIX=\$HOME/Games/byond tools/build/host.sh"
	exit 1
fi

DMB_PATH="$REPO_ROOT/$DME.dmb"
if [[ ! -f "$DMB_PATH" ]]; then
	echo "[ERROR] $DMB_PATH not found. Run tools/build/build.sh first."
	exit 1
fi

ARGS=("$DME.dmb" "$PORT")
[[ "$TRUSTED" == "1" ]] && ARGS+=("-trusted")
ARGS+=("$@")

echo "Using DreamDaemon: $BYOND_BIN/dreamdaemon.exe"
echo "Using Wine prefix: $BYOND_WINEPREFIX"
echo "Hosting $DME.dmb on port $PORT"
echo "--------------------------------------------------------"

CLEANED_UP=0
cleanup() {
	[[ $CLEANED_UP == 1 ]] && return
	CLEANED_UP=1
	trap - ERR
	echo
	echo "Stopping DreamDaemon..."
	pkill -x "dreamdaemon.exe" 2>/dev/null || true
	sleep 1
	pkill -9 -x "dreamdaemon.exe" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

cd "$REPO_ROOT"
WINEPREFIX="$BYOND_WINEPREFIX" "$WINE" "$BYOND_BIN/dreamdaemon.exe" "${ARGS[@]}" &
WINE_PID=$!
wait "$WINE_PID" || true
