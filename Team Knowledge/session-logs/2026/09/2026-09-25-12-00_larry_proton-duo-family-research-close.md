---
agent_id: larry
session_id: proton-duo-family-research-close
timestamp: 2026-09-25T12:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Proton Duo/Family mail + calendar + drive deep-dive

## Context

David asked for Proton Mail suite research, narrowed to Duo/Family comparisons, then worked through shared email, calendars, Drive, and Linux/Windows/iOS app coverage.

## What we did

- Larry routed Proton suite research to Pax protocol (subagents down, ran direct).
- Pax returned triangulated plans/privacy/comparison brief to `Deliverables/2026-09-25-proton-mail-suite-research.md`.
- Larry verified Duo/Family quotas, Groups limits, photo backup, calendar sharing, Drive Shared-with-me sync, Bridge/VPN/Drive Linux packaging from primary Proton support docs.
- Larry walked David through Duo setup: 3-address pattern, family@ forwarding vs SimpleLogin multi-mailbox send-as, his/hers/shared calendars, private/shared Drive, per-OS app gaps.

## Decisions made

- **Question:** Duo vs Family for 2 people?
  **Decision:** Duo (2 users, 3 domains, 30 addresses, 2 TB shared). Family only if 3-6 seats or 3 TB needed.
- **Question:** How to do shared family@ on Duo with both able to send?
  **Decision:** SimpleLogin multi-mailbox alias owned by both mailboxes; native Duo has no shared send-as (Groups is Workspace-only).
- **Question:** Calendar pattern?
  **Decision:** Leaning his/hers/shared with Edit on shared, View on personals.
- **Question:** Drive pattern?
  **Decision:** Private per-user plus shared Family folder; Windows sync OK via Shared-with-me, Linux shared = web/CLI only.

## Insights

- Duo admin owns all address/domain work; invitee must be on Free at invite time and loses custom-domain addresses on leaving.
- family@ lives on admin login; inbound sharing via filter-forward or SimpleLogin, outbound both-send-as only via SimpleLogin reverse-alias (clunky vs Gmail From dropdown).
- Proton Drive Windows Shared-with-me sync now works (Sync toggle); earlier gap closed. Linux still no official GUI.
- Bridge on Arch extra + Flathub, VPN on Flatpak + Arch package, Drive GUI missing on Linux.

## Realignments

- _(none this session)_

## Open threads

- [ ] David to confirm domain ownership + registrar for DNS (MX/SPF/DKIM/DMARC) walkthrough.
- [ ] Decide family@ send-as path: admin-only vs SimpleLogin dual-owner vs spare Family seat.
- [ ] Optional follow-up: Easy Switch Gmail import + photo library sizing for 2 TB split.

## Next steps

- When David returns with domain/registrar, walk DNS + Users-and-addresses + filter creation clicks.
- Write Duo setup checklist deliverable if requested.

## Cross-links

- `[[2026-09-24-13-38_larry_mypka-hotkey-ssh-agent-fix]]` — most recent prior close log.
