# Session Log: GPG Environment Fix and SOP Planning

**Date:** 2026-07-23
**Agent:** Larry (orchestrator)
**User:** David

## Summary

David's GPG environment was broken after a restore from backup. The primary key was expired, secret key material was missing, and SSH via gpg-agent wasn't working. We fixed the immediate issues and planned three SOPs for GPG maintenance.

## Issues Found

1. **Expired primary key** — `ed25519 BB1AFAE444025B46` expired 2026-07-06
2. **No subkeys** — Only primary key `[SC]`, no `[A]` or `[E]`
3. **Missing `gpg.conf`** — Running on bare defaults
4. **Orphaned key files** — 3 `.key` files in `private-keys-v1.d/` with no matching public key
5. **Stale lock file** — `public-keys.d/.#lk*`
6. **Permission issues** — `public-keys.d/`, `sshcontrol`, `common.conf` had wrong permissions
7. **Dead `sshcontrol` entry** — Referenced non-existent keygrip
8. **No GPG auth key in `authorized_keys`** — Remote servers didn't have the new subkey's public key

## What We Fixed

### Key Renewal
- Primary key renewed to `2027-07-24`
- Trust set to `[ultimate]`

### Subkeys Created
- `cv25519/990A169365E650E7 [E]` — Encryption subkey (created via `addkey`)
- `ed25519/EEADBF75A389E3FE [A]` — Authentication subkey for SSH (created via `--quick-add-key ... auth 1y`)

### SSH Fixed
- `sshcontrol` updated with new `[A]` subkey keygrip: `3A25BBF7E66D8EA3426DE9E4FBA12769B99F8FF1`
- `ssh-add -l` shows the identity
- GPG passphrase prompt restored for SSH
- `authorized_keys` updated on rog1 and garuda

### Permissions Fixed
- `public-keys.d/` — `700` ✓
- `sshcontrol` — `600` ✓
- `common.conf` — `600` ✓
- `gpg.conf` created with sane defaults

## Current State

### Key Structure
```
pub   ed25519/BB1AFAE444025B46 [SC] [expires: 2027-07-24]
sub   cv25519/990A169365E650E7 [E] [expires: 2027-07-24]
sub   ed25519/EEADBF75A389E3FE [A] [expires: 2027-07-24]
```

### Keygrips
- Primary: `D12B20C3214889A1109A8AAB3663A5788B5B8DDF`
- `[E]` subkey: `CB41605CF632752A7E1E2DC9F45B1C0129552369`
- `[A]` subkey: `3A25BBF7E66D8EA3426DE9E4FBA12769B99F8FF1`

### SSH Config
- rog1 = this laptop (rog1)
- garuda = 10.0.0.57 (remote server)
- Backup uses `~/.ssh/id_ed25519_backup` with `IdentitiesOnly yes` for garuda

## Remaining Steps

### Before SOP-004 (cleanup)
1. ~~Remove stale lock file~~ — Done ✓
2. ~~Verify `gpg.conf` contents~~ — Correct ✓

### SOPs to Write
1. ~~**SOP-003: GPG Restore for Active Use**~~ — Written ✓
2. ~~**SOP-004: GPG Backup and Lockdown**~~ — Written ✓
3. ~~**SOP-005: GPG Key Renewal**~~ — Written ✓
4. ~~Update `Team Knowledge/SOPs/INDEX.md`~~ — Updated ✓

## SOPs Written (end of session)

- `Team Knowledge/SOPs/SOP-003-gpg-restore-for-active-use.md` — **Moved to** `User Knowledge/Procedures/GPG-restore-for-active-use.md`
- `Team Knowledge/SOPs/SOP-004-gpg-backup-and-lockdown.md` — **Moved to** `User Knowledge/Procedures/GPG-backup-and-lockdown.md`
- `Team Knowledge/SOPs/SOP-005-gpg-key-renewal.md` — **Moved to** `User Knowledge/Procedures/GPG-key-renewal.md`
- `Team Knowledge/SOPs/INDEX.md` — updated (GPG SOPs removed, note added about User Knowledge)
- **New:** `User Knowledge/` folder created with Procedures, References, Checklists
- `User Knowledge/INDEX.md` — master hub for user knowledge
- `User Knowledge/Procedures/INDEX.md` — index of user procedures
- `User Knowledge/References/INDEX.md` — placeholder
- `User Knowledge/Checklists/INDEX.md` — placeholder
- `AGENTS.md` — folder map updated with User Knowledge section
- `Team Knowledge/INDEX.md` — cross-references updated

## Key Decisions

- **Tar backup approach:** Continue using `tar -czf` of `~/.gnupg` (simple, complete)
- **Separate export:** Also export secret keys in armor format for cross-machine use
- **Manifest:** Include manifest in backup for quick reference
- **Orphaned keys:** Back up to USB, then delete from local disk
- **Two-file approach for restore:** SOP-003 = restore, SOP-004 = backup/lockdown

## Session Notes

- User is security-conscious — prefers secret keys off disk when not in use
- Backup system to garuda (10.0.0.57) uses file-based SSH key, must be preserved
- GPG is primarily used for SSH authentication, not signing
- `--quick-add-key` requires full fingerprint, not long key ID
- `--quick-add-key` needs `auth` not `authenticate` for the usage flag
- `change-usage` in edit mode defaults to primary key — use `key N` first to select subkey
