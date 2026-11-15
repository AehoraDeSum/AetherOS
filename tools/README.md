# Tools

Host-side build, image inspection, and source-provenance helpers will live here. Add tools only with a documented input/output contract and reproducible version requirements.

## N104 handoff probe

Build the AetherOS-owned framebuffer marker with `make stage0-probe`, then
create a named, RAM-only Cascadia IMG4 with
`tools/package-n104-handoff-probe.sh`. The packager saves and restores the
normal Cascadia kernel payload and active kernel/ramdisk outputs. It does not
boot the phone. The probe halts after painting the screen and still depends on
the full current usbliter8 → iBSS/iBoot → m1n1 chain; it is not an independent
bootloader. Read [the boot handoff contract](../docs/BOOT_HANDOFF_CONTRACT.md)
before using it.
