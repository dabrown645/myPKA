---
agent_id: larry
session_id: linux-distro-comparison-2026-07-08
timestamp: 2026-07-08T08:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Linux Distro Comparison: Debian Testing vs Arch vs Tumbleweed

## Context

David asked for a comparison of Debian Testing to Arch Linux this morning, then narrowed the focus to kernel versions, non-Arch alternatives near kernel 7.0, and ultimately OpenSUSE Tumbleweed as a candidate — including its package format and Secure Boot/TPM support.

## What we did

- Larry provided a comparison of Debian Testing vs Arch Linux across multiple dimensions.
- Larry researched current kernel versions: Debian Testing (6.12 LTS) vs Arch (7.0.10).
- Larry identified non-Arch distros near kernel 7.0: Fedora 43 (7.0.14), OpenSUSE Tumbleweed (~7.0.x), Parrot OS (7.0).
- Larry compared OpenSUSE Tumbleweed to Arch Linux.
- Larry confirmed Tumbleweed uses RPM packages with zypper.
- Larry confirmed Tumbleweed supports Secure Boot and TPM2 disk unlock via systemd-cryptenroll or Clevis.

## Decisions made

- _(none — informational session)_

## Insights

- Debian Testing ships with kernel 6.12 LTS; Arch is on 7.0.10 — a full major version ahead.
- Fedora 43 is on 7.0.14, making it the strongest non-Arch option for recent kernels.
- OpenSUSE Tumbleweed offers rolling release with btrfs + snapper built-in, making it more resilient than Arch for kernel-PCR-bound TPM setups.
- TPM auto-unlock on Tumbleweed has rough edges with sdbootutil but is functional.

## Realignments

- _(none this session)_

## Open threads

- [ ] David to decide if he wants to evaluate Tumbleweed or Fedora further.
- [ ] Consider capturing Linux distro comparison as a PKM Topic if this becomes a recurring interest.

## Next steps

- No immediate action items — informational session complete.

## Cross-links

- _(first session log)_
