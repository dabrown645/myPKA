# LUKS Recovery Keys and Header Backup (TPM-Safe)

- **Type:** User procedure
- **Agent guide:** Rex (via Larry)
- **Trigger:** LUKS + TPM2 auto-unlock is working but you have no offline recovery key or header backup.
- **Prerequisite:** USB stick for offline storage, CachyOS booted, `sudo` access. Known current LUKS passphrase (slot 0). TPM auto-unlock working — confirmed via `lsblk -f` showing `crypto_LUKS` on `nvme0n1p2` (root) and `nvme0n1p5` (storage) with a `systemd-tpm2` token on slot 1.
- **Post-conditions:** LUKS headers backed up offline, recovery passphrase enrolled in free slot 2 on both drives, TPM auto-unlock untouched (slots 0/1 preserved), recovery verified with `--test-passphrase`.
- **Related:** [[2026-08-13-windows-reinstall-procedure]] (install this fixes), [[SECURE-BOOT-AND-TPM-GUIDE]] Part 3 (TPM enrollment reference)

## Purpose

Add BitLocker-style "just in case" recovery to existing LUKS drives without breaking TPM decrypt-on-boot. The missed step on the original install was: encrypt + enroll TPM, but never create an offline recovery key or header backup. TPM is convenience, not backup — a PCR change, BIOS update, Secure Boot toggle, TPM clear, or board swap forces passphrase fallback.

This procedure leaves slot 0 (passphrase) and slot 1 (TPM2 PCR 7) alone and uses free slot 2 for recovery.

## What not to do

- Do NOT run `systemd-cryptenroll --wipe-slot` — that deletes the TPM binding and breaks auto-unlock.
- Do NOT run `luksRemoveKey`, `luksKillSlot`, `luksFormat`, or re-enroll TPM PCRs in this procedure.
- Do NOT store recovery passphrases in plain markdown in myPKA. Paper safe + password manager + offline USB only.

## Steps

### 1. Confirm current layout (read-only)

```bash
lsblk -f
# Expected: nvme0n1p2 crypto_LUKS (root), nvme0n1p5 crypto_LUKS (storage/home)

sudo cryptsetup luksDump /dev/nvme0n1p2 | grep -Ei "version|keyslot|slot|token|tpm2-hash|tpm2-pcr|Keyslot"
sudo cryptsetup luksDump /dev/nvme0n1p5 | grep -Ei "version|keyslot|slot|token|tpm2-hash|tpm2-pcr|Keyslot"
# Expected: slot 0 argon2id (passphrase), slot 1 pbkdf2 + systemd-tpm2 token, Keyslot: 1, PCRs: 7
```

If slot 2 is already occupied, stop — pick another free slot (3-31) and substitute `--key-slot 2` below.

### 2. Mount offline USB and back up headers

```bash
# Mount USB — adjust path to your stick
lsblk -f  # identify USB mountpoint
export USB=/run/media/$USER/USB   # replace with actual mountpoint
export STAMP=$(date +%Y-%m-%d)

sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file "$USB/luks-header-nvme0n1p2-$STAMP.bin"
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p5 --header-backup-file "$USB/luks-header-nvme0n1p5-$STAMP.bin"

ls -lh "$USB"/luks-header-*.bin
sha256sum "$USB"/luks-header-*.bin | tee "$USB/luks-header-SHA256SUMS-$STAMP.txt"
```

Keep this USB offline after step 5. These `.bin` files plus your passphrase can restore a corrupted header via `luksHeaderRestore` — they are sensitive, treat like keys.

### 3. Create recovery passphrases (offline, one per drive recommended)

Generate two long passphrases now — same-for-both is simpler, distinct is better isolation. Do not reuse your boot passphrase.

Options (pick one):
- Diceware: 7-8 words from paper wordlist (best for typing at boot prompt)
- Random: `openssl rand -base64 32` written to paper (harder to type, store carefully)

Write both to paper + password manager BEFORE step 4. Label: `nvme0n1p2 slot2 recovery — YYYY-MM-DD` and `nvme0n1p5 slot2 recovery — YYYY-MM-DD`.

### 4. Enroll recovery to slot 2 (TPM untouched)

```bash
# Root drive — prompts first for existing slot 0 passphrase, then twice for NEW recovery passphrase
sudo cryptsetup luksAddKey /dev/nvme0n1p2 --key-slot 2

# Storage drive — same flow, use its recovery passphrase
sudo cryptsetup luksAddKey /dev/nvme0n1p5 --key-slot 2
```

Alternative (auto-generated): `sudo systemd-cryptenroll --recovery-key /dev/nvme0n1p2` prints a random recovery key instead of asking. Either path is TPM-safe — both use a free slot. Prefer `luksAddKey` if you already wrote diceware phrases in step 3.

### 5. Verify without unlocking or rebooting

```bash
sudo cryptsetup luksOpen --test-passphrase --key-slot 2 /dev/nvme0n1p2 && echo "p2 slot2 OK"
sudo cryptsetup luksOpen --test-passphrase --key-slot 2 /dev/nvme0n1p5 && echo "p5 slot2 OK"

sudo cryptsetup luksDump /dev/nvme0n1p2 | grep -A2 "Keyslots:" -A20 | grep -Ei "0:|1:|2:|luks2"
sudo cryptsetup luksDump /dev/nvme0n1p5 | grep -A2 "Keyslots:" -A20 | grep -Ei "0:|1:|2:|luks2"
# Expected: slots 0, 1, 2 all luks2 / ENABLED. Slots 0/1 digests unchanged.
```

If any test fails, do not reboot — re-enter the correct recovery passphrase with `luksAddKey` to the same slot after `luksKillSlot 2` (slot 2 only — never 0 or 1), or ask Rex before proceeding.

### 6. Store and test boot path

1. Copy `luks-header-*.bin` + `SHA256SUMS` already on USB (step 2). Add a text file with drive UUIDs (`lsblk -f`) and slot map (0 = boot passphrase, 1 = TPM2 PCR7, 2 = offline recovery) — no passphrases in that file, those stay on paper / password manager.
2. Unmount USB: `udisksctl unmount -p <usb-partition>` or via file manager. Store offline.
3. Normal reboot: `sudo reboot` — should still auto-unlock via TPM with no password prompt. This proves TPM was not broken.
4. Optional fallback test (when you have time): at boot, force passphrase prompt (interrupt TPM via BIOS Secure Boot toggle test or `systemd-cryptenroll` recovery path), unlock with slot 2 phrase, then reboot back to normal TPM path. Skip this if you cannot afford a maintenance window — steps 1-5 already prove recovery works.

## Done check

- [ ] `luksDump` shows slots 0,1,2 active on both drives
- [ ] `--test-passphrase --key-slot 2` passes on both drives
- [ ] Header `.bin` files + checksums on offline USB
- [ ] Recovery passphrases on paper + password manager, not in myPKA
- [ ] Normal reboot still TPM auto-unlocks
