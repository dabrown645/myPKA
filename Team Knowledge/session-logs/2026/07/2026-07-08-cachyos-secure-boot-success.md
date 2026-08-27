---
agent_id: larry
session_id: cachyos-secure-boot-success
timestamp: 2026-07-08T20:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# CachyOS Secure Boot — Finally Working

## Context

David picked up from the previous session where Secure Boot was failing with "not authorized" after key enrollment. The issue turned out to be VARS file confusion — the script uses separate VARS files for Secure Boot and non-Secure Boot modes, and the enrollment sequence needed clarification. David did a full clean reinstall and followed the correct sequence.

## What we did

- Larry diagnosed the "not authorized" boot failure — likely caused by Secure Boot being enabled in firmware before keys were enrolled, or VARS file mismatch
- Larry clarified the two-VARS-file architecture (one per mode) and the correct enrollment sequence
- David did a full delete and reinstall of CachyOS (non-Secure Boot)
- David booted with `--secure-boot`, entered UEFI at boot screen, deleted all Secure Boot variables (Setup Mode)
- David booted into CachyOS, installed sbctl/mokutil/limine-mkinitcpio-hook
- David ran `sbctl create-keys`, `sbctl enroll-keys --microsoft`, `limine-enroll-config`, `limine-update`
- David rebooted into UEFI, enabled Secure Boot to Standard
- **Secure Boot now works** — `sbctl status` shows Secure Boot: Enabled
- Larry explained TPM2 auto-unlock behavior with mode switching (PCR 7)

## Decisions made

- **Question:** What causes "not authorized" on Secure Boot?
  **Decision:** The sequence matters — you must be in Setup Mode (variables deleted) BEFORE enrolling keys. If Secure Boot is already enabled when keys are enrolled, or if the VARS file is wrong, the boot chain fails.

- **Question:** Can you switch between Secure Boot and non-Secure Boot modes?
  **Decision:** Yes, each mode has its own VARS file. Switch freely before TPM2 setup. After TPM2 enrollment, switching modes causes TPM to ask for recovery key (PCR 7 changes). Switching back restores auto-unlock.

## Insights

- The "not authorized" error was caused by the firmware having Secure Boot enabled before the user's keys were enrolled — the signed Limine binary wasn't signed by Microsoft's default keys
- `reboot --firmware-setup` doesn't always work in QEMU — entering UEFI at the boot screen (press Escape at CachyOS logo) is more reliable
- The correct sequence is: boot `--secure-boot` → enter UEFI at boot screen → delete all Secure Boot variables → boot into OS → enroll keys → reboot into UEFI → enable Secure Boot
- `sbctl status` showing `Setup Mode: Disabled` + `Secure Boot: Disabled` after key enrollment is the correct intermediate state

## Realignments

- Larry initially thought the VARS file was being swapped incorrectly — the real issue was the enrollment sequence (keys must be enrolled AFTER entering Setup Mode, not before)

## Open threads

- [ ] Complete TPM2 auto-unlock setup (Part 3 of guide)
- [ ] Test full dual-boot with Windows disk
- [ ] Test Secure Boot + TPM2 persistence across reboots
- [ ] Apply procedure to physical laptop after VM testing succeeds

## Next steps

- David completes TPM2 auto-unlock setup (crypttab, systemd-cryptenroll, mkinitcpio hooks)
- Test auto-unlock with a reboot
- Test mode switching with TPM2 active
- Document final partition scheme for physical deployment

## Cross-links

- [[2026-07-08-cachyos-secureboot-tpm-vm-testing]] — Previous session on Secure Boot troubleshooting
- [[2026-07-07-larry-cachyos-vm-and-mypka-onboarding]] — Initial CachyOS VM setup session
