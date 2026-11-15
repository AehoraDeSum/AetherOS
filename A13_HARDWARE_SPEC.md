# iPhone 11 / A13 Hardware Specification

**Scope:** iPhone 11 only (iPhone12,1 / N104AP / T8030), not iPhone 11 Pro or Pro Max  
**Status:** Initial inventory; register-level specification is not yet validated  
**Last reviewed:** 2026-11-14

## Confidence labels

- **Confirmed:** Apple-published product specification or directly stated by a maintained project for this exact model.
- **Reported:** Open-source bring-up reports it, but AetherOS has not reproduced it.
- **Unknown:** Needs measurement or corroboration before it informs a device binary or memory map.

## Platform summary

| Item | Current record | Confidence / source |
| --- | --- | --- |
| Product | iPhone 11, model identifier iPhone12,1; board identifier N104AP / n104ap | Confirmed by [Cascadia A13 documentation](https://github.com/rzxvx/Project-Cascadia/blob/main/devices/a13/README.md) |
| SoC | Apple A13 Bionic, T8030 | Confirmed by Apple for A13 and Cascadia for T8030 on iPhone12,1 |
| CPU | 6-core: 2 performance + 4 efficiency cores | Confirmed by [Apple technical specifications](https://support.apple.com/en-us/111865); Cascadia reports all six cores working in its port |
| GPU | 4-core Apple GPU | Apple-published core count; Linux driver support is a separate unknown |
| Display | 6.1-inch IPS LCD, 1792 × 828, 326 ppi | Confirmed by Apple technical specifications |
| Memory | Commonly reported as 4 GB; Apple does not publish RAM capacity on its specification page | Reported; verify on the exact test unit and account for firmware reservations |
| Internal storage | 64 / 128 / 256 GB product configurations | Confirmed by Apple; Linux block-device protocol and safe access details remain implementation questions |
| Wireless | Wi-Fi and Bluetooth are reported working by Cascadia on this target | Reported; firmware, calibration, and upstream license/provenance must be recorded |
| Boot model | usbliter8 tethered bootstrap with RP2350 is authorized for lab evaluation; AetherOS handoff is not demonstrated | User decision; Apple security documentation and Cascadia boot-path reference |

## Subsystem inventory and work order

| Subsystem | Evidence and known state | AetherOS priority | Open questions |
| --- | --- | --- | --- |
| CPU / SMP | Apple identifies six CPU cores; Cascadia reports all six online | Critical | Entry exception level, secondary-core release, coherency, frequency states |
| RAM / MMU | 4 GB is reported, not Apple-published; Linux requires a valid usable/reserved memory map | Critical | DRAM initialization/training, physical ranges, firmware reservations, page-size constraints |
| Interrupts / timers | T8030 support work exists in Linux trees | Critical | AIC register map, interrupt routing, timer frequency and safe initial state |
| Debug / USB | Cascadia reports USB shell/network after its current boot path | Critical | A permitted AetherOS debug channel; no claim that stock DFU is a general-purpose console |
| Persistent storage | Cascadia reports internal storage used as Linux disk | High, after RAM-only boot | Controller protocol, partition safety, write protection strategy, recovery procedure |
| Touch | Cascadia reports touchscreen working | High | Exact controller/panel variant, firmware provenance, suspend/resume and gesture behavior |
| Wi-Fi / Bluetooth | Cascadia reports both working; BCM4378 is a candidate identifier in existing research | High | Confirm exact board/revision, firmware and calibration requirements, regulatory behavior |
| Power / thermal | Separate A13 Linux work describes SMC/PMGR support for some devices | High | Confirm exact N104AP applicability, charging, thermals, battery reporting and shutdown behavior |
| Native display | Current Cascadia A13 status reports framebuffer output but no native display; A13 feature notes mark native modesetting incomplete | Very high after shell | N104AP LCD panel sequence, DSI setup, backlight and reboot/resume behavior |
| Audio | No exact-model validated status in the cited Cascadia summary | Medium | Codec, DSP, microphones, speakers, routing, firmware and licensing |
| GPU | Apple lists a 4-core GPU; Cascadia reports no GPU support in its A13 status | Very high, after basic display | Firmware, command submission, memory management, kernel driver and Mesa stack |
| Cellular / SEP / cameras | Outside first Linux platform milestone | Deferred | Interfaces and security boundaries are not part of initial scope |

## Addressing and device-tree policy

This document deliberately does not publish guessed MMIO base addresses, RAM ranges, interrupt numbers, clock IDs, or reset values. Existing device trees and reverse-engineered descriptions are research inputs, not automatically trusted AetherOS specifications.

Before a value enters `kernel/device-tree/` or bootloader code, its record must include:

1. Exact source URL, revision, and license.
2. Device and board identifier to which the value applies.
3. Whether it is read from a device tree, observed in a driver, or inferred.
4. Independent corroboration or a reversible measurement plan.
5. Confidence, known caveats, and affected driver(s).

Do not carry over display details from the iPhone 11 Pro OLED panel to the iPhone 11 LCD. Likewise, SoC-level driver support does not prove a feature on N104AP until the board-specific wiring, firmware, and panel/controller data match.

## Evidence sources

- [Apple — iPhone 11 technical specifications](https://support.apple.com/en-us/111865)
- [Apple Platform Security — iPhone and iPad boot process](https://support.apple.com/en-ie/guide/security/secb3000f149/web)
- [Project Cascadia — A13 / iPhone 11 status](https://github.com/rzxvx/Project-Cascadia/blob/main/devices/a13/README.md)
- [Hoolock — A13 feature support](https://github.com/yhavry/Hoolock-Docs-A13/blob/master/features/A13.md) (SoC and iPhone 11 Pro details are not assumed to apply to the iPhone 11 panel)
- [Linux — Booting AArch64 Linux](https://docs.kernel.org/arch/arm64/booting.html)
