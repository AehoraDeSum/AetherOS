# Bootloader

Owns the intended AetherOS early boot stages and Linux loader. The immediate goal is a RAM-only execution proof and repeatable kernel handoff through the known lab bootstrap, while separately testing whether iBoot/iBSS/m1n1 can be removed from the final chain. Device execution constraints and the independence gate are tracked in [BOOTLOADER_RESEARCH.md](../BOOTLOADER_RESEARCH.md); the current Linux handoff is summarized in [BOOT_HANDOFF_CONTRACT.md](../docs/BOOT_HANDOFF_CONTRACT.md).

The generic stage-0 C scaffold is compile-only. An N104-specific, one-page framebuffer probe now builds as an arm64 Image-compatible payload and is packaged as a named IMG4. It has not yet been run on the device and is explicitly not an independent bootloader.
