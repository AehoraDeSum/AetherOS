#!/usr/bin/env bash
set -euo pipefail

# Build a separate Alpine RAM root with XFCE on Xorg's simple framebuffer
# driver. This leaves Cascadia's regular root archive and the phone's storage
# untouched.
CASCADIA_A13="${CASCADIA_A13:-/Volumes/swxc/aetheros/Project-Cascadia/devices/a13}"
BASE_ROOTFS="$CASCADIA_A13/build/alpine-a13.tar.gz"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)/build"
STAGE_DIR="$CASCADIA_A13/build/aether-live-desktop"
ALPINE_VER="${ALPINE_VER:-3.24}"

[[ -f "$BASE_ROOTFS" ]] || {
    echo "Missing Cascadia RAM root filesystem: $BASE_ROOTFS" >&2
    exit 1
}
mkdir -p "$OUTPUT_DIR" "$STAGE_DIR/dist" "$STAGE_DIR/etc/X11/xorg.conf.d" \
    "$STAGE_DIR/etc/xdg/autostart" \
    "$STAGE_DIR/root/.config/xfce4/xfconf/xfce-perchannel-xml" \
    "$STAGE_DIR/root/.vnc" \
    "$STAGE_DIR/usr/local/bin"

cat > "$STAGE_DIR/etc/X11/xorg.conf.d/99-aether-fbdev.conf" <<'EOF'
Section "Device"
    Identifier "Aether simpledrm framebuffer"
    Driver     "fbdev"
    Option     "fbdev" "/dev/fb0"
EndSection

Section "Screen"
    Identifier "Aether framebuffer screen"
    Device     "Aether simpledrm framebuffer"
EndSection
EOF

cat > "$STAGE_DIR/etc/xdg/autostart/aether-onscreen-keyboard.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Aether On-screen Keyboard
Exec=svkbd-mobile-intl -d -H 20 -fn "DejaVu Sans:size=13"
OnlyShowIn=XFCE;
NoDisplay=true
EOF

cat > "$STAGE_DIR/root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitordefault" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="0"/>
          <property name="rgba1" type="array">
            <value type="double" value="0.08"/>
            <value type="double" value="0.12"/>
            <value type="double" value="0.18"/>
            <value type="double" value="1"/>
          </property>
        </property>
      </property>
      <property name="monitorNone-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="0"/>
          <property name="rgba1" type="array">
            <value type="double" value="0.08"/>
            <value type="double" value="0.12"/>
            <value type="double" value="0.18"/>
            <value type="double" value="1"/>
          </property>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

cat > "$STAGE_DIR/root/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="thunar" version="1.0">
  <property name="misc-single-click" type="bool" value="true"/>
</channel>
EOF

python3 - "$STAGE_DIR/root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
data = path.read_text()
needle = "</channel>"
addition = '''  <property name="desktop-icons" type="empty">
    <property name="single-click" type="bool" value="true"/>
  </property>
'''
if needle not in data:
    raise SystemExit("could not add single-click setting to XFCE desktop config")
path.write_text(data.replace(needle, addition + needle, 1))
PY

cat > "$STAGE_DIR/usr/local/bin/aether-live-desktop" <<'EOF'
#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this from the root Linux serial shell." >&2
    exit 1
fi
# Cascadia's serial login may leave HOME unset; startx/xauth need it to create
# the X session authority file that x11vnc will later use.
export HOME=/root
if pidof Xorg >/dev/null 2>&1; then
    echo "Xorg is already running. Use aether-stop-desktop before retrying." >&2
    exit 1
fi

# The boot image may have started the framebuffer keyboard. Xorg owns the
# framebuffer while the desktop is active, so stop it before switching over.
pkill -x fbkeyboard 2>/dev/null || true

export XDG_RUNTIME_DIR=/tmp/xdg-0
mkdir -p "$XDG_RUNTIME_DIR" /run/dbus
chmod 700 "$XDG_RUNTIME_DIR"
if ! pidof dbus-daemon >/dev/null 2>&1; then
    dbus-uuidgen --ensure
    dbus-daemon --system
fi

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
setsid sh -c 'startxfce4 >/tmp/aether-xfce.log 2>&1' \
    </dev/null >/dev/null 2>&1 &
echo "$!" >/run/aether-live-desktop.pid
echo "XFCE is starting on the framebuffer. Wait about 20 seconds. Log: /tmp/aether-xfce.log"
EOF

cat > "$STAGE_DIR/usr/local/bin/aether-stop-desktop" <<'EOF'
#!/bin/sh
set -eu

if pidof xfce4-session >/dev/null 2>&1; then
    pkill -TERM -x xfce4-session
fi
sleep 2
if pidof Xorg >/dev/null 2>&1; then
    pkill -TERM -x Xorg
fi
rm -f /run/aether-live-desktop.pid
echo "Desktop stopped; the Linux framebuffer console is available again."
EOF

cat > "$STAGE_DIR/usr/local/bin/aether-vnc" <<'EOF'
#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this from the root Linux serial shell." >&2
    exit 1
fi
# The initramfs serial shell may leave HOME unset. The current Xorg session is
# started without an Xauthority file, so use /dev/null for local X access; VNC
# itself remains password protected and bound only to the USB ECM address.
export HOME=/root
if ! pidof Xorg >/dev/null 2>&1; then
    echo "Start the XFCE desktop first with aether-live-desktop." >&2
    exit 1
fi
PASSFILE=/root/.vnc/passwd
if [ ! -s "$PASSFILE" ]; then
    echo "Set a VNC password first: mkdir -p /root/.vnc && x11vnc -storepasswd /root/.vnc/passwd"
    exit 1
fi
if [ -s /run/aether-vnc.pid ] && kill -0 "$(cat /run/aether-vnc.pid)" 2>/dev/null; then
    echo "VNC is already running."
    exit 0
fi

# Bind only to Cascadia's USB Ethernet address, never to Wi-Fi or other LANs.
setsid x11vnc -display :0 -auth /dev/null -rfbauth "$PASSFILE" \
    -listen 172.16.42.1 -rfbport 5900 -forever -shared -noxdamage -repeat \
    >/tmp/aether-vnc.log 2>&1 </dev/null &
echo "$!" >/run/aether-vnc.pid
echo "VNC is starting on 172.16.42.1:5900 over USB only. Log: /tmp/aether-vnc.log"
EOF

cat > "$STAGE_DIR/usr/local/bin/aether-stop-vnc" <<'EOF'
#!/bin/sh
set -eu
pkill -TERM -x x11vnc 2>/dev/null || true
rm -f /run/aether-vnc.pid
echo "VNC stopped."
EOF

chmod 755 "$STAGE_DIR/usr/local/bin/aether-live-desktop" \
    "$STAGE_DIR/usr/local/bin/aether-stop-desktop" \
    "$STAGE_DIR/usr/local/bin/aether-vnc" \
    "$STAGE_DIR/usr/local/bin/aether-stop-vnc"

docker run --rm --platform linux/arm64 \
    -v "$BASE_ROOTFS:/base/alpine-a13.tar.gz:ro" \
    -v "$STAGE_DIR:/stage:ro" \
    -v "$STAGE_DIR/dist:/dist" \
    "alpine:$ALPINE_VER" sh -euxc '
        mkdir -p /r
        tar -xzf /base/alpine-a13.tar.gz -C /r
        apk --root /r --keys-dir /etc/apk/keys \
            --repositories-file /r/etc/apk/repositories add \
            xorg-server xf86-video-fbdev xf86-input-libinput xinit \
            xfce4 xfce4-terminal svkbd touchegg dbus dbus-x11 xrandr xinput x11vnc
        cp -R /stage/etc/. /r/etc/
        cp -R /stage/usr/. /r/usr/
        mkdir -p /r/root/.config/xfce4/xfconf/xfce-perchannel-xml
        cp -R /stage/root/.config/. /r/root/.config/
        mkdir -p /r/root/.vnc
        tar -C /r -czf /dist/alpine-a13-live-desktop.tar.gz .
        chown "$(id -u):$(id -g)" /dist/alpine-a13-live-desktop.tar.gz
    '

cp "$STAGE_DIR/dist/alpine-a13-live-desktop.tar.gz" "$OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/alpine-a13-live-desktop.tar.gz"
