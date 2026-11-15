# N104 Boot Handoff Contract

**Status:** researched contract for a lab-only AetherOS execution probe; not an independent bootloader specification  
**Device:** iPhone 11 / N104AP / T8030  
**Captured:** 2026-11-15

## What the proven boot path does

Cascadia's documented path is:

1. DFU plus the user-authorized RP2350/usbliter8 lab bootstrap reaches patched iBSS recovery.
2. The host supplies a DeviceTree and restore trust cache, then a kernelcache-type rkrn payload and the bootx command.
3. iBSS/iBoot starts the rkrn payload, which contains Hoolock m1n1, DeviceTree, initramfs, and Linux Image.gz.
4. m1n1 prepares the platform and FDT, shuts down selected devices, disables the MMU, and calls the Linux payload entry.
5. Linux starts with the Alpine RAM root.

The current sequence still depends on Apple's iBSS/iBoot and m1n1. Reaching the Linux-image entry does not establish an independent AetherOS boot chain.

## Observed m1n1 → Linux contract

Cascadia's A13 m1n1 research record, based on HoolockLinux/m1n1 commit d5a10ac52a6468484854419a6c5130f1d62073eb plus its local T8030 patches, reports:

| State | Evidence / confidence |
| --- | --- |
| Exception level | EL1 on the iPhone 11; documented in Project-Cascadia/devices/a13/docs/research/m1n1-patches.md |
| MMU | Off at the handoff; m1n1 calls its MMU shutdown path |
| Arguments | x0 is the physical DTB address; x1–x4 are zero |
| Caches | m1n1 performs cache maintenance by VA to PoC for the kernel, FDT, and initrd before the handoff; this was required for the A13 payload to execute |
| Memory map | Passed through the prepared FDT; exact safe scratch ranges for an AetherOS loader have not yet been recorded |
| Debug output | The payload cannot rely on the Linux USB ACM console. The inherited framebuffer at 0x8fa298000 is the proven early visual marker; dockchannel writes from a payload did not reach the host |
| Secondary cores, DAIF, timer, residual DMA state | The generic arm64 Linux requirements are documented, but each exact value at this A13 handoff has not been independently captured here |

The Linux arm64 boot protocol requires a DTB in RAM, x0 set to its physical address, reserved argument registers zero, interrupts masked, MMU off, valid cache/coherency state, and initialized RAM. Those rules apply when entering Linux; they do not describe the earlier iBSS → m1n1 ABI. See [Linux arm64 booting](https://docs.kernel.org/arch/arm64/booting.html).

## First AetherOS-owned execution proof

The narrow next milestone is to substitute a tiny AetherOS-owned, arm64 Image-compatible probe for the Linux Image.gz while leaving the existing Cascadia bootstrap, m1n1, DTB, and RAM-root package intact. The probe uses no stack, timer, interrupt controller, DRAM training, or storage. It writes a green marker to the already-known framebuffer and halts.

**Pass condition:** the iPhone shows the marker after the existing tethered RAM boot.

**What this proves:** AetherOS-owned instructions can execute at the m1n1 → Linux handoff under the observed AArch64 image contract.

**What this does not prove:** AetherOS replaces iBSS, iBoot, or m1n1; initializes DRAM; loads Linux; or boots independently. The probe deliberately cannot reach Linux or provide a USB shell. Force-restarting back to iOS is the expected end of this temporary RAM-only trial.

The source is bootloader/stage0/n104_handoff_probe.S; make stage0-probe creates a one-page arm64 Image and gzip payload. The packaging helper creates a named aetheros-stage0-probe.rkrn.img4 while restoring Cascadia's normal build inputs and active boot pair.

## Next contract gaps after the probe

1. Capture the full entry register/system-register state and confirm interrupt masking from the exact m1n1 build.
2. Extract and record all usable and reserved RAM ranges from the actual prepared DTB, including m1n1 and initrd reservations.
3. Define a serial/visual error channel and a safe stack/location policy for a C-based Stage 0.
4. Specify a relocation and Linux Image/DTB/initramfs loader with cache maintenance and DMA quiescing.
5. Separately research whether the AetherOS loader can replace m1n1 while preserving an allowed iBSS/iBoot entry, then assess whether any documented permitted mechanism can remove iBoot/iBSS. Keep these gates distinct.

