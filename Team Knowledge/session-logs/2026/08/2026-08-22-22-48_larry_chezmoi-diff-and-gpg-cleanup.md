# Session Log: 2026-08-22 22:48

## Context

Chezmoi diff was showing unexpected results related to GPG files.

## What happened

1. User reported `chezmoi diff` gave unexpected results
2. Initial diagnosis: diff command was `nvim -d` (TUI tool) — couldn't run in non-interactive contexts
3. User fixed diff command, but GPG-related diffs remained
4. Root cause: `chezmoi add --encrypt .gnupg` captured ephemeral files (lock files) and obsolete files (`pubring.kbx`)
5. Lock files (`.#lk*`) are transient GnuPG process artifacts — created/deleted on every GPG operation
6. `pubring.kbx` is obsolete — GnuPG now uses `public-keys.d/pubring.db`
7. Removed stale files from source state, diff is now clean

## Key learning

Do NOT use blanket `chezmoi add --encrypt .gnupg` — it captures ephemeral files. Use selective add instead:

```bash
chezmoi add --encrypt ~/.gnupg/gpg.conf ~/.gnupg/gpg-agent.conf ~/.gnupg/common.conf ~/.gnupg/sshcontrol ~/.gnupg/trustdb.gpg ~/.gnupg/gpgbackup.sh ~/.gnupg/gpgkey.sh ~/.gnupg/public-keys.d/pubring.db
```

This command is saved in `~/.config/chezmoi/chezmoi.toml` as a comment.

## Decisions

- Diff command changed from `nvim -d` to `diff -u`
- GPG ephemeral files removed from chezmoi source state
- Selective add command documented for next update (expected ~1 year)

## Session type

close-session
