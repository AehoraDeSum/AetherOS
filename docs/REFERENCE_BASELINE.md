# iPhone 11 Reference Baseline

**Captured:** 2026-11-15  
**Purpose:** Pin the last user-confirmed, RAM-only Linux/desktop boot as a comparison point for AetherOS boot work. This records the Cascadia reference system; it is not an AetherOS boot image.

## Device-confirmed behavior

- Device: iPhone 11, iPhone12,1 / N104AP / T8030.
- Entry chain: DFU → RP2350 usbliter8 → patched iBSS → m1n1 → Linux.
- User-observed kernel: `7.2.0-rc1-g2f2662c87fff-dirty`, AArch64, six-core SMP.
- Root filesystem: Alpine 3.24 in RAM.
- Screen: iBoot-provided 828 × 1792 simpledrm framebuffer; native panel initialization and GPU acceleration are not established.
- Touchscreen firmware reaches `firmware running`; touch events work. XFCE, on-screen keyboard, touchscreen pointer/drag, single-tap activation, and Mac VNC over USB are confirmed.
- The user attributes apparent screen clipping to physical screen damage; no software layout issue is currently tracked.
- Internal iOS installation/storage has not been used by these trials.

## Source and build inputs

| Item | Recorded value |
| --- | --- |
| Cascadia checkout | `/Volumes/swxc/aetheros/Project-Cascadia`, branch `main` |
| Cascadia HEAD | `705fd31f014b226e663f1ab0009d138787fbfbd7` (`a5: stage 2 knows a root on the NAND`) |
| Cascadia worktree | Dirty when captured: `devices/a13/docs/research/touch.md`, `devices/a13/kernel/extras/apple_hidspi_touch.c`, `devices/a13/usbliter8ctl` |
| Kernel tree | `yhavry/Hoolock-linux`, branch `t8030`, commit `2f2662c87fff28b83eab6786f53be2c2670ba53f` |
| Kernel config base | Hoolock A13 `config_16k` at `96a110bc680f085f5744bb97679abbf41e2f0df5`, SHA-256 `8e6133a576773dc455b6384a7473bce0a646dfb04779bee8f994f00fe7691472`, merged with Cascadia `n104.fragment` |
| Effective kernel config | 16K pages enabled (`CONFIG_ARM64_16K_PAGES=y`); saved at `devices/a13/build/kernel.config` |
| Kernel source inputs | `devices/a13/kernel/build-kernel.sh`, `kernel/patches/`, `kernel/extras/`; local Cascadia modifications are part of the current reference and must be captured before claiming a clean rebuild |
| Device tree payload | `devices/a13/build/payload/t8030-n104.dtb`, SHA-256 `901a19114c6c858c571c1c793609bf8a61bc27abf419f1c8d2685c56b09c2d6b` |

## Artifact fingerprints

SHA-256 values identify the artifacts on the lab host at capture time:

| Artifact | SHA-256 |
| --- | --- |
| Active kernel IMG4, `boot/out/m1n1-linux.rkrn.img4` | `0e9eb5dac7d90c499558c0ee8843b6a67902c4aad979eb276f97d586448f786f` |
| Active RAM root IMG4, `boot/out/alpine.rdsk.img4` | `90bee3ba3250ceb5525f6d3566cd6315fec458863acbc9f27e2cc9639c8852e6` |
| Named XFCE/VNC kernel IMG4, `boot/out/aetheros-live-desktop.rkrn.img4` | `0e9eb5dac7d90c499558c0ee8843b6a67902c4aad979eb276f97d586448f786f` |
| Named XFCE/VNC RAM root IMG4, `boot/out/aetheros-live-desktop.rdsk.img4` | `90bee3ba3250ceb5525f6d3566cd6315fec458863acbc9f27e2cc9639c8852e6` |
| Separate XFCE/VNC root archive, `desktop/build/alpine-a13-live-desktop.tar.gz` | `dd4fbbf1c2e3fc3e3dfcbe8ee2b6c0d5bf9a39ffee25c7553ea6f7ef639d0a4f` |
| Normal Alpine root archive, `devices/a13/build/alpine-a13.tar.gz` | `13085e2237c064754985aa42537adeaf0c4e430836872b10c45343950be46244` |
| Kernel config, `devices/a13/build/kernel.config` | `47993bec69b445eda1a50691e268b202dd739b72d8c39847ba58672d3a6bf62a` |
| Compressed kernel payload, `devices/a13/build/payload/Image.gz` | `6515e15c2c2bc297f4ea21336e71052b91c32861774791f42785f70d4ed13894` |
| Initramfs payload, `devices/a13/build/payload/initramfs.cpio.gz` | `40f2ecb276166053ffeb0baae737f16ba80ab4a58795694a0ed4c72a427963f9` |
| m1n1 payload, `devices/a13/build/payload/m1n1-idevice.macho` | `f32758efe5efd00b14398889917398e68b4e37a200ca0208a76f70eeb4ada568` |
| AetherOS handoff probe, `boot/out/aetheros-stage0-probe.rkrn.img4` | `6a18c3efe914fd75dae6f9041ad06fdb4704d0060cfaab2c220d47f72255a8d3` |

## Known boundaries

- This baseline demonstrates that Cascadia boots Linux on this phone. It does not show AetherOS-owned code executing on the device.
- An AetherOS framebuffer probe is now packaged but has not yet been booted on the phone.
- The current boot flow retains usbliter8, patched iBSS, and m1n1. The independent-bootloader goal is unproven.
- Build artifacts came from a dirty Cascadia checkout. Before using them as a reproducibility claim, pin or archive all dirty source changes and rebuild from a clean, documented workspace.
- The Alpine image is RAM-only. No internal-storage installation, update, rollback, or restore process has been demonstrated.
