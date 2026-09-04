# Windows Reinstall Procedure — ROG Strix

**Date:** 2026-08-13
**Prepared by:** Rex
**Reason:** KB50121003 failing to install properly, causing boot hangs requiring recovery mode to restore boot functionality.

---

## Phase 1: Pre-Reinstall Prep (Do This First)

### 1.1 Back Up Critical Data

- [ ] Copy personal documents, photos, and important files to an external drive or cloud storage
- [ ] Export browser bookmarks (or confirm sync is enabled and up to date)
- [ ] Back up any local databases, game saves, or config files you care about
- [ ] Export email if using a local client (Outlook PST, Thunderbird profile, etc.)

### 1.2 Record Your Installed Apps

- [ ] Open PowerShell as Administrator
- [ ] Run: `winget list > "$HOME\Desktop\installed-apps.txt"`
- [ ] Save this file to your external drive — it's your reinstall checklist

### 1.3 Gather Licenses & Keys

- [ ] Product keys for any paid software (Office, Adobe, etc.)
- [ ] Note any app-specific logins or activation procedures
- [ ] Check Microsoft Store for previously purchased apps tied to your account

### 1.4 Prepare Windows Installation Media

- [ ] On another PC, go to [microsoft.com/software-download](https://www.microsoft.com/software-download/)
- [ ] Download the Windows Media Creation Tool
- [ ] Create a bootable USB installer (8GB+ USB drive)
- [ ] **Disconnect the second SSD** from your ROG Strix before proceeding

### 1.5 Record Your BitLocker Key (If Applicable)

- [ ] If BitLocker is enabled, save your recovery key to your Microsoft account or external storage
- [ ] Check: `manage-bde -status` in PowerShell

---

## Phase 2: Reinstall Windows

### 2.1 Boot from USB

- [ ] Insert the USB installer into the ROG Strix
- [ ] Restart and press **F2** or **Del** to enter BIOS
- [ ] Set USB as the first boot device (or press **F9** for boot menu and select USB)
- [ ] Save and exit

### 2.2 Windows Setup

- [ ] Select language, time, and keyboard → click **Next**
- [ ] Click **Install Now**
- [ ] Enter product key (or click "I don't have a product key" if upgrading)
- [ ] Select your Windows edition
- [ ] Accept license terms

### 2.3 Partition & Drive Selection (CRITICAL)

- [ ] Choose **Custom: Install Windows only (advanced)**
- [ ] You should see ONLY the single SSD (second drive is disconnected)
- [ ] Delete all partitions on the target SSD
- [ ] Select the **unallocated space** → click **Next**
- [ ] **DO NOT** create partitions manually — let Windows handle it

### 2.4 Complete Installation

- [ ] Windows will install and restart several times — this is normal
- [ ] Follow the OOBE (Out-of-Box Experience) prompts
- [ ] Sign in with your Microsoft account
- [ ] Choose privacy settings as desired

---

## Phase 3: Post-Install Setup

### 3.1 Reconnect Second SSD

- [ ] Shut down completely
- [ ] Reconnect the second SSD
- [ ] Boot up and verify it appears in **Disk Management** (`diskmgmt.msc`)
- [ ] Confirm Windows only lives on the primary SSD (check boot partition)

### 3.2 Windows Updates

- [ ] Go to **Settings → Windows Update**
- [ ] Check for and install all updates
- [ ] Restart as needed until fully up to date

### 3.3 Driver Installation

- [ ] Open **MyASUS** app (pre-installed or download from ASUS support)
- [ ] Run driver updates — especially GPU, chipset, audio, and network
- [ ] Or download drivers manually from [asus.com/support](https://www.asus.com/support/) using your model number

### 3.4 Reinstall Apps

- [ ] Open your saved `installed-apps.txt` checklist
- [ ] Reinstall apps in priority order:
  1. Browser (Chrome/Edge/Firefox) — sign in to sync
  2. Steam / gaming clients
  3. Productivity tools (Office, etc.)
  4. Communication apps (Discord, Slack, etc.)
  5. Utilities and everything else
- [ ] Restore any backed-up config files and data

### 3.5 Take Control of Windows Updates (Home Edition)

- [ ] Disable automatic updates — registry method:
  ```powershell
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
  ```
- [ ] Or disable via service:
  ```powershell
  Stop-Service wuauserv
  Set-Service wuauserv -StartupType Disabled
  ```
- [ ] Install PSWindowsUpdate module for manual control:
  ```powershell
  Install-Module PSWindowsUpdate -Force
  Import-Module PSWindowsUpdate
  ```
- [ ] Before any update, create a restore point:
  ```powershell
  Checkpoint-Computer -Description "Pre-update restore point" -RestorePointType MODIFY_SETTINGS
  ```
- [ ] Check for updates manually:
  ```powershell
  Get-WindowsUpdate
  ```
- [ ] Install selectively by KB number:
  ```powershell
  Install-WindowsUpdate -KBArticleIDs KBxxxxxxx
  ```
- [ ] If something breaks, roll back:
  ```powershell
  Restart-Computer -Restore
  ```

### 3.6 Final Checks

- [ ] Verify all drives appear correctly in Disk Management
- [ ] Test internet connection
- [ ] Test audio and display
- [ ] Confirm no boot files leaked to second SSD
- [ ] Delete the `installed-apps.txt` from desktop once done

---

## Phase 4: CachyOS Install (Second SSD)

### 4.1 Partition Layout

| Partition | Size | Filesystem | Purpose |
|-----------|------|------------|---------|
| EFI | 15G | FAT32 | Boot firmware (shared with Windows) |
| CachyOS | 150G | ext4/btrfs (LUKS) | Root filesystem |
| Swap | 40G | swap (encrypted) | Swap space |
| Future Root | 150G | Unformatted | Spare partition for future use |
| Storage | Remaining | ext4/btrfs (LUKS) | Data storage (TPM2 auto-unlock) |

**Notes:**
- EFI partition is shared — Windows and CachyOS both boot from it
- CachyOS root and Storage will be encrypted with LUKS + TPM2 auto-unlock
- Future Root partition is kept adjacent to Storage for potential expansion later
- Leave Future Root as unallocated space for maximum flexibility

### 4.2 Installation Steps

- [ ] Boot from CachyOS USB installer
- [ ] Select manual partitioning
- [ ] Create partitions per the layout above
- [ ] Encrypt CachyOS root with LUKS during install
- [ ] Complete base install (no DE)
- [ ] Follow `SECURE-BOOT-AND-TPM-GUIDE.md` for Secure Boot enrollment
- [ ] Encrypt Storage partition with LUKS:
  ```bash
  # Format with LUKS
  cryptsetup luksFormat /dev/nvmeXn1p5

  # Open the LUKS container
  cryptsetup open /dev/nvmeXn1p5 storage

  # Create filesystem
  mkfs.ext4 /dev/mapper/storage
  ```
- [ ] Set up TPM2 auto-unlock for Storage:
  ```bash
  # Enroll TPM2 for automatic unlock
  systemd-cryptenroll /dev/nvmeXn1p5 --tpm2-device=auto --tpm2-pcrs=0+1+2+3+7
  ```
- [ ] Repeat TPM2 enrollment for CachyOS root if not done during install
- [ ] ⚠️ MISSED STEP (added 2026-09-04 — this is the step skipped on the original install): back up LUKS headers + enroll offline recovery keys — TPM auto-unlock is NOT a backup:
  ```bash
  # Backup headers to offline USB BEFORE adding keys
  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file "$USB/luks-header-nvme0n1p2-$(date +%Y-%m-%d).bin"
  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p5 --header-backup-file "$USB/luks-header-nvme0n1p5-$(date +%Y-%m-%d).bin"

  # Add a recovery passphrase to free slot 2 (leaves slot 0 passphrase + slot 1 TPM untouched)
  # Do NOT use --wipe-slot here — that would break TPM auto-unlock
  sudo cryptsetup luksAddKey /dev/nvme0n1p2 --key-slot 2
  sudo cryptsetup luksAddKey /dev/nvme0n1p5 --key-slot 2

  # Verify without unlocking
  sudo cryptsetup luksOpen --test-passphrase --key-slot 2 /dev/nvme0n1p2
  sudo cryptsetup luksOpen --test-passphrase --key-slot 2 /dev/nvme0n1p5
  ```
  Store the two recovery passphrases + header files offline on USB / paper. See [[luks-recovery-keys-and-header-backup]] for the full TPM-safe fix procedure.
- [ ] Configure systemd mount units for Storage (not fstab)
- [ ] Run pyinfra deploy from `~/Projects/mycachyos`
- [ ] Configure chezmoi for user dotfiles

---

## Quick Reference

| Task | Shortcut / Command |
|---|---|
| Disk Management | `diskmgmt.msc` |
| PowerShell (Admin) | Right-click Start → Terminal (Admin) |
| List installed apps | `winget list` |
| Check BitLocker status | `manage-bde -status` |
| BIOS entry | **F2** or **Del** during boot |
| Boot menu | **F9** during boot |
| ASUS Recovery | **F9** during POST (before Windows loads) |

---

*Keep this document handy during the reinstall. Check off each item as you go.*
