---
agent_id: larry
session_id: dc-metro-car-scan-close
timestamp: 2026-09-22T01:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# DC metro vs PNW car scan + VIN review

## Context

David asked Otto to compare prices and availability for his shortlist in the Washington DC metro while registering in Vancouver WA 98682, then had a VIN checked. Session spanned Plan mode into Build mode.

## What we did

- Larry answered OpenCode TUI question: `tab` is autocomplete, `shift+tab` is `agent.cycle` to Plan — David confirmed shift+tab works.
- Larry located the list: `[[car-research-for-second-car]]` + `Deliverables/2026-09-11-otto-shortlist-98682.md` (Sportage Hybrid EX, Tucson Hybrid SEL Convenience, RAV4 Hybrid XLE + Weather, $35k OTD firm, $31,680 selling ceiling).
- Otto in Plan mode scoped DC scan with WA 8.9% OTD math, then in Build mode pulled DC vs Portland/Vancouver comps via Capital One, CarGurus, TrueCar snippets.
- Otto reviewed VIN KNDPYDDHXT7294873: 2026 Sportage Plug-In Hybrid X-Line AWD, Wolf Gray/Terracotta, 6k mi, CPO, $34,309 at Beaverton Kia → $37,863 OTD, fails 500-mi veto (470 total) and budget.

## Decisions made

- **Question:** Does DC get taxed differently since David is there?
  **Decision:** No — still registering 98682, so OTD = selling x 1.089 + $500. Trip/ship sunk because David is in DC for other reasons.
- **Question:** Is DC systematically cheaper or better stocked for the 3 gated hybrids?
  **Decision:** No. Prices flat to higher for comparable CPO miles; availability tied (Sportage 18 DC vs 19 Portland) or PNW better (RAV4 XLE 118 DC vs 148 Portland). Shop DC opportunistically only.

## Insights

- Capital One/Autotrader/CarGurus/Edmunds all block scraping (403/406); Capital One HTML still yields prices, miles, VINs, dealers.
- Exact-trim scarcity dominates: Tucson SEL Convenience Hybrid shows zero exact hits in DC filter; RAV4 Weather Package rarely confirmed on listing; 2023 EXs pollute 2024+ Sportage searches.
- Same VIN bouncing across Lanphere group stores ($34,309 / $35,309 / $36,059) — always re-confirm current selling price in writing.

## Realignments

- "I would still be registering it in Vancouver WA" — kept WA OTD math for DC cars.
- "I would pick up in DC not ship back to WA" → "I have to be in DC for other reasons so don't count trip cost" — dropped $1,000-1,500 ship/fly-drive allowance from comparison.

## Open threads

- [ ] Tucson SEL Convenience $26,495 (15k mi, Certified) and 2025 Sportage EX $30,993 Chantilly (10k mi, CPO) are the only two DC leads worth a quote sheet — David to pick one.
- [ ] VIN K25433 walks unless seller meets ≤$31,680 selling; needs CPO sheet + in-service date + heated/BSM sticker photo + PPI + Carfax before any deposit.
- [ ] No deal packet written yet; Otto to draft `Deliverables/YYYY-MM-DD-<vin>-deal.md` on request.

## Next steps

- David confirms target VIN; Otto runs out-of-state OTD + negotiation script in writing.
- Next session: live re-pull for chosen VIN only, not full market.

## Cross-links

- `[[2026-09-19-23-00_larry_otto-suv-vin-decode-close]]` — prior VIN-decode close.
- `[[2026-09-17-00-30_larry_otto-watch-suv-sedan-checks]]` — Otto watch checks.
- `[[2026-09-11-otto-shortlist-98682]]` — $35k OTD shortlist SSOT for gates.
