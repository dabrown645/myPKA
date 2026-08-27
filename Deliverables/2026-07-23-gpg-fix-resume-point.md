# GPG Environment Status — Resume Point

**Created:** 2026-07-23 20:10
**Purpose:** Quick reference when resuming this session

## Current Working State

GPG is functional. SSH via gpg-agent is working.

### Key Info
```
Primary:    BB1AFAE444025B46 (ed25519) [SC] [expires: 2027-07-24]
Fingerprint: 510BC4C8F52DAF51956ED33BBB1AFAE444025B46
Trust:      [ultimate]

Subkey [E]: 990A169365E650E7 (cv25519) [E] [expires: 2027-07-24]
Keygrip:    CB41605CF632752A7E1E2DC9F45B1C0129552369

Subkey [A]: EEADBF75A389E3FE (ed25519) [A] [expires: 2027-07-24]
Keygrip:    3A25BBF7E66D8EA3426DE9E4FBA12769B99F8FF1
```

### SSH Public Key (for authorized_keys)
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeF6nX/Nsy6aFfjpjcvJ5fHBWeUiqaswMgUBw+HSm+j
```

## What's Left To Do

### Immediate (before SOP-004)
1. ~~Remove stale lock file~~ — Already done ✓
2. ~~Verify `gpg.conf` contents~~ — Correct ✓

All cleanup is complete. Ready for SOP-004.

### Then Write SOPs
1. ~~SOP-003: GPG Restore for Active Use~~ — Written ✓
2. ~~SOP-004: GPG Backup and Lockdown~~ — Written ✓
3. ~~SOP-005: GPG Key Renewal~~ — Written ✓
4. ~~Update `Team Knowledge/SOPs/INDEX.md`~~ — Updated ✓

**All tasks complete.**

## SOP Summaries (planned)

### SOP-003: GPG Restore for Active Use
- Move current `.gnupg` out of way
- Restore from encrypted USB tar
- Verify permissions
- Check key status — renew if expired
- Create subkeys if missing
- Update `sshcontrol` with correct keygrip
- Restart gpg-agent
- Verify SSH works
- Update `authorized_keys` on remote servers if `[A]` changed

### SOP-004: GPG Backup and Lockdown
- Create backup directory with timestamp
- Full tar of `~/.gnupg`
- Export secret keys (armor format)
- Export trustdb
- Copy orphaned `.key` files
- Create manifest
- Bundle into single archive
- Copy to encrypted USB
- Delete secret keys from local keyring
- Remove orphaned `.key` files
- Kill gpg-agent
- Verify SSH is broken (confirms keys are gone)

### SOP-005: GPG Key Renewal
- Check expiration dates
- Check if secret key is on disk (if not, run SOP-003 first)
- Renew primary key
- Renew subkeys if needed
- Verify renewal
- Re-backup via SOP-004

## Important Notes

- `--quick-add-key` requires FULL fingerprint, not long key ID
- `--quick-add-key` needs `auth` not `authenticate` for usage flag
- `change-usage` defaults to primary key — use `key N` first to select subkey
- SSH config: garuda backup uses file-based key, don't touch that config
- rog1 = this laptop, garuda = 10.0.0.57
