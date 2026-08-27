---
agent_id: larry
session_id: cachyos-secureboot-tpm-vm-testing
timestamp: 2026-07-08T18:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# CachyOS Secure Boot + TPM2 VM Testing

## Context

David wanted to test the full Secure Boot + TPM2 auto-unlock procedure in a QEMU VM before applying it to his physical laptop. This session involved extensive troubleshooting of QEMU/OVMF display issues, getting sbctl to detect UEFI in the VM, and creating a comprehensive guide.

## What we did

- Updated `setup-test-vm.sh` to support `--secure-boot` flag that switches OVMF firmware, machine type, and VGA adapter
- Added `--display=` flag for display backend selection
- Added `--dry-run` and `--diag` flags for debugging
- Added `test-display` command for quick display testing
- Discovered `q35` machine type is required for Secure Boot pflash (not `pc/i440fx`)
- Discovered `-vga std` required for Secure Boot OVMF (virtio display doesn't work)
- Discovered `-bios` flag doesn't expose efivars to guest (sbctl can't detect UEFI)
- Discovered `--firmware-builtin` flag fails in QEMU (use `--microsoft` only)
- Discovered initramfs is not a PE file (skip signing it)
- Successfully got sbctl to detect UEFI and enrolled Secure Boot keys in VM
- Created comprehensive guide: `SECURE-BOOT-AND-TPM-GUIDE.md`
- Reset VARS file preservation to keep enrolled keys across reboots

## Decisions made

- **Question:** How to handle Secure Boot OVMF in QEMU?
  **Decision:** Use `q35` machine type with pflash (`OVMF_CODE.secboot.4m.fd` + `OVMF_VARS.4m.fd`). The combined `OVMF.4m.fd` via `-bios` works for display but doesn't expose efivars.

- **Question:** How to handle display with Secure Boot?
  **Decision:** Use `-vga std` for Secure Boot mode. Display resizing doesn't work well, but it's acceptable for testing. Install CachyOS in non-Secure Boot mode first (where `-vga virtio` works), then switch to Secure Boot for testing.

- **Question:** Should OVMF VARS be preserved across reboots?
  **Decision:** Yes. The script now only copies fresh VARS if the file doesn't exist, preserving enrolled Secure Boot keys.

## Insights

- The Secure Boot OVMF (`OVMF_CODE.secboot.4m.fd`) requires `q35` machine type for proper pflash initialization
- `sbctl` checks for Secure Boot variables (PK, KEK, db, dbx) to detect UEFI — non-Secure-Boot OVMF doesn't have these
- QEMU's `-bios` flag loads firmware into guest memory without exposing UEFI variable storage
- The CachyOS wiki recommends `--disable-shim-lock` for GRUB-based Secure Boot (no Shim needed)
- PCR 7 (Secure Boot state) is the core PCR for TPM2 auto-unlock — changes if boot chain is tampered

## Realignments

- Initially tried `-bios OVMF.4m.fd` for Secure Boot — worked for display but sbctl couldn't detect UEFI
- Initially used `--firmware-builtin` flag — failed in QEMU because firmware default keys don't exist
- Initially tried to sign initramfs — failed because it's not a PE file

## Open threads

- [ ] Complete CachyOS reinstall in VM (David handling)
- [ ] Test full Secure Boot setup procedure in VM after reinstall
- [ ] Test TPM2 auto-unlock procedure in VM
- [ ] Apply procedure to physical laptop after VM testing succeeds

## Next steps

- David reinstalls CachyOS in VM (non-Secure Boot mode)
- Boot with `--secure-boot` and follow the guide
- Test sbctl key enrollment and GRUB signing
- Test TPM2 auto-unlock with systemd-cryptenroll
- Once verified in VM, apply to physical laptop

## Cross-links

- [[2026-07-07-larry-cachyos-vm-and-mypka-onboarding]] — Previous session on CachyOS VM setup
