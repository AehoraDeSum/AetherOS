#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this preview as root from the USB shell." >&2
    exit 1
fi

for app in weston seatd; do
    command -v "$app" >/dev/null 2>&1 || {
        echo "Missing $app. Install the preview runtime first." >&2
        exit 1
    }
done
QMLSCENE=/usr/lib/qt6/bin/qmlscene
[ -x "$QMLSCENE" ] || { echo "Missing $QMLSCENE. Install the Qt Quick runtime first." >&2; exit 1; }

QML=/opt/aetheros/shell/Main.qml
[ -r "$QML" ] || { echo "Missing $QML" >&2; exit 1; }

export XDG_RUNTIME_DIR=/run/user/0
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

seatd -g video >/tmp/aether-seatd.log 2>&1 &
seatd_pid=$!
weston_pid=

stop_preview() {
    if [ -n "$weston_pid" ]; then
        kill "$weston_pid" 2>/dev/null || true
        wait "$weston_pid" 2>/dev/null || true
    fi
    kill "$seatd_pid" 2>/dev/null || true
}
trap stop_preview EXIT INT TERM

sleep 1
socket_name=wayland-aetheros
LIBSEAT_BACKEND=seatd weston --backend=drm --renderer=pixman \
    --socket="$socket_name" \
    --log=/tmp/aether-weston.log >/dev/null 2>&1 &
weston_pid=$!

socket="$XDG_RUNTIME_DIR/$socket_name"
tries=0
while [ ! -e "$socket" ] && [ "$tries" -lt 20 ]; do
    kill -0 "$weston_pid" 2>/dev/null || break
    sleep 1
    tries=$((tries + 1))
done

if [ ! -S "$socket" ]; then
    echo "Weston did not start. Logs: /tmp/aether-weston.log and /tmp/aether-seatd.log" >&2
    exit 1
fi

export WAYLAND_DISPLAY="$socket_name"
export QT_QPA_PLATFORM=wayland
export QT_QUICK_BACKEND=software
"$QMLSCENE" "$QML"
