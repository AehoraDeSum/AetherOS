# Install procedure: AetherOS on the iPhone 11's NVMe

**Decision (I1, 2026-11-15, by the user): iOS is erased.** All of NVMe namespace 1 goes to Linux. Namespaces 2–7 (firmware, syscfg, nvram, effaceable storage) are never written.

The first persistent root is Cascadia's reference Alpine (`build/alpine-a13.tar.gz`). The AetherOS root from B4 later replaces it on the same partition. This proves persistence first, without waiting on B4.

This follows Cascadia's tested flow (`devices/a13/docs/research/nvme-plan.md`, N1–N3), with an AetherOS backup step in front of it.

## What erasing means

- iOS, its apps and all user data on the phone are gone. **Back up anything you want to keep (Finder or iCloud) first.**
- After the erase, a normal power-on shows the recovery screen. Every boot is `DFU → ./cascadia a13 boot`.
- The way back to iOS: a DFU restore in Finder, which installs the currently signed iOS and erases the Linux disk. You need the Apple ID that owns the phone (Activation Lock).
- A Finder restore does not rewrite syscfg (namespace 3). Still, it is backed up below, because nothing else can recreate it.

## I0 — Backups (nothing is written to the phone)

1. Boot any RAM image as usual (`./cascadia a13 boot`). The write gate can stay closed: reads pass.
2. On the Mac:
   ```sh
   /Volumes/swxc/aetheros/AetherOS/tools/nvme-backup.sh
   ```
   This sets every namespace read-only on the phone. It copies namespaces 2–7 and the GPT areas of namespace 1, reads each one twice and compares the hashes from the phone and the Mac. It writes the result to `/Volumes/swxc/aetheros/backups/` and mirrors it to `~/AetherOS-backup/`.
3. Put a third copy somewhere off this Mac (an encrypted USB stick or a cloud vault).
4. Keep the IM4M (`boot/inputs/IM4M`) with the backups as well: without it, the phone cannot be booted into Linux.

I0 is done when both copies verify and the off-Mac copy exists.

## I2 — Install

Before each `pack`, back up the active boot pair:

```sh
out=/Volumes/swxc/aetheros/Project-Cascadia/devices/a13/boot/out
cp -p "$out/m1n1-linux.rkrn.img4" "$out/m1n1-linux.before-nvme-install.rkrn.img4"
cp -p "$out/alpine.rdsk.img4"     "$out/alpine.before-nvme-install.rdsk.img4"
```

From `Project-Cascadia/`, with `lab/env.sh` sourced:

1. `./cascadia a13 periphery`, with the phone booted. It fetches this phone's syscfg (calibration), then asks the first question: type `ERASE`. This only records the decision (`boot/inputs/nvme-linux`).
2. `./cascadia a13 pack`, then `./cascadia a13 boot`. The new image opens the write gate for namespace 1 only. The RAM root must have `sgdisk` and `mkfs.ext4`: the standard Alpine has them. The XFCE lab image may not.
3. `./cascadia a13 periphery` again. Cascadia takes its own copy of namespaces 2–7, then asks the second question: type `ERASE`. It partitions namespace 1 (`cascadia-root`, ext4) and unpacks Alpine onto it.
4. `./cascadia a13 boot`. Expect `[nvme] root /dev/nvme0n1p1` on the console.

## I2 exit checks

- [ ] Three cold boots in a row reach the NVMe root.
- [ ] `apk add <pkg>`, reboot, and the package is still there.
- [ ] Power loss: cut power while idle, boot, and `dmesg` shows a clean ext4 journal replay.
- [ ] `dmesg | grep 'write gate'` shows namespace 1 open and 2–7 closed.

Record each result in `DEVICE_TRIAL.md`.

## Last resort: syscfg damaged

Not automated, on purpose. Writing namespace 3 back from `nvme0n3.bin` needs a kernel image whose DT opens the gate for namespace 3 only, plus a manual `dd` on the phone. Decide it case by case, with the user.
