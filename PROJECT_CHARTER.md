# AetherOS Project Charter

**Status:** Phase 0 — research and architecture  
**Target device:** iPhone 11, model identifier iPhone12,1 / N104AP, Apple A13 / T8030  
**Last reviewed:** 2026-11-15

## Mission

Build a maintainable Linux-based platform for the iPhone 11 that includes AetherOS-owned hardware enablement, a distribution, system services, and a phone-oriented desktop. Design interfaces so that later ports to other Apple devices and ARM64 boards remain possible.

The project will use the Linux kernel. It will develop the target configuration, required patches, device description, and missing drivers; it will not write a new kernel.

## Scope

The system architecture covers the entire stack from the earliest AetherOS-owned code through the desktop:

- An independently designed bootloader, if a compliant way to execute it can be established.
- Linux AArch64 kernel configuration and platform support.
- Hardware enablement, keeping hardware-specific code in kernel drivers where practical.
- Init, system services, libraries, package management, and recovery.
- A small ARM64 distribution, initially evaluating Alpine Linux and APK.
- A Wayland-based, touch-first desktop named Aether Shell, with Qt/QML as the initial UI candidate.

All layers are defined up front. Implementation proceeds through small prototypes and explicit gates; the full stack is not developed at once.

## Engineering principles

1. **Bound the bootstrap exception.** The user has authorized usbliter8 as a tethered, lab-only bootstrap candidate for the project device. This explicitly revises the original no-exploit boundary for that route only; it does not make the method Apple-supported or suitable for general users.
2. **Preserve the existing iOS installation.** Early device work is RAM-only. Do not write internal storage until a separate, explicit project decision follows demonstrated boot reliability and a recovery plan.
3. **Keep prototypes reversible.** Prefer host builds, QEMU where relevant, removable development equipment, and read-only device inspection.
4. **Separate evidence from assumptions.** Mark hardware facts with provenance and confidence. Unknown addresses, reset states, RAM training, and firmware interfaces stay unknown until corroborated.
5. **Track source and license provenance.** Before adapting Cascadia, Hoolock, Asahi, or other code, record the exact source revision, license, modifications, and required notices.
6. **Use narrow component boundaries.** Keep bootloader, kernel, hardware support, system, distribution, and desktop APIs independently reviewable. Start in one workspace for coordinated early development; split repositories when ownership or release cadence justifies it.
7. **Make each phase useful on its own.** Every phase should end with an artifact, a reproducible build or experiment, and a stated transition criterion.
8. **Prioritize a bootable, recoverable system.** Keep XFCE/VNC as bring-up tools. Defer Aether Shell polish and product personalization until AetherOS-owned boot, kernel handoff, image generation, persistence, and recovery have working prototypes.

## Initial decisions

| Topic | Decision | Status |
| --- | --- | --- |
| Kernel | Linux AArch64 | Accepted |
| Device | iPhone 11 / N104AP / T8030 only for the first target | Accepted |
| Bootloader | AetherOS-owned stages; usbliter8 may serve as a tethered lab bootstrap | High-risk; handoff and iBoot/iBSS independence unresolved |
| Distribution | Evaluate Alpine Linux and APK for the first root filesystem | Candidate |
| Init | Compare OpenRC with a small AetherOS init after the first kernel shell | Candidate |
| Desktop | Wayland compositor and Qt/QML shell | Candidate |
| Persistent storage | Leave untouched during early bring-up | Accepted |
| Source layout | One monorepo/workspace initially; keep component interfaces separable | Accepted |

## Success measures

The project is successful through incremental milestones: verified device and memory facts; a permitted device-execution path or an early documented no-go; an AetherOS-owned stage executing on the device; Linux handoff and a recoverable RAM image; a reproducible distribution and validated persistence/recovery plan; required hardware enablement; then Aether Shell. GPU acceleration and gaming remain later experiments. A phone-internal installation is explicitly gated on proven boot reliability, a recovery procedure, and a separate user decision; early prototypes remain RAM-only.

## Phase 0 exit criteria

- Identify a documented, permitted path that can run AetherOS-owned code on the target, or record a no-go for device execution under the project's constraints.
- Separate verified A13/iPhone 11 facts from unresolved memory, power, and peripheral details.
- Select a baseline kernel source and define an evidence-backed patch and license process.
- Keep the first build reproducible on the Apple Silicon development host.
