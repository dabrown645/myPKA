---
name: Home Automation
tags:
  - technology
  - smart-home
---

# Home Automation

## Current Setup (Baseline — pre-migration)

**Controller:** Vera (circa 2017)
- Z-Wave only, local-first (no cloud dependency)
- Becoming unreliable — multiple devices acting up, no vendor support
- ~6–15 automations/scenes running

**Devices:** ~1–10 Z-Wave lights and switches

## Migration Plan

Replacing the Vera with Home Assistant running on a hybrid mini PC/NAS. See full research at [[Deliverables/2026-05-27-hass-vera-migration-research|Pax Research — HA + NAS Migration]].

**Target hardware:** Beelink ME Pro (N150, 16GB, 2-bay NAS)
**Z-Wave dongle:** Zooz ZST39 (800-series)
**Software stack:** Proxmox → HA OS VM + TrueNAS VM

## Open questions

- Frigate / AI camera NVR — whether to include in this build or later
- Exact storage capacity needed (how many TB for NAS)

## Sources

- [[Deliverables/2026-05-27-hass-vera-migration-research]]
