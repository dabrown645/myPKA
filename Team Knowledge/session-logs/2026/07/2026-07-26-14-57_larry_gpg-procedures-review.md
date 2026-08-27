# Session Log: GPG Procedures Review

- **Date:** 2026-07-26 14:57
- **Agent:** Larry
- **User:** David
- **Topic:** GPG user procedures review and updates

## Summary

David reviewed the three GPG user procedures (restore, backup/lockdown, key renewal) and raised observations about workflow design, security practices, and documentation accuracy.

## Key Observations

1. **Restore leaves secret keys on disk by design** — This is intentional for the permanent install use case. The workflow is: restore → work → lockdown.

2. **Multiple machines workflow** — David works on multiple machines that get replaced frequently. The current restore/lockdown cycle adds friction for this use case. Discussed hardware token (YubiKey) as a better fit for frequent machine replacement.

3. **GPG identity persistence** — The concept is one persistent identity independent of machines. The USB (or hardware token) holds the identity; machines are ephemeral.

4. **Subkeys recreated during restore** — David had to recreate subkeys from original backup, which changed subkey fingerprints and keygrips. This made the key reference tables in all three procedures outdated.

5. **Date handling in backup procedure** — The procedure called `$(date +%Y-%m-%d)` independently in multiple commands, which could cause issues around midnight. Fixed by capturing date once in `BACKUP_DATE` variable.

## Actions Taken

1. **Updated key reference tables** in all three GPG procedures:
   - `GPG-restore-for-active-use.md`
   - `GPG-backup-and-lockdown.md`
   - `GPG-key-renewal.md`
   
   New subkey fingerprints:
   - `[E]`: `90315B4ABC2E129BE09DACC724FC514F5F64E5B8`
   - `[A]`: `32BA78D2B8505D782BF42A35ED90C2737542A1AC`

2. **Fixed date handling** in `GPG-backup-and-lockdown.md` — consolidated multiple `$(date +%Y-%m-%d)` calls into single `BACKUP_DATE` variable.

3. **Corrected primary key expiry date** in `GPG-key-renewal.md` — was `2027-07-24`, corrected to `2027-07-25` to match actual keyring state.

## Insights

- The GPG procedures assume a single-machine workflow. For multi-machine replacement scenarios, a hardware token (YubiKey) is the recommended approach.
- The restore procedure's steps 5-8 (create missing subkeys) can change the user's identity if subkeys aren't in the backup. This should be documented as a caveat.

## Open Questions

- Should the procedures include a note about when to use restore vs. lockdown for permanent installs?
- Should there be a separate "multi-machine setup" guide?
- Would a hardware token guide be valuable for David's workflow?

## Next Steps

- Consider adding a "Multi-Machine Workflow" section to the GPG procedures
- Evaluate whether a YubiKey setup guide would be useful
- Monitor for any other documentation gaps during future GPG operations
