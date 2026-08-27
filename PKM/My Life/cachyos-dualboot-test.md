---
name: CachyOS Dual-Boot Test
status: paused
target_date: 2026-07-15
key_element: computing
linked_goals: []
tags:
  - linux
  - cachyos
  - dual-boot
  - vm
  - secure-boot
---

# CachyOS Dual-Boot Test

## Why this matters

Test CachyOS dual-boot installation alongside Windows in a virtualized environment before deploying to physical hardware. Validates UEFI boot, partition scheme, and bootloader behavior with Secure Boot + TPM 2.0.

## Status update

**2026-07-08:** Secure Boot fully working in VM. Clean reinstall of CachyOS, enrolled keys via sbctl, Limine signed, Secure Boot enabled and verified. TPM2 auto-unlock setup pending.

**Issues resolved:**
- Secure Boot was blocking CachyOS boot → switched to standard OVMF
- Display output issue → was actually Secure Boot, not display driver
- "not authorized" error on Secure Boot boot → correct sequence: enter Setup Mode (delete variables) BEFORE enrolling keys
- VARS file confusion → script uses separate VARS per mode, enrollment must happen in the correct mode's VARS

**Completed:**
- [x] CachyOS installation on virtual disk
- [x] Secure Boot key enrollment (sbctl create-keys, enroll-keys, limine-enroll-config, limine-update)
- [x] Secure Boot enabled and verified

**Remaining work:**
- TPM2 auto-unlock setup (crypttab, systemd-cryptenroll, mkinitcpio hooks)
- Test Windows coexistence
- Test Secure Boot + TPM2 persistence across reboots
- Apply procedure to physical laptop

## Open threads

- Complete TPM2 auto-unlock setup
- Test dual-boot with Windows disk
- Document final partition layout for physical deployment

## Next steps

- [ ] Set up TPM2 auto-unlock (Part 3 of guide)
- [ ] Test auto-unlock with reboot
- [ ] Test mode switching with TPM2 active
- [ ] Document partition scheme

## Artifacts

- [[Deliverables/cachyos-dualboot-test/README|VM Setup Documentation]]
- [[Deliverables/cachyos-dualboot-test/setup-test-vm|Launch Script]]
