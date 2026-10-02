---
agent_id: larry
session_id: pkm-frameworks-vs-icor-performance
timestamp: 2026-10-02T01:27:00Z
type: close-session
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: []
linked_guidelines: ["GL-002-frontmatter-conventions", "GL-005-llm-agnostic-portable-core"]
---

# Frameworks vs ICOR + myKnowledge performance audit

## Context

David asked for competing PKM frameworks vs ICOR for Life/myPKA, then drilled into Forte/Milo, then into response-time lag between `~/Projects/icore/myKnowledge` (ICOR-for-Life + myPKA) and this folder (myPKA 5.5.2). Session ran in myPKA 5.5.2 as Larry orchestrating Pax/Silas passes.

## What we did

- Larry routed framework survey to Pax: returned PARA/BASB, Zettelkasten, LYT/Ideaverse, GTD, Johnny Decimal, Bullet Journal/ZTD/12WY with confidence levels.
- Pax returned Forte deep dive (PARA + CODE/BASB, AI Second Brain 2026 cohort, Personal Context Management) and Milo deep dive (MOCs, ACE Atlas/Calendar/Efforts, ARC).
- Pax returned PARA+BASB vs ICOR AI-integration contrast (1 assistant + skills vs team with contracts, synced folders vs portable core + adapters).
- Larry clarified PARA ranked #1 as default starting point, not best; explained anchor + carrier rule as ICOR differentiator.
- Silas audited both vaults from here (read-only): myKnowledge 294 md / 23MB / 16 agents / 12 Obsidian plugins; myPKA 5.5.2 ~241 md / 16MB / 9 agents / no plugin runtime.
- Silas ranked cost drivers in myKnowledge: duplicate `03 WiP/_archive/2026-10-01-import-mypka-main`, `.obsidian/plugins` 5.7MB (chat 2.1MB), `06 AI Team/AI Team Knowledge` 11.5MB (Avatars 8.2MB), frontmatter drift 11/25 sampled missing, `.icor-for-life/CHANGELOG.md` 180kb outlier.
- Larry confirmed logic is not all in `06 AI Team`: root AGENTS.md/ADAPTER-PROMPT.md + `.icor-for-life/manifest.json` + `.mypka/` + adapters + plugins + content folders all point into it.
- Larry quantified no-Obsidian saving (~6.2MB / 27% disk, larger per-question time save) and confirmed opencode in myKnowledge skips plugin tax with zero changes.

## Decisions made

- **Question:** Where to run Silas audit? **Decision:** Read-only from myPKA 5.5.2 via absolute path; nothing written to myKnowledge.
- **Question:** Migrate to SQLite now? **Decision:** No. Stay on markdown; apply scoping + dedup + plugin trims first per SOP-002 thresholds (<1000 stay, ~5000 migrate).
- **Question:** Delete duplicate archive? **Decision:** Proposed, not yet approved. Next step lists exact move.

## Insights

- myKnowledge is ICOR-for-Life scaffold v2.0.1 + myPKA embedded (mode A/B per its AGENTS.md) — two layers, so slower than lean 5.5.2 by construction.
- Biggest instant win is deleting `03 WiP/_archive/Operations/2026-10-01-import-mypka-main` (double hits on every search).
- Second win isAvatars/Brand under `06 AI Team/AI Team Knowledge` — 9.5MB binary/brand weight in the AI-read path; belongs in `05 Assets/`.
- Chat plugin tax (snapshot + open note + archiving) dominates per-question latency vs CLI scoped reads.

## Realignments

- "I see it is listed as number 1 PARA" — Larry first read as vault location; David meant ranking in answer. Corrected to ranking rationale.
- "answered wrong question. I am comparing response time between icor-for-live/myPKA and myPKA 5*" — Larry first answered PARA vs ICOR. Corrected to myKnowledge vs 5.5.2 after David supplied paths (`~/Projects/icore/myKnowledge` resolved to `~/Projects/icore/myKnowledge`).
- "Do I need to be in myKnowledge to do that" — answered no, audit can run via absolute path.

## Open threads

- [ ] David to approve delete/move of `03 WiP/_archive/2026-10-01-import-mypka-main` out of vault.
- [ ] Optional Silas frontmatter pass on `04 Inner World` + `03 WiP` (11/25 missing) per GL-1002.
- [ ] Optional plugin trim: keep chat + 1-2, disable terminal/sqlite-viewer/planner when not in use.
- [ ] No Deliverable written this session; offer stands for PARA-vs-MOC side-by-side map if wanted.

## Next steps

- Provide exact move/delete commands for #1 + Avatars/Brand on David's go-ahead.
- Re-time opencode in myKnowledge with Obsidian closed vs open to confirm gain.

## Cross-links

- Prior close in same window: `2026-10-01-10-14_larry_rog1-hdmi-battery-power` — unrelated hardware thread, no content link.
