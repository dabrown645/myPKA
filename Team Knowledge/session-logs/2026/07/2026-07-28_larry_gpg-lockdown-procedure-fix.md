---
agent_id: larry
session_id: gpg-lockdown-procedure-fix
timestamp: 2026-07-28T00:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# GPG Lockdown Procedure Fix

## Context

David returned to the GPG backup and lockdown procedure. After running `gpg --delete-secret-keys`, he received unexpected prompts for orphaned keys, and SSH broke — which wasn't the intended outcome. The procedure needed to be fixed to match the actual goal: partial lockdown.

## What we did

1. Diagnosed the issue: `gpg --delete-secret-keys` removes ALL secret keys (primary + subkeys), not just the primary.
2. Identified 3 orphaned `.key` files in `private-keys-v1.d/` that caused the extra prompts.
3. Clarified David's actual intent: keep `[E]` (encryption) and `[A]` (SSH) subkeys on disk, remove only the primary `[SC]` key.
4. Discussed GPG best practices, key exchange, Proton Mail, and key servers.
5. Redesigned the backup structure from nested tar to flattened copy for easier single-file restoration.
6. Updated `GPG-backup-and-lockdown.md` with all fixes.

## Decisions made

- **Partial lockdown**: Primary key removed, subkeys retained. SSH and decryption stay functional.
- **Flattened backup**: `cp -a ~/.gnupg/` instead of nested tar. Simpler extraction.
- **Orphaned keys left as-is**: Already backed up in the `.gnupg/` copy, harmless, no cleanup during lockdown.
- **Quick restore section added**: Shows how to extract just the primary key file for temporary signing.

## Insights

- The old procedure was over-engineered — `gpg --delete-secret-keys` was too aggressive for the actual use case.
- Flattened backup structure makes single-file extraction trivial (one `tar` command).
- Orphaned `.key` files are harmless and don't need special handling during lockdown.
- GPG encryption is algorithmically strong; the weak point is always key/passphrase management, not the crypto.

## Realignments

- Procedure now matches actual intent: partial lockdown, not full secret key removal.

## Open threads

- Consider hardware token (YubiKey) for primary key storage — never touches disk.
- Multi-machine workflow guide may be useful if David works across multiple machines frequently.

## Next steps

- Test the updated procedure on a real lockdown cycle.
- Consider YubiKey guide for future.

## Cross-links

- `[[2026-07-26-22-21_larry_gpg-orphan-key-question]]` — orphan key discussion.
- `[[2026-07-26-14-57_larry_gpg-procedures-review]]` — procedures review that updated key reference tables.
- `[[User Knowledge/Procedures/GPG-backup-and-lockdown]]` — the procedure we fixed.
