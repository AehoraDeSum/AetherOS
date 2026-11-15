# Distribution

Planned scope: ARM64 root filesystem, package recipes, image creation, release metadata, updates, persistence, and recovery. Alpine Linux with APK is the initial candidate, pending package, driver, and firmware licensing review.

## Priority and install boundary

The immediate target is a reproducible, bootable RAM image with a minimal init, a usable shell, logs, and a recovery path. XFCE/VNC is only a confirmed reference environment; Aether Shell personalization is deferred.

After RAM boots and kernel handoffs are repeatable, evaluate a persistent install path and update/rollback flow. Do not write to the iPhone's internal storage until boot reliability, backup/restore, and recovery are demonstrated and the user makes a separate decision. External build storage is for source and artifacts; it is not by itself a device installation target.
