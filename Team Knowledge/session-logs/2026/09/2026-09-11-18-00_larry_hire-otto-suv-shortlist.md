---
agent_id: larry
session_id: hire-otto-suv-shortlist-2026-09-11
timestamp: 2026-09-11T18:00:00Z
type: close-session  # close-session | mid-session-insight | realignment | proactive
linked_sops: ["SOP-001-how-to-add-a-new-specialist"]
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions"]
---

# Hired Otto and built 98682 SUV shortlist

## Context

David asked to hire an auto procurement specialist, then immediately put him to work deciding car/truck/SUV for a retired second car behind an Ioniq 6, grandkids plus road trips, $35k OTD firm at 98682.

## What we did

- Larry routed the hire to Nolan per [[SOP-001-how-to-add-a-new-specialist]]; Nolan asked one scoping question (answer: buy personal cars).
- Nolan briefed Pax; Pax returned triangulated buyer-advocate research to `Deliverables/2026-09-11-auto-procurement-hire-research.md` (flat-fee OTD competition, not dealer-paid broker).
- Nolan drafted Otto (Auto Procurement Specialist); David approved the name.
- Hired Otto: contract at `Team/Otto - Auto Procurement Specialist/AGENTS.md`, shim at `.claude/agents/otto.md` (Claude Code only host active), journal template copied with matching md5, rows added to `[[agent-index]]`, root `AGENTS.md` (now 8 specialists), and Larry routing cheatsheet. No Workstream update — no recurring orchestration yet.
- Otto ran intake (retired, Ioniq 6 primary, grandkids, road trips, <$35k, exploring) and web research (compact SUV pricing/safety, Maverick vs Santa Cruz, IIHS pages, CPO listings, 98682 8.9% tax, WA $200 doc cap).
- Otto delivered ranked shortlist to `Deliverables/2026-09-11-otto-shortlist-98682.md`: CPO 2024 Sportage Hybrid EX first, Tucson Hybrid SEL Convenience second, 2022–23 RAV4 Hybrid XLE + Weather stretch third, CR-V fourth on safety footnote.
- Compared Sportage vs Tucson (tie on paper, buy best CPO example) and Santa Cruz (loses for David: open bed, no hybrid, OTD bust, resale fog).
- Confirmed light towing/dump/kayak duty covered by all three (RAV4 3,500 lbs best; Koreans 2,000/1,650); added hitch + crossbars as optional reminder list, not required.
- Saved standing watchlist in the shortlist file: 50 mi radius of 98682, trigger phrase "Otto, check the watch", no dealer contact until a find clears the bar. David is not ready to pull VINs yet.

## Decisions made

- **Question:** Who owns personal-car buying? **Decision:** Otto, buyer-aligned flat-fee only, no dealer commissions, no title-taking.
- **Question:** Car, truck, or SUV for David? **Decision:** 2-row compact hybrid SUV; sedan redundant with Ioniq 6, truck only wins on weekly dirty hauling.
- **Question:** 3-row or not? **Decision:** No 3-row at all — 5 local max, 4 road-trip max, large 3-rows explicitly skipped, then compact 3-rows dropped too.
- **Question:** New or CPO? **Decision:** CPO 2022–24 preferred — new either busts $35k OTD or misses heated seats; CPO EX/SEL/XLE fits $28.8–34.6k OTD with headroom.
- **Question:** How to handle the wait? **Decision:** Standing watchlist, periodic checks on request, "wait" is an acceptable report.

## Insights

- $35k OTD at 98682 = $31,680 selling-price ceiling (8.9% + ~$500 fees) — this single number eliminated every new heated-seat trim except base strippers.
- Heated-seats-minimum is the stealth budget driver: forces EX/SEL/XLE grade, which is exactly where CPO beats new.
- CR-V's reputation vs test data split: roomiest and most refined, but 2023+ Poor on updated moderate-overlap rear-passenger metrics — worth stating plainly when grandkids ride along.
- RAV4 heated seats hide behind the Weather Package — most used listings fail the filter on that alone.

## Realignments

- "I am open to CPO in addition to new" — shifted plan from new-only to CPO-first.
- "Top safety is important and minimum of heated front seats" — added safety + trim gates.
- "skip large 3-row SUVs" → then "5 passenger locally is sufficient and 4 for road trip max" — collapsed the universe from 3-rows back to 2-row compacts.
- "Put on list so I don't forget about them but don't make them required" (hitch/crossbars) — accessories = reminder, not purchase gates.
- "I am not ready to actually pull vins yet" — switched from active sourcing to patient watch mode.

## Open threads

- [ ] Watch: "Otto, check the watch" — scan CPO within 50 mi of 98682 against standing criteria.
- [ ] David to share test-drive picks (1+2 or 1+3) when ready; Otto then runs VIN-level OTD negotiation.
- [ ] Log-the-hire line for persistence: Hired Otto as Auto Procurement Specialist after Pax research. Brief at `[[2026-09-11-auto-procurement-hire-research]]`. Contract at `[[Team/Otto - Auto Procurement Specialist/AGENTS]]`. Shim at `.claude/agents/otto.md`.

## Next steps

- Next session: run the watch on request or on David's "check the watch" ping; report hits with OTD math or clean "wait".
- No structural debt left open.

## SSOT / structural fixes (Librarian pass)

- Verified Otto registration in all four places: `[[agent-index]]`, root `AGENTS.md` (count 7→8 + row), Larry routing cheatsheet row, shim + contract + journal template present with matching md5.
- Research-brief wikilink `[[2026-09-11-auto-procurement-hire-research]]` resolves to the Deliverables file; no broken links introduced.
- No duplicate facts created; no INDEX.md updates required (Deliverables is datestamped working surface, no index).

## Cross-links

- Prior related: `Team Knowledge/session-logs/2026/09/2026-09-08-car-research-project-and-suv-comparisons.md`
