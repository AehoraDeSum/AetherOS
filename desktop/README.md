# Aether Shell

## Current platform state

The iPhone 11 reference boot now shows the Linux text console through simpledrm, and the touchscreen produces Linux multitouch events. The current framebuffer is provided by iBoot; native N104 MIPI-DSI panel initialization is not implemented. The A13 GPU is also not yet available to the UI.

The first Aether Shell screen has now been launched on the device using Weston DRM/Pixman and Qt Quick software rendering. The user confirmed that the square launcher cards respond to taps and produce visible UI feedback. This validates the first compositor → shell → touchscreen path on the reference boot.

The current device trial has moved to a conventional live XFCE desktop. The RAM image includes XFCE 4.20, Xorg's framebuffer driver for `/dev/fb0`, Thunar, XFCE Terminal, settings, an on-screen keyboard, and x11vnc. Desktop icons and Thunar are configured for single-tap activation, which better matches touch input. Xorg/libinput routes touchscreen input; the A13 GPU is not required. Touch input, keyboard, desktop, and Mac VNC connection have been confirmed on the iPhone 11. This is a reference desktop used to exercise real Linux applications and input, not the final Aether Shell.

The Qt Quick Aether Shell remains available as the immediately previous boot image. Its updated navigable pages are still prototype UI flows; the Files and Terminal tiles do not launch applications.

## Prototype sequence

1. Build a small Qt Quick screen with touch-sized controls and a visible event counter. **Complete on device.**
2. Run it as a Wayland client under Weston using the DRM/KMS backend and Pixman software rendering. This checks the compositor, display and touch path without depending on the A13 GPU. **Complete on device; taps produce visible feedback.**
3. Package the prototype as an optional RAM-root overlay so the existing console boot remains recoverable. **Complete; the previous boot pair is backed up.**
4. Test a complete XFCE desktop session, app launching, terminal, file manager, settings, touch, on-screen keyboard, and USB VNC on the framebuffer. **Complete on device.**
5. Continue Aether Shell separately; connect its launcher to real services and applications after the desktop path is dependable.
6. Treat native DSI/backlight bring-up and GPU acceleration as separate hardware milestones.

## Prototype constraints

- Target portrait mode and the iPhone 11's 828 × 1792 framebuffer.
- Use Qt Quick's software scene-graph backend; avoid OpenGL, Vulkan, and GPU-only effects.
- Keep a way to exit the compositor and return to the Linux console.
- The first prototype is a rendering/input proof, not a complete desktop or app launcher.

## Build and run the live XFCE desktop

The live desktop root filesystem is built separately from Cascadia's normal Alpine root and packed as a RAM disk. It does not access the iPhone's internal storage.

Build and package it on the M4 Mac:

```sh
desktop/build-live-desktop-rootfs.sh
desktop/package-live-desktop.sh
```

The packaging script temporarily substitutes the desktop root archive while Cascadia makes the IMG4 pair, restores the normal Alpine root archive afterward, and preserves the currently active pair. The new default boot pair and a named copy are in Cascadia's `devices/a13/boot/out` directory:

- `m1n1-linux.rkrn.img4`
- `alpine.rdsk.img4`

The previous XFCE pair without VNC is preserved as `m1n1-linux.before-aether-vnc.rkrn.img4` and `alpine.before-aether-vnc.rdsk.img4`. The previous Qt shell pair is preserved as `m1n1-linux.before-aether-live-desktop.rkrn.img4` and `alpine.before-aether-live-desktop.rdsk.img4`; the earlier console-only pair remains as `m1n1-linux.before-aether-shell-preview.rkrn.img4` and `alpine.before-aether-shell-preview.rdsk.img4`. The regular Alpine archive at `devices/a13/build/alpine-a13.tar.gz` stays unchanged.

Boot the iPhone through the usual usbliter8 procedure. In its Linux serial shell, run:

```sh
/usr/local/bin/aether-live-desktop
```

Wait about 20 seconds for XFCE. Try the panel and app menu, launch Thunar and XFCE Terminal, tap around the desktop, and type with the on-screen keyboard. To stop XFCE and return to the Linux framebuffer console, run:

```sh
/usr/local/bin/aether-stop-desktop
```

To mirror and control the current Xorg display from the Mac, set a VNC password in the serial shell and start the USB-only VNC server:

```sh
mkdir -p /root/.vnc
x11vnc -storepasswd /root/.vnc/passwd
/usr/local/bin/aether-vnc
```

On the Mac, open `vnc://172.16.42.1:5900` in Screen Sharing. The VNC server binds only to Cascadia's USB Ethernet address and requires that password; it is not exposed on Wi-Fi. The current Xorg session has no Xauthority file, so the VNC helper uses `/dev/null` for local X access. Stop it from the serial shell with `/usr/local/bin/aether-stop-vnc`.

If XFCE does not appear, stop it from the serial shell and inspect `/tmp/aether-xfce.log` before retrying.

To switch Cascadia's next boot back to the immediately previous Qt shell pair on the Mac:

```sh
cd /Volumes/swxc/aetheros/Project-Cascadia/devices/a13/boot/out
cp -p m1n1-linux.before-aether-live-desktop.rkrn.img4 m1n1-linux.rkrn.img4
cp -p alpine.before-aether-live-desktop.rdsk.img4 alpine.rdsk.img4
```

The desktop still relies on Cascadia's usbliter8/iBSS/m1n1 path and iBoot's simpledrm framebuffer. It does not demonstrate AetherOS's independent bootloader, native DSI panel initialization, or GPU acceleration. The XFCE profile's Xorg framebuffer configuration follows the existing Cascadia A13/A5 framebuffer desktop work.

The Qt Quick software adaptation renders the scene graph with Qt's raster paint engine, and Weston supports a Pixman CPU renderer and a standalone DRM/KMS backend. Those make a software-only prototype possible before the A13 GPU driver is ready. Sources: [Qt Quick software adaptation](https://doc.qt.io/qt-6/qtquick-visualcanvas-adaptations-software.html), [Weston running documentation](https://wayland.pages.freedesktop.org/weston/toc/running-weston.html).
