/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI should close
#define UI_CLOSE -1

/// Maximum number of windows that can be suspended/reused
#define TGUI_WINDOW_SOFT_LIMIT 5
/// Maximum number of open windows
#define TGUI_WINDOW_HARD_LIMIT 9

/// Maximum ping timeout before we close the window as a zombie
#define TGUI_PING_TIMEOUT (4 SECONDS)
/// Rate-limit full updates to prevent DoS
#define TGUI_REFRESH_FULL_UPDATE_COOLDOWN (1 SECONDS)

/// Window does not exist
#define TGUI_WINDOW_CLOSED 0
/// Window was just opened and is still loading
#define TGUI_WINDOW_LOADING 1
/// Window is free and ready to receive data
#define TGUI_WINDOW_READY 2

/// Get a window id based on a pool index
#define TGUI_WINDOW_ID(index) "tgui-window-[index]"
/// Get a pool index from a window id
#define TGUI_WINDOW_INDEX(window_id) text2num(copytext(window_id, 13))

/// Creates a URL-encoded JSON message packet for output()
#define TGUI_CREATE_MESSAGE(type, payload) ( \
	"%7b%22type%22%3a%22[type]%22%2c%22payload%22%3a[url_encode(json_encode(payload))]%7d" \
)
