#!/usr/bin/env bash
set -euo pipefail

CASCADIA_ROOT="${CASCADIA_ROOT:-/Volumes/swxc/aetheros/Project-Cascadia}"
LAB_ENV="${AETHEROS_LAB_ENV:-/Volumes/swxc/aetheros/lab/env.sh}"
A13="$CASCADIA_ROOT/devices/a13"
BASE_ROOTFS="$A13/build/alpine-a13.tar.gz"
LIVE_ROOTFS="$(cd "$(dirname "$0")" && pwd)/build/alpine-a13-live-desktop.tar.gz"
TMP_ROOTFS="$A13/build/alpine-a13.live-desktop.tmp.tar.gz"
KERNEL="$A13/boot/out/m1n1-linux.rkrn.img4"
RAMDISK="$A13/boot/out/alpine.rdsk.img4"
KERNEL_BACKUP="$A13/boot/out/m1n1-linux.before-aether-live-desktop.rkrn.img4"
RAMDISK_BACKUP="$A13/boot/out/alpine.before-aether-live-desktop.rdsk.img4"
KERNEL_VNC_BACKUP="$A13/boot/out/m1n1-linux.before-aether-vnc.rkrn.img4"
RAMDISK_VNC_BACKUP="$A13/boot/out/alpine.before-aether-vnc.rdsk.img4"
KERNEL_TEMP="$A13/boot/out/.live-desktop-kernel.$$.img4"
RAMDISK_TEMP="$A13/boot/out/.live-desktop-ramdisk.$$.img4"
PACKED_KERNEL="$A13/boot/out/aetheros-live-desktop.rkrn.img4"
PACKED_RAMDISK="$A13/boot/out/aetheros-live-desktop.rdsk.img4"
success=0

[[ -f "$LIVE_ROOTFS" ]] || { echo "Build the XFCE rootfs first: desktop/build-live-desktop-rootfs.sh" >&2; exit 1; }
[[ -f "$BASE_ROOTFS" && -f "$KERNEL" && -f "$RAMDISK" ]] || {
    echo "Missing Cascadia base rootfs or current boot image pair." >&2
    exit 1
}
[[ -f "$LAB_ENV" ]] || { echo "Missing host environment: $LAB_ENV" >&2; exit 1; }
[[ ! -e "$TMP_ROOTFS" ]] || { echo "A previous temporary rootfs is present: $TMP_ROOTFS" >&2; exit 1; }

cleanup() {
    status=$?
    trap - EXIT HUP INT TERM
    if [[ -f "$TMP_ROOTFS" ]]; then mv -f "$TMP_ROOTFS" "$BASE_ROOTFS"; fi
    if [[ "$success" -ne 1 ]]; then
        [[ -f "$KERNEL_TEMP" ]] && cp -p "$KERNEL_TEMP" "$KERNEL"
        [[ -f "$RAMDISK_TEMP" ]] && cp -p "$RAMDISK_TEMP" "$RAMDISK"
    fi
    rm -f "$KERNEL_TEMP" "$RAMDISK_TEMP"
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

cp -p "$KERNEL" "$KERNEL_TEMP"
cp -p "$RAMDISK" "$RAMDISK_TEMP"
[[ -e "$KERNEL_BACKUP" ]] || cp -p "$KERNEL" "$KERNEL_BACKUP"
[[ -e "$RAMDISK_BACKUP" ]] || cp -p "$RAMDISK" "$RAMDISK_BACKUP"
[[ -e "$KERNEL_VNC_BACKUP" ]] || cp -p "$KERNEL" "$KERNEL_VNC_BACKUP"
[[ -e "$RAMDISK_VNC_BACKUP" ]] || cp -p "$RAMDISK" "$RAMDISK_VNC_BACKUP"
cp -p "$BASE_ROOTFS" "$TMP_ROOTFS"
cp "$LIVE_ROOTFS" "$BASE_ROOTFS"

cd "$CASCADIA_ROOT"
# shellcheck disable=SC1090
source "$LAB_ENV"
./cascadia a13 pack

cp -p "$KERNEL" "$PACKED_KERNEL"
cp -p "$RAMDISK" "$PACKED_RAMDISK"
success=1
ls -lh "$KERNEL" "$RAMDISK" "$KERNEL_BACKUP" "$RAMDISK_BACKUP" \
    "$KERNEL_VNC_BACKUP" "$RAMDISK_VNC_BACKUP" \
    "$PACKED_KERNEL" "$PACKED_RAMDISK"
