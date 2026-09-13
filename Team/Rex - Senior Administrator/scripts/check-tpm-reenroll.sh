#!/bin/bash
# check-tpm-reenroll.sh — Rex for David
# Run AFTER cachy-update / pacman -Syu, BEFORE reboot.
# Checks the last pacman transaction for boot-crypto changes
# (systemd, systemd-libs, mkinitcpio) and prompts to re-enroll TPM PCR 7.
# Safe to run anytime: empty result = nothing to do.
set -euo pipefail

LOG="/var/log/pacman.log"
ROOT_UUID="e6514b65-dbc7-4820-ba90-713dc7e7721e"
STORE_UUID="0feb9776-20f3-498d-8bcf-9a22e7bb520e"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rex-tpm-reenroll.handled"

if [[ ! -r "$LOG" ]]; then
  echo "Cannot read $LOG" >&2
  exit 1
fi

# Last transaction block: from last "transaction started" to end of log
LAST_START=$(grep -n "transaction started" "$LOG" | tail -n 1 | cut -d: -f1)
if [[ -z "$LAST_START" ]]; then
  echo "No pacman transaction found in $LOG. Nothing to do."
  exit 0
fi

BLOCK=$(tail -n +"$LAST_START" "$LOG")
LAST_LINE=$(wc -l < "$LOG" | tr -d ' ')

# Already handled this exact transaction?
if [[ -f "$STATE_FILE" ]] && grep -qx "$LAST_START:$LAST_LINE" "$STATE_FILE" 2>/dev/null; then
  echo "OK: this transaction already handled (marked in $STATE_FILE). Safe to reboot."
  exit 0
fi

HITS=$(echo "$BLOCK" | grep -E "upgraded (systemd |systemd-libs|mkinitcpio )" || true)

if [[ -z "$HITS" ]]; then
  echo "OK: last transaction has no systemd/systemd-libs/mkinitcpio upgrade. Safe to reboot."
  exit 0
fi

echo "ATTENTION: boot-crypto update detected in last transaction:"
echo "$HITS"
echo ""
echo "This class broke TPM PCR 7 on 2026-09-12 (systemd 261.2->261.3 + mkinitcpio 41->42)."
echo "Signing-only updates (limine/vmlinuz/bundles) are safe — this is not one of those."
echo ""
read -r -p "Re-enroll TPM PCR 7 on both drives now? [y/N] " ANS
if [[ ! "$ANS" =~ ^[Yy]$ ]]; then
  echo "Skipped. Keep your slot-0 passphrase handy — next reboot may prompt."
  echo "Re-run this script anytime before reboot."
  exit 0
fi

echo "Re-enrolling root ($ROOT_UUID)..."
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 "/dev/disk/by-uuid/$ROOT_UUID"
echo "Re-enrolling storage ($STORE_UUID)..."
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 "/dev/disk/by-uuid/$STORE_UUID"

mkdir -p "$(dirname "$STATE_FILE")"
echo "$LAST_START:$LAST_LINE" > "$STATE_FILE"

echo ""
echo "Done. Safe to reboot."
echo "After reboot verify: journalctl -b 0 --no-pager | grep -c 'TPM policy does not match'  (expect 0)"
