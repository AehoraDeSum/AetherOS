#!/bin/sh
# AetherOS I0: back up the iPhone 11's irreplaceable NVMe namespaces BEFORE
# any install. Read-only on the phone: it only runs dd/sha256sum, and the
# namespaces are set read-only first. Run it with the phone booted into a
# Cascadia/AetherOS RAM image (the write gate may be closed: reads pass).
#
#   tools/nvme-backup.sh            back up to both places, verify
#   PHONE=root@host tools/nvme-backup.sh
#
# What it copies:
#   nvme0n2  firmware (img4 store)      8 MiB
#   nvme0n3  syscfg: calibration, MACs, serials -- IRREPLACEABLE
#   nvme0n4  iPCB
#   nvme0n5  nvram
#   nvme0n6  effaceable storage
#   nvme0n7  unknown, 1 MiB
#   nvme0n1  first and last 1 MiB (the GPT of the iOS disk), for the record
# Each file is hashed on the phone and on the Mac; both must agree, and each
# namespace is read twice. Output goes to two places (private: serials):
#   $PRIMARY/n104-nvme-<stamp>/  and  $MIRROR/n104-nvme-<stamp>/
set -eu

PHONE=${PHONE:-root@172.16.42.1}
PRIMARY=${PRIMARY:-/Volumes/swxc/aetheros/backups}
MIRROR=${MIRROR:-$HOME/AetherOS-backup}
stamp=$(date +%Y%m%d-%H%M%S)

say()  { printf '\n== %s\n' "$*"; }
fail() { printf 'nvme-backup: %s\n' "$*" >&2; exit 1; }
phone() { ssh -o ConnectTimeout=5 -o BatchMode=yes "$PHONE" "$@"; }
if command -v shasum >/dev/null 2>&1; then sha() { shasum -a 256 "$1" | awk '{print $1}'; }
else sha() { sha256sum "$1" | awk '{print $1}'; }; fi

say "phone"
model=$(phone 'tr -d "\0" </proc/device-tree/model' 2>/dev/null) || fail "no ssh to $PHONE (boot the phone, check the USB network)"
echo "model: $model"
case "$model" in *iPhone*11*|*n104*|*N104*) ;; *) fail "unexpected model '$model' -- this is for the iPhone 11 (N104AP)";; esac
phone 'for n in 2 3 4 5 6 7; do [ -b /dev/nvme0n$n ] || exit 1; done' \
    || fail "nvme0n2..7 not all present on the phone"
phone 'for d in /dev/nvme0n*; do blockdev --setro "$d"; done'
echo "all NVMe namespaces set read-only on the phone"

dir="$PRIMARY/n104-nvme-$stamp"
mkdir -p "$dir"; chmod 700 "$PRIMARY" "$dir"
: > "$dir/SHA256SUMS"

grab() { # name, remote command that writes the data to stdout
    name=$1; cmd=$2
    phone "$cmd" > "$dir/$name"
    [ -s "$dir/$name" ] || fail "$name: empty read"
    remote=$(phone "$cmd | sha256sum" | awk '{print $1}')   # second read
    local_sum=$(sha "$dir/$name")
    [ "$remote" = "$local_sum" ] || fail "$name: phone $remote != Mac $local_sum (two reads differ or the copy broke)"
    chmod 600 "$dir/$name"
    printf '%s  %s\n' "$local_sum" "$name" >> "$dir/SHA256SUMS"
    printf 'ok  %-22s %8s bytes  %s\n' "$name" "$(wc -c <"$dir/$name" | tr -d ' ')" "$local_sum"
}

say "namespaces 2-7"
for n in 2 3 4 5 6 7; do
    grab "nvme0n$n.bin" "dd if=/dev/nvme0n$n bs=4096 2>/dev/null"
done

say "nvme0n1 GPT areas"
size=$(phone 'blockdev --getsize64 /dev/nvme0n1')
echo "nvme0n1: $size bytes"
grab "nvme0n1-head-1MiB.bin" "dd if=/dev/nvme0n1 bs=1048576 count=1 2>/dev/null"
grab "nvme0n1-tail-1MiB.bin" "dd if=/dev/nvme0n1 bs=1048576 skip=$((size / 1048576 - 1)) count=1 2>/dev/null"

{
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "model: $model"
    echo "nvme0n1 bytes: $size"
    echo "taken by: AetherOS tools/nvme-backup.sh, phone read-only"
} > "$dir/INFO.txt"
chmod 600 "$dir/INFO.txt"

say "mirror"
mkdir -p "$MIRROR"; chmod 700 "$MIRROR"
cp -Rp "$dir" "$MIRROR/"
while read -r sum name; do
    [ "$(sha "$MIRROR/$(basename "$dir")/$name")" = "$sum" ] || fail "mirror copy of $name does not verify"
done < "$dir/SHA256SUMS"
echo "verified: $MIRROR/$(basename "$dir")"

say "done"
echo "primary: $dir"
echo "mirror:  $MIRROR/$(basename "$dir")"
echo "Keep at least one copy off this Mac as well (an encrypted USB stick or cloud vault): nvme0n3 is irreplaceable."
