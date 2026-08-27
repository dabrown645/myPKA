# GPG Backup and Lockdown

- **Type:** User procedure
- **Agent guide:** Larry (or any agent)
- **Trigger:** Work session complete, you want secret keys off disk.
- **Prerequisite:** GPG is functional on this machine (restored via [[GPG-restore-for-active-use]] or keys were generated here).
- **Post-conditions:** Full backup on encrypted USB, primary secret key removed from disk, subkey secrets remain. SSH and decryption functional; GPG signing/certification broken by design.
- **Related:** [[GPG-restore-for-active-use]] (restore), [[GPG-key-renewal]] (renew before backup if expired)

## Purpose

Create a complete backup of the GPG environment on encrypted USB, then remove the primary `[SC]` secret key from the local machine. This is a **partial lockdown**: you can still receive encrypted files and SSH, but you cannot sign, certify, or manage keys. To restore full functionality, run [[GPG-restore-for-active-use]].

## Key reference

| Key | Fingerprint | Keygrip | Purpose | After Lockdown |
|-----|-------------|---------|---------|----------------|
| Primary `[SC]` | `510BC4C8F52DAF51956ED33BBB1AFAE444025B46` | `D12B20C3214889A1109A8AAB3663A5788B5B8DDF` | Sign + Certify | **Removed** |
| Subkey `[E]` | `90315B4ABC2E129BE09DACC724FC514F5F64E5B8` | `A696D16BFAA7A51FE3AFFF3869908F1CD438E7EF` | Encryption | Kept |
| Subkey `[A]` | `32BA78D2B8505D782BF42A35ED90C2737542A1AC` | `8757F6925CF18F20D9D3D174BFDE9B6E652582F8` | SSH Authentication | Kept |

## Steps

### 1. Verify current state

```bash
gpg --list-keys --keyid-format long
gpg --list-secret-keys --keyid-format long
ssh-add -l
```

Record what works. This is your before-snapshot for comparison after lockdown.

### 2. Create backup directory

```bash
BACKUP_DATE=$(date +%Y-%m-%d)
BACKUP_DIR=~/gpg-backup-$BACKUP_DATE
mkdir -p "$BACKUP_DIR"
```

### 3. Copy `.gnupg` directory

```bash
cp -a ~/.gnupg/ "$BACKUP_DIR/.gnupg/"
```

### 4. Export secret keys (human-readable)

```bash
gpg --export-secret-keys --armor BB1AFAE444025B46 > "$BACKUP_DIR/gpg-secret-keys.asc"
```

### 5. Export trustdb

```bash
gpg --export-ownertrust > "$BACKUP_DIR/gpg-ownertrust.txt"
```

### 6. Create manifest

```bash
cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
GPG Backup Date: $(date +%Y-%m-%d %H:%M)
Primary Key: BB1AFAE444025B46
Full Fingerprint: 510BC4C8F52DAF51956ED33BBB1AFAE444025B46
Subkeys: $(gpg --list-keys --keyid-format long BB1AFAE444025B46 | grep "^sub" | tr '\n' ', ')
SSH Keygrip: $(grep -v "^#" ~/.gnupg/sshcontrol | tail -1)
Files: .gnupg/, gpg-secret-keys.asc, gpg-ownertrust.txt, MANIFEST.txt
EOF
```

### 7. Bundle into single archive

```bash
tar -czf ~/gpg-backup-$BACKUP_DATE.tar.gz -C ~/ "gpg-backup-$BACKUP_DATE/"
```

### 8. Copy to encrypted USB

```bash
cp ~/gpg-backup-$BACKUP_DATE.tar.gz /path/to/usb/
```

### 9. Verify USB

```bash
ls -la /path/to/usb/gpg-backup-$BACKUP_DATE.tar.gz
```

Optional: verify contents by extracting to a temp directory and checking the manifest.

### 10. Remove primary key secret only

Delete only the primary key's `.key` file. Leave subkey files intact.

```bash
rm ~/.gnupg/private-keys-v1.d/D12B20C3214889A1109A8AAB3663A5788B5B8DDF.key
```

### 11. Verify primary key is locked

```bash
gpg --list-secret-keys --with-keygrip --keyid-format long
```

Expected output:
- Primary key: `sec#` — secret not on disk
- Subkeys: `se` — secrets still on disk

### 12. Restart gpg-agent

```bash
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

### 13. Verify SSH works

```bash
ssh-add -l
```

Should show one identity — the `[A]` subkey.

### 14. Verify GPG signing is broken (expected)

```bash
echo "test" | gpg --clearsign
```

Should fail with "No secret key" error. This confirms the primary key is off disk.

### 15. Clean up local backup

```bash
rm -rf ~/gpg-backup-$BACKUP_DATE/
rm ~/gpg-backup-$BACKUP_DATE.tar.gz
```

### 16. Log the lockdown

Write a session log entry noting:
- Backup location (USB path)
- Backup filename
- Primary key removed from disk, subkeys retained
- Verification results (`sec#` for primary, SSH working, signing broken)

## Common issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Primary key still shows `sec` not `sec#` | Wrong `.key` file deleted or deletion failed | Check keygrip in key reference table, re-run Step 10 |
| SSH broken after lockdown | Wrong key file deleted (subkey instead of primary) | Restore from backup via [[GPG-restore-for-active-use]], re-run lockdown carefully |
| `ssh-add -l` shows no identities after restart | gpg-agent not restarted or `sshcontrol` missing `[A]` keygrip | Run `gpgconf --kill gpg-agent && gpgconf --launch gpg-agent`, verify `sshcontrol` |
| USB copy fails | USB not mounted or full | Check mount point and available space |
| GPG signing still works after lockdown | Primary key file not actually removed | `ls ~/.gnupg/private-keys-v1.d/D12B20C3214889A1109A8AAB3663A5788B5B8DDF.key` — should not exist |

## Quick restore (primary key only)

To temporarily restore signing capability without a full restore:

```bash
# Extract just the primary key file from backup
tar -xzf ~/gpg-backup-*.tar.gz -C /tmp/
cp /tmp/gpg-backup-*/.gnupg/private-keys-v1.d/D12B20C3214889A1109A8AAB3663A5788B5B8DDF.key ~/.gnupg/private-keys-v1.d/
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

Verify:
```bash
gpg --list-secret-keys --keyid-format long
```

Should show `sec` (not `sec#`) for the primary key. When done, re-run the lockdown procedure to remove it again.
