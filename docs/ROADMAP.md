# AetherOS Engineering Roadmap

**Priority:** Bootability, repeatable builds, persistence design, and recovery come before desktop product work. The XFCE/VNC image is a confirmed lab reference only.

## Current device baseline

- iPhone 11 / N104AP boots Cascadia's Alpine Linux image through DFU, RP2350 usbliter8, patched iBSS, and m1n1.
- Linux shell, touchscreen input, XFCE, and USB VNC are confirmed on the device.
- The generic AetherOS stage-0 remains a compile-only scaffold. A separate framebuffer marker is packaged as a named IMG4 but has not yet run on-device. The current reference flow is not independent.
- Device experiments remain in RAM. The iOS install and internal storage stay untouched.

## Ordered milestones

| Milestone | Work | Exit condition |
| --- | --- | --- |
| B0 — Freeze a reference | Record Cascadia commit, dirty source files, kernel config, DTB, boot artifacts, firmware inputs/licenses, and known-good recovery steps | Another build can reproduce the current reference image from pinned inputs; clean rebuild remains open |
| B1 — Define the entry contract | Document the exact stage AetherOS can first own, CPU exception level, registers, memory ranges, cache/MMU state, DTB, and debug channel | Initial m1n1 → Linux handoff is documented; exact memory map and some register state remain open |
| B2 — First AetherOS code on device | Link a minimal AArch64 Image-compatible stage; mark the framebuffer; keep it RAM-only | Green marker appears after handoff without changing internal storage; probe image is prepared, device trial pending |
| B3 — AetherOS-owned Linux handoff | Place Linux Image, initramfs, and DTB; normalize CPU state and pass control according to the arm64 boot protocol | AetherOS-owned loader reaches a Linux shell repeatedly and logs failures |
| B4 — Reproducible base distribution | Build a minimal root filesystem, init, essential services, versioned image, checksums, and release metadata | Clean build gives a bootable, documented RAM image with a recovery route |
| B5 — Persistence and recovery design | Compare RAM, external/host-backed, and device-persistent options; define backup, update, rollback, and restore | A recovery procedure is demonstrated before any persistent write is considered |
| B6 — Essential hardware | Enable the peripherals needed for everyday system use, prioritizing storage, input, USB/network, and power/thermal reporting | Each supported function has repeatable device evidence and documented limitations |
| B7 — Product desktop | Return to Aether Shell, application integration, and touch-first personalization | The bootable distribution and recovery flow are stable enough to support UI work |

The observed handoff ABI, probe design, and its limits are in [BOOT_HANDOFF_CONTRACT.md](BOOT_HANDOFF_CONTRACT.md). The source baseline and current image fingerprints are in [REFERENCE_BASELINE.md](REFERENCE_BASELINE.md).

## Boot independence gate

The milestones above can use the already tested usbliter8 path as a temporary lab bootstrap where needed. That is useful for proving AetherOS-owned stages, but it does not satisfy the independent-bootloader objective. Track every remaining iBoot, iBSS, m1n1, DFU, and RP2350 dependency. Do not claim independence until AetherOS replaces the required stages and the handoff is repeatable. If the only path forward requires a security bypass outside the project's approved constraints, record a no-go rather than silently changing scope.

## Installation boundary

“Installable” first means a reproducibly built, bootable, recoverable system image. It does not authorize writing to the iPhone's internal storage. Persistent installation remains a separate decision after reliable boot, backup/restore, and recovery have been demonstrated. The Mac's external `aetheros` folder stores source and build artifacts; it is not the phone's install target.
