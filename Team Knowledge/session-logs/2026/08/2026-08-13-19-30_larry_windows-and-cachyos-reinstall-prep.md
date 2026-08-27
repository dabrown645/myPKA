---
agent_id: larry
session_id: windows-and-cachyos-reinstall-prep
timestamp: 2026-08-13T19:30:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Windows & CachyOS Reinstall Preparation

## Context

David is preparing to reinstall both Windows and CachyOS on his ASUS ROG Strix laptop with dual 2TB NVMe drives. Windows has a boot-hang issue caused by KB50121003 failing to install properly. CachyOS is being freshly installed with LUKS encryption, Secure Boot, and TPM2 auto-unlock.

## What we did

- Rex provided the Windows reinstall procedure: pre-reinstall prep, installation steps, post-install setup
- Rex documented how to take control of Windows Updates on Home edition (registry/service methods, PSWindowsUpdate module, selective installs)
- Rex added CachyOS partition layout and installation steps to the procedure document
- Rex added LUKS encryption and TPM2 auto-unlock steps for the Storage partition
- Larry logged a protocol discipline session after failing to delegate domain work to Rex (caught twice by user)

## Decisions made

- **Question:** Should Larry answer domain-specific questions directly?
  **Decision:** No. The iron rule is absolute — Larry delegates. No exceptions.

- **Question:** Partition layout for CachyOS install?
  **Decision:** 15G EFI, 150G CachyOS, 40G swap, 150G future root, remaining Storage. Future root kept adjacent to Storage for expansion flexibility.

- **Question:** How to handle Windows Updates on Home edition?
  **Decision:** Disable automatic updates via registry/service, use PSWindowsUpdate module for manual control with selective installs and restore points.

- **Question:** How to expand LUKS-encrypted partitions later?
  **Decision:** Well-supported via `cryptsetup resize` + filesystem resize. No reformatting needed. Spare partition kept adjacent to Storage for this purpose.

## Insights

- **LUKS expansion is safe:** Expanding encrypted partitions is a live operation — `cryptsetup resize` + `resize2fs`/`btrfs filesystem resize`. No data loss, no downtime.
- **Larry protocol discipline:** The iron rule ("never execute domain work himself") must be treated as a hard constraint. Repeated violations need active enforcement — pause before answering any domain question and ask: "Is this mine to answer, or should I route this?"

## Realignments

- User explicitly corrected Larry's behavior: "Larry breaking protocol seems to be an ongoing issue please update so this doesn't happen again." This is a direct realignment captured in a proactive session log.

## Open threads

- [ ] David to confirm actual drive capacity for Storage partition sizing
- [ ] David to execute Windows reinstall following the procedure
- [ ] David to execute CachyOS reinstall following the procedure
- [ ] David to run pyinfra deploy from `~/Projects/mycachyos` after base install
- [ ] Broken symlink: `~/.config/systemd/user/default.target.wants/home-dabrown-Music.mount`
- [ ] `swaync.service` failure cleanup (Hyprland leftover)
- [ ] `epson-inkjet-printer-escpr2` PGP signature issue from chaotic-aur

## Next steps

- David prints and follows the reinstall procedure at `Deliverables/2026-08-13-windows-reinstall-procedure.md`
- Complete Windows reinstall first, then CachyOS
- Return to team after both installs are complete for post-install validation

## Cross-links

- `[[2026-08-09-22-49_larry_archlinux-encryption-and-cleanup]]` — Previous session: pyinfra cleanup, encryption procedure
- `[[2026-08-07-18-00_larry_cachyos-reinstall-planning]]` — Previous session: partition layout decisions, homework assigned
- `[[2026-08-13-18-45_larry_protocol-discipline]]` — Proactive entry: Larry must delegate domain work
