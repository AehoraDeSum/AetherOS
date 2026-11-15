#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="$(cd "$(dirname "$0")/.." && pwd)"
CASCADIA_ROOT="${CASCADIA_ROOT:-/Volumes/swxc/aetheros/Project-Cascadia}"
A13="$CASCADIA_ROOT/devices/a13"
LAB_ENV="${AETHEROS_LAB_ENV:-/Volumes/swxc/aetheros/lab/env.sh}"
PROBE="$WORKSPACE/build/bootloader/stage0/aetheros-n104-handoff-probe.Image.gz"
PAYLOAD="$A13/build/payload"
OUT="$A13/boot/out"
NAMED="$OUT/aetheros-stage0-probe.rkrn.img4"

[[ -f "$PROBE" ]] || { echo "Build it first with: make stage0-probe" >&2; exit 1; }
[[ -f "$LAB_ENV" ]] || { echo "Missing host environment: $LAB_ENV" >&2; exit 1; }
for f in Image.gz; do
    [[ -f "$PAYLOAD/$f" ]] || { echo "Missing Cascadia payload: $PAYLOAD/$f" >&2; exit 1; }
done
for f in m1n1-linux.macho m1n1-linux.rkrn.img4 m1n1-proxy.rkrn.img4 alpine.rdsk.img4; do
    [[ -f "$OUT/$f" ]] || { echo "Missing current Cascadia artifact: $OUT/$f" >&2; exit 1; }
done

TMP="$(mktemp -d)"
FILES=(m1n1-linux.macho m1n1-linux.rkrn.img4 m1n1-proxy.rkrn.img4 alpine.rdsk.img4)

cleanup() {
    status=$?
    trap - EXIT HUP INT TERM
    cp -p "$TMP/Image.gz" "$PAYLOAD/Image.gz"
    for f in "${FILES[@]}"; do cp -p "$TMP/$f" "$OUT/$f"; done
    rm -rf "$TMP"
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

cp -p "$PAYLOAD/Image.gz" "$TMP/Image.gz"
for f in "${FILES[@]}"; do cp -p "$OUT/$f" "$TMP/$f"; done

cp "$PROBE" "$PAYLOAD/Image.gz"
cd "$CASCADIA_ROOT"
# shellcheck disable=SC1090
source "$LAB_ENV"
./cascadia a13 pack
cp -p "$OUT/m1n1-linux.rkrn.img4" "$NAMED"
echo "Created RAM-only handoff probe: $NAMED"
shasum -a 256 "$NAMED"
echo "Cascadia's original Image.gz and active boot pair will now be restored."

