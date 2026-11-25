# AetherOS

AetherOS is an experimental Linux-based platform for the iPhone 11 (Apple A13 / T8030), with its own boot stages, hardware enablement, and distribution. A Cascadia-based Linux/XFCE reference image boots on the device, but AetherOS's own stage 0 and kernel handoff are not yet device-validated. Desktop customization is deferred while bootability, reproducible images, persistence, and recovery take priority.

## Start here

- [Project charter](PROJECT_CHARTER.md)
- [Software architecture](AETHEROS_ARCHITECTURE.md)
- [iPhone 11 hardware specification](A13_HARDWARE_SPEC.md)
- [Bootloader research and go/no-go gate](BOOTLOADER_RESEARCH.md)
- [Boot and distribution roadmap](docs/ROADMAP.md)
- [Current device reference baseline](docs/REFERENCE_BASELINE.md)
- [Contribution and branch conventions](CONTRIBUTING.md)

## Build the stage-0 scaffold

On an Apple Silicon Mac with Xcode Command Line Tools installed:

```sh
make bootloader
```

This compiles the generic AArch64 ELF scaffold into `build/bootloader/stage0/`. It does not link or sign a device image, communicate with a phone, alter firmware, or write to device storage. Separately, `make stage0-probe` builds a small N104 Image-compatible framebuffer marker; it is not a complete bootloader and is awaiting its first device trial.

Remove generated files with `make clean`.

## Current engineering gate

The user has authorized usbliter8 as a tethered, lab-only bootstrap candidate. The m1n1-to-Linux entry contract is now documented, and a RAM-only AetherOS framebuffer probe is prepared as a named IMG4. The next device gate is to boot that probe through the known lab path and observe its marker. This would prove only the handoff payload, not remove iBoot/iBSS or m1n1. The long-term independent boot path remains a separate feasibility gate; document a no-go early if device constraints prevent it. See [BOOTLOADER_RESEARCH.md](BOOTLOADER_RESEARCH.md) and [BOOT_HANDOFF_CONTRACT.md](docs/BOOT_HANDOFF_CONTRACT.md).

Until that gate is resolved, keep device experiments read-only and RAM-only. Do not write to internal storage or modify the existing iOS installation.

## License

GPL-2.0 (see [LICENSE](LICENSE)), the same as Project Cascadia and the Linux kernel. Third-party code keeps its own license; Apple firmware and IPSW-derived files are never part of this repository.
