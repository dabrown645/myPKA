---
agent_id: larry
session_id: luks-recovery-codes-and-procedure-fix
timestamp: 2026-09-04T15:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions"]
---

# LUKS recovery codes question to TPM-safe fix procedure

## Context

You asked whether the encrypted-drive setup should have given you recovery codes, then confirmed TPM auto-unlock must not break, and asked for the missed step highlighted plus a fix procedure with commands for when you have a USB stick.

## What we did

- Rex analyzed `lsblk` + your `luksDump` output: `nvme0n1p2` (root) and `nvme0n1p5` (storage) are LUKS2 with slot 0 passphrase (argon2id) + slot 1 TPM2 PCR 7 auto-unlock — no offline recovery key exists.
- Rex traced the gap to `[[2026-08-13-windows-reinstall-procedure]]` §4.2, which enrolls TPM but never backs up headers or adds a recovery key (`[[SECURE-BOOT-AND-TPM-GUIDE]]` Part 3 has a `--recovery-key` line the checklist never carried over).
- Rex updated `[[2026-08-13-windows-reinstall-procedure]]` with a flagged `MISSED STEP (added 2026-09-04)` block (header backup + `luksAddKey --key-slot 2`, no `--wipe-slot`).
- Rex created `[[luks-recovery-keys-and-header-backup]]` in `User Knowledge/Procedures/` and indexed it — 6-step TPM-safe runbook (confirm, header backup to USB, write phrases to paper, enroll slot 2, `--test-passphrase` verify, store + reboot test).
- Larry ran librarian sweep: fixed one wikilink path in the new procedure, confirmed INDEX row and cross-refs resolve.

## Decisions made

- **Question:** Same or distinct recovery passphrase per drive?
  **Decision:** Deferred to you at implementation time — procedure recommends distinct, allows same for simplicity.
- **Question:** Where do recovery secrets live?
  **Decision:** Paper safe + password manager + offline USB only — never plain markdown in myPKA.
- **Question:** Touch TPM/PCR policy in this fix?
  **Decision:** No — slots 0/1 and PCR 7 binding stay untouched; `--wipe-slot`, `luksKillSlot 0/1`, re-seal explicitly excluded.

## Insights

- LUKS installer flow never issues BitLocker-style codes — the "recovery code step" only exists if the procedure adds it manually. Worth stating explicitly in every future encryption runbook.
- `slot 1 pbkdf2 1000-iter` + `systemd-tpm2` token is the reliable fingerprint of TPM auto-unlock vs a human passphrase — useful triage pattern for future LUKS questions.
- `systemd-cryptenroll status <device>` fails on this systemd version ("Too many arguments") — `cryptsetup luksDump` + token grep is the version-stable read path.

## Realignments

- _(none this session — you corrected plan/build mode explicitly and Rex proceeded)_

## Open threads

- [ ] You to implement `[[luks-recovery-keys-and-header-backup]]` steps 1-6 when USB stick is available (header `.bin` files + slot-2 phrases).
- [ ] Optional fallback boot test (passphrase prompt via slot 2) deferred to a maintenance window.
- [ ] BitLocker recovery key for `nvme1n1p3` still unverified — separate Windows-side check (`manage-bde -status` / Microsoft Account).

## Next steps

- You run the new procedure when ready; next session verifies `luksDump` slots 0/1/2 + reboot still TPM auto-unlocks.
- Consider graduating the "TPM is not a backup — every LUKS runbook ends with header backup + slot-2 recovery" rule into the reinstall procedure permanently (already added as MISSED STEP; promote to checklist norm on next install doc).

## Cross-links

- `[[2026-08-13-19-30_larry_windows-and-cachyos-reinstall-prep]]` — original reinstall prep where LUKS+TPM steps were added without recovery.
- `[[2026-08-09-22-49_larry_archlinux-encryption-and-cleanup]]` — earlier encryption procedure session.
