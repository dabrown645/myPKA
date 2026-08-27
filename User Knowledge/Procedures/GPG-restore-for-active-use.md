# GPG Restore for Active Use

- **Type:** User procedure
- **Agent guide:** Larry (or any agent)
- **Trigger:** You need GPG for work (SSH, signing, encryption) and secret keys are on the encrypted USB, not on disk.
- **Prerequisite:** A GPG backup exists on encrypted USB (created via [[GPG-backup-and-lockdown]]).
- **Post-conditions:** GPG is fully functional, SSH via gpg-agent works, secret keys are on disk.
- **Related:** [[GPG-backup-and-lockdown]] (backup/lockdown), [[GPG-key-renewal]] (renew expired keys)

## Purpose

Restore a working GPG environment from an encrypted USB backup. This gets you from "secret keys on USB only" to "GPG fully functional on this machine" so you can use SSH, sign, or encrypt.

## Key reference

| Key | Fingerprint | Keygrip | Purpose |
|-----|-------------|---------|---------|
| Primary `[SC]` | `510BC4C8F52DAF51956ED33BBB1AFAE444025B46` | `D12B20C3214889A1109A8AAB3663A5788B5B8DDF` | Sign + Certify |
| Subkey `[E]` | `90315B4ABC2E129BE09DACC724FC514F5F64E5B8` | `A696D16BFAA7A51FE3AFFF3869908F1CD438E7EF` | Encryption |
| Subkey `[A]` | `32BA78D2B8505D782BF42A35ED90C2737542A1AC` | `8757F6925CF18F20D9D3D174BFDE9B6E652582F8` | SSH Authentication |

## Steps

### 1. Back up the current `.gnupg` (even if broken)

Preserves whatever is there now in case it contains useful state.

```bash
mv ~/.gnupg ~/.gnupg.pre-restore.$(date +%Y%m%d)
```

### 2. Restore from encrypted USB

```bash
cp -a /path/to/usb/gpg-backup-*.tar.gz /tmp/
tar -xzf /tmp/gpg-backup-*.tar.gz -C /tmp/
cp -a /tmp/gpg-backup-*/.gnupg ~/.gnupg
rm -rf /tmp/gpg-backup-* /tmp/.gnupg
```

### 3. Verify permissions

The tar should preserve correct permissions. Verify:

```bash
ls -la ~/.gnupg/
ls -la ~/.gnupg/private-keys-v1.d/
ls -la ~/.gnupg/public-keys.d/
```

Expected permissions:
| Path | Expected |
|------|----------|
| `~/.gnupg/` | `700` |
| `private-keys-v1.d/` | `700` |
| `public-keys.d/` | `700` |
| `*.key` files | `600` |
| `sshcontrol` | `600` |
| `common.conf` | `600` |
| `trustdb.gpg` | `600` |
| `gpg-agent.conf` | `644` |

If any are wrong, fix them:

```bash
chmod 700 ~/.gnupg ~/.gnupg/private-keys-v1.d ~/.gnupg/public-keys.d
chmod 600 ~/.gnupg/sshcontrol ~/.gnupg/common.conf ~/.gnupg/trustdb.gpg
chmod 600 ~/.gnupg/private-keys-v1.d/*.key 2>/dev/null
chmod 644 ~/.gnupg/gpg-agent.conf
```

### 4. Check key status

```bash
gpg --list-keys --keyid-format long
```

Look for `[expired]` on the primary key or subkeys. If expired, see [[GPG-key-renewal]].

### 5. Check for subkeys

```bash
gpg --list-secret-keys --keyid-format long --with-subkey-fingerprints
```

Look for lines with `[A]` (Authentication) and `[E]` (Encryption).

### 6. Create `[A]` subkey if missing

```bash
gpg --quick-add-key 510BC4C8F52DAF51956ED33BBB1AFAE444025B46 ed25519 auth 1y
```

### 7. Create `[E]` subkey if missing

```bash
gpg --edit-key BB1AFAE444025B46
# gpg> addkey
# Select: 12 (ECC encrypt only)
# Curve: 1 (Curve 25519)
# Expiration: 365
# Confirm: y
# Enter passphrase
# gpg> save
```

### 8. Update `sshcontrol`

Get the `[A]` subkey's keygrip:

```bash
gpg --list-secret-keys --with-keygrip --keyid-format long BB1AFAE444025B46
```

Find the `Keygrip =` line under the `[A]` subkey. Replace the last non-comment line in `~/.gnupg/sshcontrol` with this keygrip.

### 9. Restart gpg-agent

```bash
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

### 10. Verify SSH

```bash
ssh-add -l
```

Should show one identity (the `[A]` subkey).

```bash
ssh rog1
```

Should prompt for GPG passphrase.

### 11. Update `authorized_keys` on remote servers

If the `[A]` subkey changed during restore, the old public key on remote servers won't match. Export the new one:

```bash
ssh-add -L
```

Copy the output. On each remote server, append it to `~/.ssh/authorized_keys`.

### 12. Log the restore

Write a session log entry noting:
- Restore date
- Key fingerprints
- Any subkeys created
- Any `authorized_keys` updates

## Common issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ssh-add -l` shows no identities | Wrong keygrip in `sshcontrol` | Re-check keygrip from step 8 |
| SSH prompts for file passphrase, not GPG | `authorized_keys` doesn't have the GPG auth key | Run step 11 |
| `sec#` in key listing | Secret key not on disk | Restore didn't complete — re-run from step 2 |
| `gpg: key expired` warnings | Primary or subkey expired | Run [[GPG-key-renewal]] |
| Stale lock files in `public-keys.d/` | Previous gpg process didn't clean up | `rm ~/.gnupg/public-keys.d/.#lk*` |
