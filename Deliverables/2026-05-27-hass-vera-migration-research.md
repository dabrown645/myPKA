# Home Assistant + NAS: Vera Migration Research

**Pax Research Deliverable** — 2026-05-27
**Requested by:** Larry | **For:** David

---

## Executive Summary

David's Vera (2017, Z-Wave only) is end-of-life. The recommended replacement is a single **Beelink ME Pro** running **Proxmox** → HA OS VM + TrueNAS Scale VM for NAS. This gives full isolation, snapshots before every update, and room for Frigate later. The **Zooz ZST39** (800-series Z-Wave Long Range) is the best dongle at $28.95. **All existing Z-Wave devices must be excluded from Vera and re-paired to the new stick** — no NVM transfer is possible from Vera's proprietary stack. Budget estimate: **~$720–$1,120** depending on drives.

---

## 1. Hardware Deep-Dive

### 1.1 Beelink ME Pro — Larry's Pick

| Spec | Detail |
|---|---|
| CPU | Intel N150 (4C/4T, Twin Lake, 6W TDP) or N95 |
| RAM | 16 GB LPDDR5-4800 **soldered** (not upgradeable) |
| SATA bays | 2x 3.5"/2.5" (up to 72 TB raw) |
| NVMe | 3x M.2 2280 (1x PCIe 3.0 x2, 2x PCIe 3.0 x1) |
| Networking | 1x 5 GbE + 1x 2.5 GbE + WiFi 6 + BT 5.4 |
| Modular | Swappable mainboard tray (future Intel/AMD/ARM upgrades) |
| Price (N150/16GB) | **$559** (barebone) or **$679** w/ 1TB SSD |

**Why it wins over alternatives:**

- Only pre-built mini PC with 2x SATA + 3x NVMe + dual LAN (5GbE + 2.5GbE) in one box
- Swappable motherboard tray means the chassis outlives the CPU
- 3x NVMe slots let you dedicate one for OS/boot, one for Frigate recordings, one for cache
- 5 GbE + 2.5 GbE gives headroom for simultaneous HA traffic + NAS transfers + Frigate
- All-metal, quiet, smaller than typical 2-bay NAS
- 3-year warranty

**Caveats:**

- RAM is **soldered 16 GB max** — no 32 GB option. For HA + TrueNAS VM + Frigate this is tight but workable (see §6).
- Pre-order shipping (~35 days as of May 2026)

### 1.2 Alternatives Comparison

| Model | CPU | RAM | SATA | NVMe | LAN | Price | Notes |
|---|---|---|---|---|---|---|---|
| **Beelink ME Pro** | N150 | 16GB soldered | 2x 3.5" | 3x M.2 | 5G+2.5G | **$559** | Best overall; modular |
| **Aoostar R1** | N100 | Up to 16GB DDR4 SODIMM | 2x 3.5" | 1x M.2 | 2x 2.5G | **$269** | Cheaper, but 1 NVMe, no 5GbE, older CPU |
| **CWWK/Topton 6-bay ITX** | N100/N150 | Up to 48GB DDR5 SODIMM | 6x SATA | 2x M.2 | 2x 2.5G | **~$120–180 (board only)** | Requires own case/PSU; most flexible storage |
| **CWWK/Topton 8-bay** | N150 | Up to 48GB DDR5 | 8x SATA | 2x M.2 | 2x 2.5G + 1x 10G | **~$200–250 (board only)** | 10GbE future-proof; large case needed |
| **Custom build (ITX)** | i3-N305 | 32GB DDR5 SODIMM | 4-6 SATA | 2-3 M.2 | 2.5G | **~$400–600** | Most powerful, but larger, louder, pricier |

**Verdict:** The Aoostar R1 is a solid budget pick. The CWWK boards are best if David wants 4+ drives. But for a *single box* that does HA + NAS + Frigate without building a PC, the **Beelink ME Pro is the sweet spot**.

### 1.3 Z-Wave USB Dongle: Zooz ZST39

| Dongle | Chip | Price | Z-Wave LR | S2/SmartStart | Notes |
|---|---|---|---|---|---|
| **Zooz ZST39** | 800 series | **$28.95** | Yes (US) | Yes | Best value, 5yr warranty, lifetime support |
| HomeSeer SmartStick G8 | 800 series | $37.95 | Yes | Yes | Good; supports NVM migration *between 500/700 series* |
| Aeotec Z-Stick Gen5 | 500 series | ~$35 | No | No | **Do not buy** — obsolete 500-series, no LR, no S2 |

**Recommendation:** Zooz ZST39. It's the most popular dongle in the HA community, 800-series, Long Range capable, and $10 cheaper than the HomeSeer. Both work identically with Z-Wave JS in HA. Skip the Aeotec Gen5 entirely.

**Note on migration:** Neither the Zooz nor HomeSeer can do an NVM backup/restore from Vera. Vera uses a proprietary Z-Wave stack with an encrypted NVM. All devices **must** be excluded from Vera and re-paired. The HomeSeer's migration feature only works when coming from another 500/700-series Z-Wave stick, not from Vera.

### 1.4 RAM & Storage Layout

**RAM:**

- 16 GB is enough for HA VM (~2 GB) + TrueNAS VM (~4–6 GB) + Frigate LXC (~4 GB) = ~12 GB used. Tight but works. No swap thrashing if Frigate's `-O` (object detection) is tuned.
- If David wants headroom for more VMs later, the Beelink's 16 GB ceiling is a constraint. **If RAM needs are a concern, consider the CWWK board route** (up to 48 GB DDR5 SODIMM), but that means building a system.
- **Recommendation:** 16 GB is acceptable for the stated workload. Proxmover's ballooning helps.

**Storage layout (Beelink ME Pro):**

| Slot | Use | Drive |
|---|---|---|
| NVMe slot 1 (PCIe x2) | Proxmox boot + VM storage (OS) | 512 GB–1 TB NVMe SSD |
| NVMe slot 2 (PCIe x1) | Frigate recordings / HA backup target | 256–512 GB NVMe SSD |
| SATA bay 1 | NAS data pool (RAID 1 mirror) | 4–8 TB CMR HDD (WD Red Plus / Seagate IronWolf) |
| SATA bay 2 | NAS data pool (RAID 1 mirror) | Same size as bay 1 |

**Why:** The x1 NVMe slots are slower (~1 GB/s) but perfect for Frigate's ringbuffer and video clips. OS + VMs on the fast x2 slot. HDDs in RAID 1 for data integrity.

---

## 2. Software Stack Comparison

### 2.1 Three Approaches

| Criteria | **Proxmox → HA VM + TrueNAS VM** | **Unraid → HA Docker + NAS** | **Ubuntu + Docker → everything in containers** |
|---|---|---|---|
| **Concept** | Type-1 hypervisor. Two VMs: HA OS, TrueNAS Scale. Everything isolated. | Paid OS with parity-based storage. HA as Docker container. | Plain Ubuntu Server. HA + NAS + Frigate all in Docker Compose. |
| **Migration from Vera** | Run Vera integration in HA VM during transition, then cut over to Z-Wave JS. | Same — just in Docker HA. | Same — just in Docker HA. |
| **Backup** | Proxmox backup server (PBS) or vzdump snapshots of entire VMs. Restore in 5 min. | Unraid's built-in backup for appdata + shares. No VM-level snapshots without plugin. | Manual Docker volume backup or use borg/restic. Most manual. |
| **Snapshots before HA updates** | Yes — native Proxmox VM snapshots. **Best-in-class.** | No native VM snapshot (unless running a VM). Docker container snapshots via plugin. | Manual, or use docker commit + export. Fragile. |
| **NAS performance** | TrueNAS Scale VM gets raw disk passthrough. ZFS. Excellent. | Unraid's parity-based pool (single-drive parity). Slower writes but simpler expansion. | Use mergerfs + snapraid. Flexible but DIY. |
| **Frigate integration** | LXC container for Frigate (or VM). GPU passthrough for Coral. | Docker container. GPU passthrough works. | Docker container. Cleanest GPU access. |
| **Resource overhead** | Moderate (Proxmox KB + 2 VM kernels). ~2 GB overhead. | Low (single kernel). | Lowest (single kernel, no hypervisor). |
| **Learning curve** | Steepest: Proxmox, ZFS, networking. | Moderate: Unraid UI is friendly. | Moderate: Docker Compose + Linux admin. |
| **Cost** | **Free** (Proxmox VE). | **$59–$129** (Unraid licence). | **Free** (Ubuntu). |
| **Maintenance** | Proxmox updates quarterly. VM updates separate. | Unraid updates via UI. Docker updates via CA tool. | Ubuntu updates + manual Docker management. |

### 2.2 Larry's Pick: Proxmox → HA VM + TrueNAS VM

**Reasons:**

1. **Snapshots before HA updates** — this is the killer feature. A Proxmox VM snapshot takes 2 seconds and saves David hours if a HA update breaks something.
2. **TrueNAS VM** gives battle-tested ZFS with easy SMB/NFS shares. Disk passthrough for direct HDD access.
3. **Frigate** runs cleanly in a separate LXC or VM with Coral USB passthrough.
4. **Free** — no licence cost.
5. **Portable** — Proxmox backup can restore VMs onto any Proxmox host, making future hardware swaps trivial.

**Trade-off accepted:** Steeper initial setup. But David is technical (Linux, Docker, Proxmox) so this is fine.

### 2.3 When to pick the other two

- **Unraid** — choose if David values easy drive expansion (add one disk at a time) over ZFS data integrity. Unraid's parity is weaker than ZFS RAID 1, but adding a disk to a ZFS pool later is painful.
- **Ubuntu + Docker** — choose only if RAM is critically tight (under 16 GB). Or if David already has a strong Docker Compose workflow and wants zero virtualization overhead. Lacks isolation and snapshot safety.

---

## 3. Migration from Vera

### 3.1 Can Z-Wave devices be reused without re-pairing?

**No.** This is the single most important finding.

Vera uses a proprietary Z-Wave implementation with an encrypted NVM (network key store). There is **no tool** to extract the S0/S2 network keys or the node database. The physical Z-Wave chip in Vera is not a removable USB stick — it's soldered on the PCB.

| Task | Possible? | How |
|---|---|---|
| Transfer Z-Wave network (NVM) | **No** | Vera's NVM is encrypted/proprietary. No known path. |
| Reuse devices without re-pairing | **No** | Each device believes it belongs to Vera's network. Must be excluded first. |
| Reuse devices by excluding then re-pairing | **Yes** | Standard Z-Wave procedure. 100% of devices will work. |

**Process:**

1. Keep Vera powered on and connected during transition.
2. For each device: Put the Vera into exclusion mode **or** factory-reset the device (if supported). Then include it into the new Zooz ZST39 via HA Z-Wave JS.
3. Start with mains-powered devices (switches, plugs) — they act as repeaters and strengthen the mesh before you add battery devices.
4. Battery devices (sensors, locks) need to be woken up manually (usually a tap/press on the device) to be excluded and included.

**Estimated time:** 30–90 minutes for 20–30 devices. Most time is walking around the house.

### 3.2 Scenes and Automations

**No export path.** Vera scenes are stored in Vera's internal Lua engine database. There is no export format.

**Action:** David should:

1. Open the Vera GUI and take screenshots of every scene/automation.
2. Manually recreate them in Home Assistant automations.
3. This is a good time to simplify: many Vera scenes were workarounds for Vera's limited automation engine. HA can do more with fewer, cleaner automations.

**Gotchas:**

- Z-Wave devices will appear with **new entity IDs** in HA. All automations will need entity ID updates.
- Door locks with S0 security: You need the S0 network key. Since Vera's key can't be extracted, locks will need to be **excluded and re-included** fresh. If they had security set, do a factory reset of the lock before inclusion.
- Vera's zwave-plus-association-based scenes (direct device-to-device associations) cannot be replicated in HA the same way. Rebuild as HA automations.
- Battery sensors may show "dead" initially — walk around to wake them or wait for their next wake interval.

### 3.3 Using Vera integration as a bridge (temporary)

Home Assistant has a native [Vera integration](https://www.home-assistant.io/integrations/vera/) that can poll the Vera controller over the network (port 3480). For a transition period, David could:

1. Set up HA with the Vera integration first.
2. Get all devices showing in HA.
3. Build automations in HA while Vera still handles the Z-Wave radio.
4. Then, one by one, exclude from Vera and re-pair to the Zooz stick.
5. Remove Vera integration once all devices are migrated.

This **reduces downtime** — HA automations keep working throughout the transition.

---

## 4. NAS Considerations

### 4.1 Is the N150 enough for concurrent HA + NAS + light Plex?

**Yes, with caveats.**

| Workload | CPU impact | RAM impact | N150 capable? |
|---|---|---|---|
| Home Assistant (Core + Companion) | Minimal (~5% idle) | ~1–2 GB | Yes, easily |
| TrueNAS NAS (SMB/NFS file serving) | Minimal (I/O bound) | ~2–4 GB (ZFS ARC) | Yes |
| **Plex direct play** (no transcoding) | Minimal | ~1 GB | Yes |
| **Plex 1080p transcoding** (1 stream) | Moderate | ~2 GB | **Yes** — Quick Sync hardware transcoding works on N150 |
| **Plex 4K transcoding** (1 stream) | High | ~3 GB | **Borderline** — N150's 24 EU iGPU can do 1x 4K→1080p transcode, but not 2+ |
| Frigate (4–6 cameras, Coral TPU) | Low (Coral offloads AI) | ~3–4 GB | Yes, with USB Coral |
| All concurrently | Moderate | ~12 GB total | **Yes, but 16 GB is tight** |

**Key insight:** The N150 has Intel Quick Sync Video (Twin Lake iGPU with 24 EUs). Plex hardware transcoding works. One 4K transcode is fine. Multiple simultaneous 4K transcodes will choke.

**For "light Plex"** (1–2 direct play streams, occasional 1080p transcode), the N150 is perfect. If David wants heavy 4K transcoding (multiple family members remotely), consider the i3-N305 or a separate mini PC for Plex.

### 4.2 2-bay (RAID 1) vs 4-bay flexibility

| Factor | 2-bay (Beelink ME Pro) | 4-bay (CWWK board + case) |
|---|---|---|
| **RAID** | RAID 1 mirror only | RAID 5/6/10, ZFS RAID-Z |
| **Usable capacity** | 50% of raw (e.g. 2×8 TB = 8 TB usable) | 75%+ (e.g. 4×8 TB RAID 5 = 24 TB usable) |
| **Drive failure** | Lose 1 drive, keep running. Replace and resilver. | Lose 1 drive, keep running. More resilient options. |
| **Expandability** | Replace both drives with larger ones to grow. Painful. | Add one drive at a time (Unraid) or replace in pairs (ZFS). |
| **Power / noise** | Lower. 2 drives + efficient mini PC. | Higher. 4+ drives + larger case/PSU/fans. |
| **Form factor** | All-in-one shoebox. | Separate case + motherboard + PSU + cables. |

**Recommendation:**

- **2-bay is fine** for David's use case — HA + NAS + light Plex. Most home users don't need more than 8–12 TB usable. Starting with 2× 8 TB HDDs in RAID 1 gives 8 TB usable.
- Upgrade path: When 8 TB fills up, replace with 2× 20 TB drives → 20 TB usable.
- If David anticipates 20 TB+ storage needs (large media library, security footage retention, etc.), **start with a 4-bay build**. The Beelink is a 2-bay box and can't be upgraded to 4-bay.

---

## 5. Budget Estimate

| Item | Option | Price |
|---|---|---|
| **Mini PC** | Beelink ME Pro (N150, 16 GB, no storage) | $559 |
| **NVMe OS drive** | 512 GB NVMe SSD (e.g. WD SN580) | $55 |
| **Frigate NVMe** | 256 GB NVMe SSD | $30 |
| **NAS HDDs (2×)** | 2× 8 TB WD Red Plus (CMR) | $260 ($130 ea.) |
| **Z-Wave dongle** | Zooz ZST39 | $29 |
| **Coral TPU** | USB Coral Accelerator (for Frigate) | $60 |
| **Total (recommended)** | | **~$993** |
| **Budget option** | Aoostar R1 + 1× 8 TB HDD + same dongle | ~$594 |
| **Premium option** | CWWK 6-bay board + 32 GB RAM + 4× 8 TB HDD + case + PSU | ~$1,200–1,500 |

### Optional extras

| Item | Price | Why |
|---|---|---|
| Proxmox Backup Server (PBS) | Free | Run as LXC for VM-level backup |
| UPS (CyberPower 1500VA) | $150 | Protect the single point of failure |
| 5 GbE switch | $50–80 | Use the ME Pro's 5 GbE port fully |
| Larger NVMe (1 TB) | +$40 | More room for VM disk images |

---

## 6. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| 16 GB RAM too tight with Frigate | Medium | High | Tune ZFS ARC limit (4 GB max). Frigate with Coral uses ~3–4 GB. Total ~12 GB. Monitor and reduce if needed. |
| Vera cannot export Z-Wave keys | Certain | Medium | Factory-reset door locks if S0 key is lost. All other devices include fine without it. |
| Plex 4K transcoding performance | Low-Medium | Medium | Direct play on local network. Transcode only for remote. Consider a separate $150 N100 box for Plex if needed. |
| Beelink RAM is soldered | High | Medium | Accept 16 GB constraint. If truly insufficient, sell ME Pro and move to CWWK board with 48 GB support. |
| 2-bay capacity ceiling | Medium | Low | Monitor usage. This is a 2–3 year horizon problem. By then, larger HDDs will be cheaper. |

---

## Summary of Key Findings

1. **Hardware: Beelink ME Pro ($559)** is the best single-box solution. Modular mainboard, 5+2.5 GbE, 2× SATA + 3× NVMe. RAM is soldered 16 GB max — the main trade-off.
2. **Z-Wave: Zooz ZST39 ($29)** is the clear winner. 800-series, Long Range, S2/SmartStart. 5-year warranty.
3. **Software: Proxmox → HA VM + TrueNAS VM.** Free, best snapshot support, maximum isolation. David's Linux/Proxmox experience makes the learning curve manageable.
4. **Migration: every device must be excluded from Vera and re-paired.** No shortcuts. Use the HA Vera integration as a bridge for zero-downtime transition.
5. **N150 is enough** for concurrent HA + NAS + light Plex (1–2 streams, occasional 4K transcode). Frigate with Coral is comfortable at 16 GB total if ARC is tuned down.
6. **Budget: ~$993** all-in including HDDs, dongle, Coral. ~$594 on a budget build with Aoostar R1.
7. **2-bay is fine for now.** 4-bay only if David anticipates 20 TB+.
