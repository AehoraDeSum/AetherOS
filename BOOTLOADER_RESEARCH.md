# AetherOS Bootloader Research

**Status:** usbliter8 tethered lab bootstrap authorized; AetherOS handoff and independent-loader feasibility unresolved  
**Target:** iPhone 11 / N104AP / A13 (T8030)  
**Last reviewed:** 2026-11-14

## Executive finding

The user has authorized usbliter8 as a tethered, lab-only bootstrap candidate for the project device. This authorization is limited to that named route. The generic AArch64 stage-0 is still a compile-only scaffold. A separate framebuffer probe is packaged, but has not run on the phone; no AetherOS-owned handoff has yet been demonstrated.

The published Project Cascadia A13 path is useful as a Linux and driver reference, but it does **not** demonstrate the desired independent bootloader. Its current device documentation identifies a tethered flow using usbliter8, a patched iBSS, and m1n1. usbliter8 is now an accepted candidate for an initial lab bootstrap; Cascadia's complete flow is not automatically AetherOS's flow. We must establish which components AetherOS can replace. No exploit procedure is documented here.

Apple's published security model describes immutable Boot ROM as the hardware root of trust and signature verification across the boot chain, including iBoot and the operating-system kernel. DFU is a recovery/firmware-update mode, not a documented generic interface for loading an arbitrary operating system. A permissive iPhone bootloader API, standard UEFI entry point, or owner-authorized development mode for this consumer device has not been identified.

## What “independent” means here

The intended AetherOS chain would have AetherOS-owned stage 0, platform initialization, and Linux loader code after the selected bootstrap. For the initial tethered prototype, usbliter8 is an explicitly authorized external entry dependency. The separate independence milestone is to replace Apple's iBoot/iBSS and m1n1 roles with AetherOS-owned stages where feasible. The RP2350/DFU bootstrap may remain; untethered startup is separate and unproven.

The current Cascadia reference gives us a narrower first execution point: its m1n1-to-Linux handoff is documented at EL1 with the MMU off and the DTB physical address in x0. A tiny AetherOS-owned Image-compatible probe has been packaged to mark that handoff in the inherited framebuffer. This would prove only that AetherOS code can run as the payload after m1n1; it does not replace iBSS, iBoot, or m1n1. See [the handoff contract](docs/BOOT_HANDOFF_CONTRACT.md).

Boot ROM itself is immutable device hardware and necessarily begins execution. Independence therefore means that AetherOS does not replace, patch, or bypass that root of trust; it uses only a documented, permitted interface that the device owner is allowed to invoke. No such interface has been proven for arbitrary Linux on the iPhone 11.

## Candidate paths

| Candidate | Evidence | Meets current project scope? | Status |
| --- | --- | --- | --- |
| Apple-supported startup / DFU restore | Apple documents signature-checked secure boot. The public documentation does not describe an arbitrary Linux loader interface. | No evidence that it can load AetherOS; do not assume DFU accepts unsigned/custom stages. | Not a demonstrated path |
| usbliter8 tethered bootstrap | User has authorized an RP2350-backed lab evaluation. Cascadia reports using it as part of its A13 startup path. | Yes, for this named lab prototype | Accepted candidate; handoff not demonstrated |
| Project Cascadia A13 flow | Current docs report a tethered setup using usbliter8, patched iBSS, and m1n1, followed by Linux. | Reference, not the independence result | Determine which stages AetherOS can replace |
| A documented vendor development interface or authorized test device | No applicable iPhone 11 interface has been located. | Potentially, if independently documented and authorized | Research question |
| AetherOS binary compiled for AArch64 | This repository can compile early-stage code to relocatable objects on an Apple Silicon host. | Yes for host compilation; it says nothing about device entry or hardware initialization. | Available as scaffold only |

## Required technical questions

Before any target execution beyond the bounded framebuffer probe is proposed, answer these questions from documented and permitted sources:

1. What mechanism starts AetherOS-owned code without an exploit or signature bypass?
2. What processor exception level, security state, MMU/cache state, interrupt mask, and core state does that mechanism provide?
3. Does it hand off initialized DRAM and a usable memory map, or is there a documented way for AetherOS to initialize memory?
4. Which clocks, power domains, interrupt controller, timers, DMA devices, and display resources are initialized, and which are safe to reinitialize?
5. Can the system be restarted into the original iOS installation without writing persistent storage?
6. Can the Linux kernel, initramfs, and DTB fit in known safe RAM ranges while respecting firmware reservations?

The generic AArch64 Linux contract is necessary but does not answer the T8030 platform questions. The loader must ultimately enter Linux in a supported non-secure exception level with the required register, interrupt, MMU, cache, coherency, timer, and DTB state.

## Go/no-go gate

**Probe gate:** A tethered, RAM-only framebuffer-marker attempt is prepared. It writes no persistent storage and intentionally halts before Linux starts. Its expected recovery is a force-restart into the existing iOS installation.

**Loader prototype go:** A fuller AetherOS loader experiment remains gated on exact entry state, safe RAM ranges, debug output, and a recorded recovery path.

**Independence gate:** demonstrate that AetherOS-owned stages can take over the required bootloader roles and load Linux without relying on iBoot/iBSS or m1n1. Record any remaining usbliter8/RP2350/DFU dependency separately. Persistent storage remains out of scope until a separate recovery-backed decision.

## Risk register

| Risk | Impact | Current mitigation / gate |
| --- | --- | --- |
| No compliant way to enter AetherOS-owned code | Blocks all device bring-up and the independent-loader goal | Resolve first; record evidence and stop device work if no compliant path exists |
| DRAM training and memory map are unavailable | Loader may not safely place Linux, DTB, and initramfs | Do not assume Linux handoff state; require authoritative ranges and reservation data |
| Apple power and security co-processors are undocumented | Unstable boot, device lockout, or loss of required services | Keep early work RAM-only and avoid reinitializing undocumented domains |
| iPhone 11 panel/GPU support is incomplete | No native display or acceleration despite a booting kernel | Treat framebuffer, native panel modesetting, and GPU acceleration as distinct milestones |
| Code provenance/license incompatibility | Prevents redistribution or upstreaming | Pin source revisions and record SPDX/license and local modifications before adapting code |
| Persistent-storage experiment harms iOS/recovery | Loss of the existing installation | Do not write storage in Phase 0–4; require a separate recovery-backed decision |

## Phase 0 research outputs

- A source register separating Apple-published facts, exact-model bring-up reports, and unverified hypotheses.
- A boot-state table for any permitted entry candidate: CPU mode, security state, memory, cores, interrupts, MMU/caches, timer, and device state.
- A written go/no-go decision with links and an explanation of any remaining uncertainty.
- If the decision is no-go, keep the hardware-specific code dormant while continuing generic ARM64 and userspace work.

## References

- [Apple Platform Security — iPhone and iPad boot process](https://support.apple.com/en-ie/guide/security/secb3000f149/web)
- [Project Cascadia — A13 device status and boot path](https://github.com/rzxvx/Project-Cascadia/blob/main/devices/a13/README.md)
- [Project Cascadia — iPhone 11 quickstart](https://github.com/rzxvx/Project-Cascadia/blob/main/devices/a13/docs/QUICKSTART.md)
- [usbliter8 — published A12/A13 SecureROM exploit project](https://github.com/JoshAtticus/usbliter8) (classification reference only; not an AetherOS dependency)
- [Linux — Booting AArch64 Linux](https://docs.kernel.org/arch/arm64/booting.html)
