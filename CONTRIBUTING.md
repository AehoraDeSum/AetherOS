# Contributing to AetherOS

## Branches

- Keep `main` in a documented, buildable state.
- Use short-lived topic branches named for their area, such as `docs/boot-gate`, `boot/stage0-contract`, `kernel/a13-config`, or `desktop/aether-shell`.
- Review changes before merging them to `main`; do not force-push shared branches.

## Change expectations

- Keep each change within one component boundary where practical.
- Update the relevant architecture or hardware record when an interface, assumption, or source provenance changes.
- Record exact upstream revisions, licenses, notices, and local modifications before adapting external code.
- Do not add device-execution procedures that violate the project boundary in `PROJECT_CHARTER.md` or the unresolved boot gate in `BOOTLOADER_RESEARCH.md`.
- Keep generated build output out of version control. The local stage-0 compile can be reproduced with `make bootloader`.

## Current scope

The repository is in Phase 0. The stage-0 objects are compile scaffolding and are not suitable for device execution. The next device-related change must first be supported by a documented, permitted boot-entry decision.
