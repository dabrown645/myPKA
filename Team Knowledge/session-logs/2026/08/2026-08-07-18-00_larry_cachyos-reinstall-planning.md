---
agent_id: larry
session_id: cachyos-reinstall-planning
timestamp: 2026-08-07T18:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# CachyOS Reinstall Planning Session

## Context

David returned to work on installation scripts for CachyOS. He has a pyinfra-based project at `~/Public/archlinux/refactor/pyinfra/` that automates package installation. He is planning a fresh CachyOS install on his ASUS ROG Strix laptop with dual 2TB NVMe drives, and wants to get the full configuration right before reinstalling.

## What we did

- Larry reviewed the full pyinfra project structure: deploy.py, inventory.py, 10 package modules, and legacy scripts.
- Larry identified that `inventory.py` has a syntax error (unclosed bracket) but David clarified that `pyinfra @local deploy.py` bypasses inventory entirely — inventory.py can be deleted.
- Larry incorrectly said duplicate `additional_packages` in distrobox.ini was last-wins — user corrected that distrobox docs say it's additive (confirmed).
- Larry created `User Knowledge/Cheatsheets/` folder and moved the COSMIC keybindings cheatsheet from project root, adding multi-monitor shortcuts.
- Larry failed to route the distrobox/sysadmin question to Rex — user caught this and Larry recorded the routing lesson in a session log.
- Larry investigated David's full system: partition layout, systemd services, chezmoi repo, secure boot/TPM setup, display managers, Hyprland and COSMIC configurations.
- Discussed LUKS encryption for storage partition — David cannot encrypt in-place, but since he's reinstalling anyway, LUKS setup during install is the clean path.
- Discussed polkit differences — Hyprland uses `hyprpolkitagent`, COSMIC handles polkit internally through `cosmic-settings-daemon`.
- Discussed pyinfra vs chezmoi boundary: pyinfra handles packages + system config, chezmoi handles user dotfiles + user-level systemd units.

## Decisions made

- **Question:** Where is the boundary between pyinfra and chezmoi?
  **Decision:** pyinfra handles packages, system-level mounts, linger. Chezmoi handles user dotfiles, systemd user services, bin scripts, user-level bind mounts.

- **Question:** How to switch between Hyprland and COSMIC?
  **Decision:** SDDM as display manager with session switching. Both Hyprland and COSMIC packages installed, selectable at login.

- **Question:** Should Secure Boot + TPM setup be automated?
  **Decision:** Manual procedure, following the existing `SECURE-BOOT-AND-TPM-GUIDE.md`. Pyinfra handles post-install only.

- **Question:** Storage partition encryption?
  **Decision:** LUKS on both root and storage, set up during base install. TPM2 auto-unlock for both. Clean path since reinstalling anyway.

## Insights

- **Pyinfra scope limitation:** Pyinfra can't handle partitioning or base install — it runs on an installed system. It's strictly a post-install automation layer.
- **Hyprland + COSMIC coexistence:** Both DEs need their polkit agents handled correctly. Hyprland needs `hyprpolkitagent` as a separate agent; COSMIC bundles its polkit rules in `cosmic-settings-daemon`. SDDM session switching should handle launching the correct agent.
- **Partition layout:** David has `cachyos` (140GB) and `root` (150GB) partitions. He'll install on `cachyos` and keep `root` as a spare/option to expand storage later.

## Realignments

- Larry initially suggested pyinfra should handle `/Storage/dabrown` and `/Storage/Backups` mount setup. David confirmed that's correct — pyinfra handles system-level mounts, not chezmoi.
- Larry initially missed the routing to Rex for the distrobox question. David corrected: routing is Larry's responsibility, not something the user should have to specify. This was recorded in a session log.

## Open threads

- [ ] David's homework: Fresh base CachyOS install (no DE) → get package list → add Hyprland + noctalia → diff → add COSMIC → diff. This becomes the source of truth for pyinfra package modules.
- [ ] Fix broken symlink: `~/.config/systemd/user/default.target.wants/home-dabrown-Music.mount` points to non-existent file.
- [ ] `epson-inkjet-printer-escpr2` PGP signature issue from chaotic-aur — may resolve itself on next run, or may need key trust investigation.
- [ ] The `swaync.service` failure — leftover from Hyprland, not relevant under COSMIC. Should be cleaned up.
- [ ] `hyprdynamicmonitors.service` — Hyprland-specific, not relevant under COSMIC. Keep in chezmoi for Hyprland sessions.

## Next steps

- David completes package list homework (base, base+Hyprland, base+COSMIC diffs)
- Return to planning with package lists to build out the pyinfra modules and full installation plan
- Then execute: base install → secure boot → TPM → pyinfra → chezmoi

## Cross-links

- `[[2026-08-07-10-00_larry_cosmic-cheatsheet-and-routing-lesson]]` — routing lesson and Cheatsheets folder creation
- `[[2026-07-08-cachyos-secure-boot-success]]` — Secure Boot success in VM
- `[[2026-07-08-cachyos-secureboot-tpm-vm-testing]]` — Secure Boot troubleshooting
- `[[cachyos-dualboot-test]]` — Project file for the dual-boot test
