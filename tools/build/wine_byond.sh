: "${WINE:=wine}"
: "${LUTRIS_GAME_URI:=lutris:rungameid/1}"

ensure_byond_launcher_running() {
	if pgrep -f "byond\.exe" >/dev/null 2>&1; then
		return 0
	fi
	if ! command -v lutris >/dev/null 2>&1; then
		return 1
	fi
	echo "BYOND launcher not running, starting it via Lutris..."
	nohup env LUTRIS_SKIP_INIT=1 lutris "$LUTRIS_GAME_URI" >/dev/null 2>&1 &
	disown
	sleep 2
}

log_to() {
	BUILD_LOG_FILE="$1"
	exec > >(tee "$BUILD_LOG_FILE") 2>&1
	trap 'ec=$?; echo; echo "[ERROR] $(basename "$0") failed at line $LINENO (exit $ec): $BASH_COMMAND" >&2; echo "Full log saved to: $BUILD_LOG_FILE" >&2' ERR
}

find_bun() {
	if command -v bun >/dev/null 2>&1; then
		BUN="$(command -v bun)"
		return 0
	fi
	local candidate
	for candidate in \
		"$HOME/.bun/bin/bun" \
		"$HOME/.local/bin/bun" \
		"/usr/bin/bun" \
		"/usr/local/bin/bun"
	do
		if [[ -x "$candidate" ]]; then
			BUN="$candidate"
			return 0
		fi
	done
	return 1
}

find_byond_bin() {
	local candidates=()
	[[ -n "${WINEPREFIX:-}" ]] && candidates+=("$WINEPREFIX")
	candidates+=("$HOME/Games/byond" "$HOME/.wine" "$HOME/.byond")

	local prefix bindir
	for prefix in "${candidates[@]}"; do
		for bindir in \
			"$prefix/drive_c/Program Files (x86)/BYOND/bin" \
			"$prefix/drive_c/Program Files/BYOND/bin"
		do
			if [[ -f "$bindir/dm.exe" ]]; then
				BYOND_WINEPREFIX="$prefix"
				BYOND_BIN="$bindir"
				return 0
			fi
		done
	done
	return 1
}
