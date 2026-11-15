#!/usr/bin/env bash
set -euo pipefail

# Build an optional RAM-root overlay on top of Cascadia's already working
# Alpine image. This does not write to the iPhone or its internal storage.
CASCADIA_A13="${CASCADIA_A13:-/Volumes/swxc/aetheros/Project-Cascadia/devices/a13}"
BASE_ROOTFS="$CASCADIA_A13/build/alpine-a13.tar.gz"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)/build"
STAGE_DIR="$CASCADIA_A13/build/aether-shell-preview"
ALPINE_VER="${ALPINE_VER:-3.24}"

[[ -f "$BASE_ROOTFS" ]] || {
    echo "Missing Cascadia RAM root filesystem: $BASE_ROOTFS" >&2
    exit 1
}
mkdir -p "$OUTPUT_DIR" "$STAGE_DIR/shell" "$STAGE_DIR/dist"
cp "$(dirname "$0")/shell/Main.qml" "$STAGE_DIR/shell/Main.qml"
cp "$(dirname "$0")/shell/run-preview.sh" "$STAGE_DIR/shell/run-preview.sh"

docker run --rm --platform linux/arm64 \
    -v "$BASE_ROOTFS:/base/alpine-a13.tar.gz:ro" \
    -v "$STAGE_DIR/dist:/dist" \
    -v "$STAGE_DIR/shell:/shell:ro" \
    "alpine:$ALPINE_VER" sh -euxc '
        mkdir -p /r
        tar -xzf /base/alpine-a13.tar.gz -C /r
        apk --root /r --keys-dir /etc/apk/keys \
            --repositories-file /r/etc/apk/repositories add \
            qt6-qtbase qt6-qtdeclarative qt6-qtwayland \
            weston weston-backend-drm weston-shell-desktop seatd
        mkdir -p /r/opt/aetheros/shell
        cp /shell/Main.qml /r/opt/aetheros/shell/Main.qml
        cp /shell/run-preview.sh /r/opt/aetheros/shell/run-preview.sh
        chmod 755 /r/opt/aetheros/shell/run-preview.sh
        tar -C /r -czf /dist/alpine-a13-aether-shell-preview.tar.gz .
        chown "$(id -u):$(id -g)" /dist/alpine-a13-aether-shell-preview.tar.gz
    '

cp "$STAGE_DIR/dist/alpine-a13-aether-shell-preview.tar.gz" "$OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/alpine-a13-aether-shell-preview.tar.gz"
