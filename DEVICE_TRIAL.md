# iPhone 11 Reference Device Trial

**Status (2026-11-15):** Cascadia boots Linux 7.2.0-rc1 on the iPhone 11 through the RP2350 usbliter8 path. A Qt Quick touch screen was confirmed working through Weston DRM/Pixman. The live XFCE 4.20 desktop is confirmed on-device, including touchscreen pointer control, icon dragging, on-screen keyboard, single-tap activation, and password-protected VNC from the Mac over USB. The user reports the latest desktop/VNC setup works smoothly. This remains a Cascadia reference boot, not an AetherOS boot.

## Confirmed on device

- Target: iPhone 11 / iPhone12,1 / N104AP / T8030.
- Entry path: DFU → usbliter8 → patched iBSS → m1n1 → Linux. The generic AetherOS Stage 0 remains a compile-only scaffold; a separate RAM-only framebuffer probe is packaged but has not yet been tried on the device. The independent bootloader goal remains open.
- Kernel: AArch64 Linux 7.2.0-rc1, 16K-page Hoolock configuration with Cascadia changes.
- Root filesystem: Alpine is loaded in RAM. The current image does not request an internal-storage erase or install.
- Display: the Linux text console is visible through simpledrm using the framebuffer left by iBoot. This confirms framebuffer output, not native MIPI-DSI panel initialization.
- Touch: the driver now requests active-low AP GPIO 197, holds the controller in reset while enabling its rails, and releases it before the HBPP handshake. It skips the final HBPP ACK after `0x10003400 = 1`, because the controller is already entering firmware at that point.
- Touch result: the kernel logged `firmware running`; reading `/dev/input/event1` while tapping produced `ABS_MT_TRACKING_ID`, `ABS_MT_POSITION_X`, `ABS_MT_POSITION_Y`, and `ABS_MT_WIDTH_MAJOR` events.
- Graphics and UI: Weston 14.0.2 opened `/dev/dri/card0`, selected the Pixman renderer, enabled the 828 × 1792 simpledrm output, and discovered the touchscreen. The Qt Quick preview reached the phone display; the user confirmed tapping the square launcher cards produces visible UI feedback.
- Earlier live desktop: Cascadia's A13 research log records XFCE with multi-touch on this phone on 2026-10-31. The current AetherOS trial repackages Alpine 3.24 with XFCE 4.20, Xorg `fbdev` on `/dev/fb0`, Thunar, XFCE Terminal, and `svkbd` for a full touch-oriented desktop session.
- User-observed XFCE input: virtual keyboard taps work, touchscreen moves the pointer, desktop icons can be dragged, and single-tap activation is configured. The user confirmed the latest VNC connection works from macOS. Apparent screen overflow was attributed by the user to physical display damage; no XFCE layout defect is confirmed.
- Handoff probe: `make stage0-probe` builds a one-page AArch64 Image-compatible marker; `tools/package-n104-handoff-probe.sh` creates the named IMG4 without changing the active boot pair. A green screen would confirm AetherOS-owned code at the m1n1 → Linux handoff only. The probe has not yet been run on-device and halts before Linux.
- The above kernel changes live in `/Volumes/swxc/aetheros/Project-Cascadia/devices/a13/kernel/extras/apple_hidspi_touch.c`. The latest packaged image is `/Volumes/swxc/aetheros/Project-Cascadia/devices/a13/boot/out/m1n1-linux.rkrn.img4`.

## Storage and recovery boundary

- Keep the iOS installation intact. Do not mount `/dev/nvme0n1` or its partitions from Linux, and do not run Cascadia's storage setup or erase workflow.
- Continue using RAM-root boots for experiments. The phone's NVMe may be detected by Linux even when the root filesystem is in RAM; detection is not permission to mount or write it.
- To return to iOS, force-restart with Volume Up, Volume Down, then hold Side until the Apple logo appears. Do not restore or repartition the phone as part of this trial.

## Current display plan

The text console and touch input provide a usable base for a software-rendered desktop trial. The Qt Quick milestone ran over Weston; the current XFCE image uses Xorg `fbdev` over the same iBoot-provided simpledrm framebuffer. Native `disp0` / MIPI-DSI initialization for the N104 `lcd,pinot` panel, backlight control, and A13 GPU acceleration remain separate, unvalidated work.

Use Weston only as a temporary Wayland compositor during the prototype trial; Aether Shell remains the project UI. Do not change panel power or display-controller registers while validating the software UI path.

## Live desktop and Aether Shell trials

The Qt Quick prototype source is in `desktop/shell/`; it was confirmed on the phone using `desktop/build-shell-preview-rootfs.sh` and Weston DRM/Pixman. A separate Alpine RAM root with XFCE 4.20 is now the active boot pair. Build it with `desktop/build-live-desktop-rootfs.sh` and package with `desktop/package-live-desktop.sh`. The package includes Xorg `fbdev`, XFCE, Thunar, XFCE Terminal, on-screen keyboard, single-click configuration, and x11vnc. VNC binds only to `172.16.42.1:5900`, requires a separate VNC password, and uses `/dev/null` for the current Xorg session's local authority setting. The latest single-click/VNC image is confirmed working on the device.

After booting through the existing usbliter8 route, start `/usr/local/bin/aether-live-desktop` from the Linux serial shell. Stop it with `/usr/local/bin/aether-stop-desktop`. Set a separate VNC password with `x11vnc -storepasswd /root/.vnc/passwd`, start mirroring with `/usr/local/bin/aether-vnc`, then open `vnc://172.16.42.1:5900` in macOS Screen Sharing. The helper uses `/dev/null` for the current Xorg session, which has no Xauthority file, while retaining VNC password authentication and the USB-only bind. Stop mirroring with `/usr/local/bin/aether-stop-vnc`. The `.before-aether-vnc` pair keeps the previously working XFCE image; `.before-aether-live-desktop` keeps the confirmed Qt Quick pair; `.before-aether-shell-preview` keeps the earlier console pair. The regular Alpine root archive and internal phone storage are unchanged. See `desktop/README.md` for the full boot and recovery steps.

## Lab location

- Cascadia: `/Volumes/swxc/aetheros/Project-Cascadia`
- Host environment: `/Volumes/swxc/aetheros/lab/env.sh`
- External build storage: `/Volumes/swxc/aetheros`
