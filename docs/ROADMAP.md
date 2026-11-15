# AetherOS Engineering Roadmap

## Target (decided 2026-11-15)

**AetherOS installed persistently on the iPhone 11, booted in one step, eventually without the Mac.**

Hard limit: on A13 every boot is tethered. The BootROM only runs Apple-signed iBoot. checkm8 is a BootROM bug that works only from DFU over USB, and it cannot be made persistent. There is no known public A13 BootROM or iBoot exploit that survives a normal power-on. So "power on and AetherOS starts" is out of reach. The reachable target is:

1. The system lives on the phone's own NVMe and survives reboots (no RAM-only, no NFS).
2. A boot is one action: phone in DFU, plug in the bootstrapper, wait.
3. The bootstrapper becomes a small pocket device instead of the Mac.

The XFCE/VNC image is a lab reference only. Desktop product work comes after the system is installable and recoverable.

## Current device baseline

- iPhone 11 / N104AP boots Cascadia's Alpine Linux from RAM through DFU, RP2350 usbliter8, patched iBSS, and m1n1.
- Linux shell, touchscreen input, XFCE, and USB VNC are confirmed on the device.
- iOS is still installed, and the internal storage is untouched.
- AetherOS stage-0 green-framebuffer probe is packaged (`aetheros-stage0-probe.rkrn.img4`) but has not run on the device yet.
- Cascadia has already shown an NVMe root on another phone (2026-11-01: `LABEL=cascadia-root`, ext4, with a kernel write gate that keeps namespaces 2–7 unwritable). That flow erases iOS.

## What the Mac does today in a boot

From `./cascadia a13 boot`:

| Step | Tool | Data |
|---|---|---|
| Bring the phone to pwned DFU | usbliter8 (RP2350) | — |
| Send iBSS by DFU, then custom boot | `usbliter8ctl` (pyusb) | 2.2 MB |
| Wait for Recovery | `irecovery -q` | — |
| DeviceTree → `devicetree` | `irecovery` | 0.23 MB |
| Empty trust cache → `firmware` | `irecovery` | 0.01 MB |
| (RAM root only) Alpine ramdisk → `ramdisk` | `irecovery` | ~255 MB |
| m1n1 + Linux → `bootx` | `irecovery` | ~14 MB |

With the root on NVMe, the ramdisk step goes away, and a boot is ~17 MB of USB traffic. Nothing in it needs macOS. Cascadia's host side already supports Linux, so any small Linux board with USB host can do the same job.

## Install track (priority)

| Milestone | Work | Exit condition |
| --- | --- | --- |
| I0 — Recovery proven before any write | Keep the NVMe namespace 2–7 backup (syscfg is irreplaceable) and the IM4M off-device; document and try the way back to iOS (DFU restore in Finder) | Written restore procedure; backups have checksums and are stored in two places |
| I1 — Install decision | Choose between: (a) all of namespace 1 for AetherOS, which erases iOS and follows Cascadia's proven N1–N3 flow; or (b) side by side with iOS, which is research (an APFS-contained extent + dm-linear, see Cascadia `research/nvme-plan.md`) | User decision recorded |
| I2 — AetherOS root on NVMe | Our own rootfs (from B4) installed through the write gate, booted from `LABEL=…-root` before the RAM and NFS fallbacks | Survives several reboots, `apk add` and reboot, and a power loss |
| I3 — One-step boot from the Mac | One command that waits for DFU, runs usbliter8 → iBSS → DT → trust cache → kernel, with no ramdisk; clear errors and a retry loop | A cold boot needs nothing but "DFU, plug in, wait" |
| I4 — Mac-less bootstrapper | A small Linux board (for example a Raspberry Pi Zero 2 W or similar with USB host) plus usbliter8, running the same boot script on power or on a button press; boot images in its storage | The phone boots AetherOS from the board, with no computer involved |
| I5 — Single-board bootstrapper (research) | Whether usbliter8's RP2350 can also send iBSS, DT, trust cache and kernel itself (needs its firmware source, USB host mode, ~17 MB of storage, full-speed USB timing) | Feasibility note: go or no-go |
| I6 — Updates and rollback | Update the root and the boot images without losing user data; keep the previous kernel/image to fall back to | An update, then a rollback, both shown on the device |

## Bootloader track (parallel, supports I3–I5)

| Milestone | Work | Exit condition |
| --- | --- | --- |
| B0 — Freeze a reference | Cascadia commit (now branch `aetheros`), kernel config, DTB, boot artifacts, firmware inputs | Reference image can be rebuilt from pinned inputs |
| B1 — Entry contract | m1n1 → Linux handoff: EL1, MMU off, `x0` = DTB | Documented in [BOOT_HANDOFF_CONTRACT.md](BOOT_HANDOFF_CONTRACT.md) |
| B2 — First AetherOS code on device | Green framebuffer probe in the m1n1 kernel slot, RAM-only | Green screen seen on the device |
| B3 — AetherOS-owned Linux handoff | AetherOS stage places Image/initramfs/DTB and enters Linux by the arm64 boot protocol | Reaches a Linux shell repeatedly |
| B4 — Reproducible base distribution | Minimal AetherOS rootfs, init, services, versioned image, checksums | Clean build gives the image that I2 installs |

## Later

- Essential hardware for daily use: native display, backlight, battery and charging, audio, buttons (Cascadia roadmap, phase 3).
- Product desktop: Aether Shell and touch-first UI.

## Rules that do not change

- Before I0 and I1 are done, nothing is written to the phone's NVMe. Experiments stay RAM-only.
- Back up the active boot pair in `boot/out/` before every swap.
- Do not claim boot independence beyond what has been shown. iBSS/iBoot/DFU and checkm8 remain dependencies on A13.
