---
agent_id: larry
session_id: archlinux-encryption-and-cleanup
timestamp: 2026-08-09T22:49:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Arch Linux Encryption Procedure + Code Cleanup

## Context

David returned to continue the CachyOS reinstall project. The pyinfra package modules (cosmic.py, hyprland.py, plasma.py) were completed as homework from the Aug 7 session. This session focused on cleaning up the pyinfra codebase and creating the Storage partition encryption procedure.

## What we did

- Larry reviewed the three new pyinfra package modules (cosmic.py, hyprland.py, plasma.py) and the deploy.py structure.
- Larry identified that deploy.py was missing hyprland and plasma imports — fixed by adding hyprland, removing plasma (David only plans to use COSMIC + Hyprland).
- Larry found unnecessary `global packages` statements across all 11 package files. Explained Python scoping rule: `global` is only needed for reassignment, not reads. Removed all `global` statements from every package file.
- Larry reviewed the full archlinux refactor project: bash scripts (fullinstall, vmpartition, mkfilesystems, baseos.sh, postinstall, snapper_install), systemd mount units, pyinfra modules.
- David requested the Storage partition encryption + TPM2 auto-unlock procedure. Larry created `scripts/ENCRYPT-STORAGE-AND-TPM2.md`.
- David requested fstab vs systemd mount comparison. Larry recommended systemd units for the dependency chain (LUKS → mapper → storage mount → bind mounts).
- Updated the procedure to use systemd mount units exclusively. Updated `Storage-dabrown.mount` and `Storage-Backups.mount` to use `/dev/mapper/storage` with `dev-mapper-storage.device` dependency.

## Decisions made

- **Question:** Install COSMIC, Hyprland, or Plasma?
  **Decision:** COSMIC + Hyprland only. Plasma removed from deploy.py but plasma.py kept in packages/ for future use.

- **Question:** fstab or systemd mount units for Storage?
  **Decision:** Systemd mount units. Clean dependency chain for LUKS unlock → mapper → storage → bind mounts. No fstab entries for Storage.

- **Question:** Where does the encryption procedure live?
  **Decision:** `scripts/ENCRYPT-STORAGE-AND-TPM2.md` in the archlinux refactor project, not as a myPKA SOP (project-specific, not team-wide).

## Insights

- **Python `global` misconception:** David thought `global` was needed to read module-level variables inside functions. It's only needed for reassignment. All 11 package files had unnecessary `global` statements — cleaned up.
- **Mount unit dependency chain:** The existing bind mounts (`home-dabrown-*.mount`) already depended on `Storage-dabrown.mount`. Updating `Storage-dabrown.mount` to use the LUKS mapper device propagates the dependency automatically — no changes needed to the 10+ bind mount units.

## Realignments

- None this session.

## Open threads

- [ ] David's full install execution: base install → secure boot → TPM → Storage encryption → pyinfra → chezmoi
- [ ] Broken symlink: `~/.config/systemd/user/default.target.wants/home-dabrown-Music.mount`
- [ ] `swaync.service` failure cleanup (Hyprland leftover)
- [ ] `epson-inkjet-printer-escpr2` PGP signature issue from chaotic-aur

## Next steps

- David executes the base CachyOS install with LUKS + Secure Boot + TPM
- Then runs the Storage encryption procedure
- Then runs pyinfra deploy
- Then configures chezmoi for user dotfiles

## Cross-links

- `[[2026-08-07-18-00_larry_cachyos-reinstall-planning]]` — Previous session: homework assigned, decisions made
- `[[2026-07-08-cachyos-secure-boot-success]]` — Secure Boot procedure reference
- `[[2026-07-08-cachyos-secureboot-tpm-vm-testing]]` — Secure Boot troubleshooting
