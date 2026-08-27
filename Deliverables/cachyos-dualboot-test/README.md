# CachyOS Dual-Boot QEMU Test Environment

**Status:** Active - In Testing  
**Created:** 2026-07-07  
**Owner:** David  

## Purpose

Test CachyOS dual-boot installation alongside Windows in a virtualized environment before deploying to physical hardware. Validates UEFI boot, partition scheme, and bootloader behavior with Secure Boot + TPM 2.0.

## What This Tests

- CachyOS live boot from ISO
- UEFI firmware behavior (standard OVMF, no Secure Boot during install)
- TPM 2.0 emulation (swtpm)
- Dual-disk setup: `win.qcow2` (Windows) + `cachy.qcow2` (CachyOS)
- Boot menu access via ESC/F12

## Prerequisites

```bash
# Required packages
sudo pacman -S qemu-full swtpm edk2-ovmf

# Verify OVMF firmware exists
ls /usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd
```

## Usage

```bash
# Launch with CachyOS ISO (for installation)
./setup-test-vm.sh launch ~/VMS/cachyos-latest-desktop/cachyos-desktop-linux-260628.iso

# Launch without ISO (boot from installed disk)
./setup-test-vm.sh launch

# Check VM disk state
./setup-test-vm.sh status

# Reset everything and start fresh
./setup-test-vm.sh destroy
```

## VM Specifications

| Setting | Value |
|---------|-------|
| Machine | pc/i440fx (UEFI) |
| Secure Boot | DISABLED (for initial install) |
| TPM 2.0 | ENABLED (swtpm emulator) |
| RAM | 8GB |
| CPUs | 4 |
| Disk 1 | win.qcow2 (40GB) |
| Disk 2 | cachy.qcow2 (40GB) |
| Display | SDL (standard VGA) |

## Boot Controls

- **ESC**: UEFI boot menu (when CachyOS logo appears)
- **F12**: Device selection menu

## Current State

- [x] Script created and tested
- [x] OVMF firmware configured (standard, no Secure Boot)
- [x] TPM 2.0 working
- [ ] CachyOS installed on cachy.qcow2
- [ ] Windows installed on win.qcow2
- [ ] Dual-boot verified
- [ ] Secure Boot enabled post-install (optional)

## Next Steps (Refinement TODO)

1. **Complete CachyOS installation** - Finish the current install process
2. **Test Windows coexistence** - Verify Windows still boots after CachyOS install
3. **GRUB configuration** - Confirm CachyOS GRUB detects Windows
4. **Secure Boot enrollment** - Enable Secure Boot after OS install and enroll CachyOS keys
5. **Partition scheme documentation** - Document final partition layout for physical deployment
6. **Boot partition testing** - Test recovery scenarios (boot repair, GRUB rebuild)

## Technical Notes

- Uses standard OVMF (`OVMF_CODE.4m.fd`) - Secure Boot requires Fedora OVMF (`edk2-ovmf-fedora` from AUR) which is broken per ArchWiki
- `-vga std` required for UEFI boot display (virtio-gpu needs OS drivers)
- swtpm provides TPM 2.0 emulation for BitLocker/TPM-bound features
- NVRAM state preserved in `OVMF_VARS.4m.fd` across reboots

## File Structure

```
cachyos-dualboot-test/
├── README.md              # This file
├── setup-test-vm.sh       # Main VM launch script
└── ~/VMS/qemu-cachyos-test/   # VM runtime directory (created by script)
    ├── disks/
    │   ├── win.qcow2
    │   └── cachy.qcow2
    ├── tpm/
    │   └── swtpm-sock
    ├── OVMF_CODE.4m.fd
    └── OVMF_VARS.4m.fd
```

## Issues Encountered & Fixes

### "Display output is not active" / "Guest has not initialized the display (yet)"
- **Cause**: `-vga virtio` requires OS GPU drivers not available during UEFI boot
- **Fix**: Changed to `-vga std` for UEFI compatibility

### Secure Boot blocking CachyOS boot
- **Cause**: Fedora OVMF Secure Boot shim doesn't recognize CachyOS signing key
- **Fix**: Use standard OVMF (no Secure Boot) for initial install

---

*Project will be refined as testing progresses. Add findings to this document.*
