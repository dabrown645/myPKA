# GPG Key Renewal

- **Type:** User procedure
- **Agent guide:** Larry (or any agent)
- **Trigger:** Key expiration warning, or proactive monthly check.
- **Prerequisite:** Secret keys must be on disk. If not, run [[GPG-restore-for-active-use]] first.
- **Post-conditions:** All keys have valid future expiration dates. Backup should be re-created via [[GPG-backup-and-lockdown]].
- **Related:** [[GPG-restore-for-active-use]] (restore if keys off disk), [[GPG-backup-and-lockdown]] (re-backup after renewal)

## Purpose

Extend the validity of GPG keys that are expired or approaching expiration, without changing the key material itself.

## Key reference

| Key | Fingerprint | Current Expiry |
|-----|-------------|----------------|
| Primary `[SC]` | `510BC4C8F52DAF51956ED33BBB1AFAE444025B46` | 2027-07-25 |
| Subkey `[E]` | `90315B4ABC2E129BE09DACC724FC514F5F64E5B8` | 2027-07-25 |
| Subkey `[A]` | `32BA78D2B8505D782BF42A35ED90C2737542A1AC` | 2027-07-25 |

## Steps

### 1. Check expiration dates

```bash
gpg --list-keys --keyid-format long
```

Look for `[expired]` or `[expires: YYYY-MM-DD]` on the primary key or subkeys.

### 2. Check if secret key is on disk

```bash
gpg --list-secret-keys --keyid-format long
```

If `sec#` (with `#`), the secret key is not on disk. Run [[GPG-restore-for-active-use]] first — you cannot renew without the secret key.

### 3. Renew primary key

```bash
gpg --edit-key BB1AFAE444025B46
```

At the `gpg>` prompt:

```
expire
```

Enter the number of days (e.g., `365` for one year). Confirm with `y`. Enter your passphrase when prompted. Then:

```
save
```

### 4. Renew subkeys (if needed)

If subkeys also need renewal:

```bash
gpg --edit-key BB1AFAE444025B46
```

At the `gpg>` prompt:

```
key 1
expire
# Enter days
# Confirm: y
# Enter passphrase
key 2
expire
# Enter days
# Confirm: y
# Enter passphrase
save
```

### 5. Quick alternative (primary key only)

```bash
gpg --quick-set-expire 510BC4C8F52DAF51956ED33BBB1AFAE444025B46 365d
```

This renews the primary key without opening the interactive editor.

### 6. Verify renewal

```bash
gpg --list-keys --keyid-format long
```

All keys should show future expiration dates. Confirm:
- Primary key: `[expires: YYYY-MM-DD]` with a future date
- Subkeys: `[expires: YYYY-MM-DD]` with a future date

### 7. Re-backup after renewal

The backup now contains stale key metadata. Create a fresh backup:

```bash
# Follow GPG-backup-and-lockdown to create a new backup with the renewed keys
```

### 8. Log the renewal

Write a session log entry noting:
- Which keys were renewed (primary, subkeys, or both)
- Previous expiration dates
- New expiration dates
- Whether a new backup was created

## Common issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `gpg: signing failed: Invalid expiry date` | Primary key expired | Renew with `expire` command — expired keys can still self-sign |
| `gpg: Key generation failed: Invalid value` | Wrong usage flag in `--quick-add-key` | Use `auth` not `authenticate` |
| Secret key not available | Keys on USB, not disk | Run [[GPG-restore-for-active-use]] first |
| Subkey shows `[expired]` after primary renewal | Subkeys have their own expiry | Renew subkeys separately with `key N` → `expire` |

## Renewal schedule

Proactively check expiration monthly:
```bash
gpg --list-keys --keyid-format long | grep -E "expires|expired"
```

Set a calendar reminder 30 days before expiry to renew and re-backup.
