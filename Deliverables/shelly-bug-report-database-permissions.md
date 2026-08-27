# [BUG] Shelly CLI corrupts pacman sync databases — wrong permissions (0640) and missing .sig files

## Description

Shelly CLI (v3.0.6-1) breaks all subsequent pacman operations by writing sync database files with incorrect permissions and not fetching signature files.

After running `shelly` to apply updates, `pacman -Ss`, `pacman -Syu`, and all other pacman operations fail with:

```
error: database 'cachyos-v3' is not valid (invalid or corrupted database (PGP signature))
error: database 'cachyos-extra-v3' is not valid (invalid or corrupted database (PGP signature))
error: database 'cachyos-core-v3' is not valid (invalid or corrupted database (PGP signature))
error: database 'cachyos' is not valid (invalid or corrupted database (PGP signature))
error: database 'core' is not valid (invalid or corrupted database (PGP signature))
error: database 'extra' is not valid (invalid or corrupted database (PGP signature))
error: database 'multilib' is not valid (invalid or corrupted database (PGP signature))
error: database 'chaotic-aur' is not valid (invalid or corrupted database (PGP signature))
```

## Two distinct problems

### 1. Wrong file permissions on .db files

**Expected (pacman):**
```
-rw-r--r-- 1 root root  4548216 Aug 21 15:32 cachyos-extra-v3.db
```

**Actual (after Shelly):**
```
-rw-r----- 1 root root  4549977 Aug 22 20:18 cachyos-extra-v3.db
```

Shelly writes `.db` files with `0640` (`-rw-r-----`) instead of `0644` (`-rw-r--r--`). This makes them not world-readable, which can cause issues when pacman (running as root via sudo) tries to access them.

### 2. Missing .db.sig files

Before Shelly runs, all repos have matching `.sig` files:
```
cachyos-extra-v3.db      Aug 21 15:32
cachyos-extra-v3.db.sig  Aug 21 15:32
```

After Shelly runs, **every single `.sig` file is gone**:
```
cachyos-extra-v3.db      Aug 22 20:18   (new timestamp, wrong perms)
cachyos-extra-v3.db.sig  MISSING
```

All 8 repos affected: `cachyos-v3`, `cachyos-extra-v3`, `cachyos-core-v3`, `cachyos`, `core`, `extra`, `multilib`, `chaotic-aur`.

## Reproduction steps

1. Confirm pacman works: `pacman -Ss git` (succeeds)
2. Run Shelly CLI to apply available updates
3. Confirm pacman is broken: `pacman -Ss git` (fails with signature errors on all databases)
4. Check `/var/lib/pacman/sync/` — all `.sig` files gone, all `.db` files have `0640` permissions

**Reproducibility:** 100% — reproduced 3 times across 2 days.

## Expected behavior

Shelly should either:
- Use `pacman -Sy` (or the equivalent `alpm` calls) which correctly fetches `.db` + `.db.sig` pairs with `0644` permissions, OR
- Not modify the sync database at all and let pacman handle syncing

## Fix

Running `sudo pacman -Syy` restores correct permissions and `.sig` files, but the problem recurs on the next Shelly update.

## Environment

- OS: CachyOS x86_64
- Shelly: 3.0.6-1 (CachyOS package)
- Desktop: COSMIC
- Repos: cachyos-v3, cachyos-extra-v3, cachyos-core-v3, cachyos, chaotic-aur, core, extra, multilib

## Notes

- This is NOT a simultaneous-use issue. I never run pacman and Shelly at the same time. The corruption happens during Shelly's own operation.
- The Shelly log shows successful completion (exit code 0) — no errors reported.
- Shelly's `config.json` is default — no custom sync settings.
- `pacman.conf` is correct (`SigLevel = Required DatabaseOptional`, no `TrustAll` leak).
