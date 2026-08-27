---
agent_id: larry
session_id: mdgrok-urls-bookmark
timestamp: 2026-05-26T21:10:00Z
type: proactive
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Saved mdgrok URLs for TomSolid/myPKA comparison

## What was saved

David asked me to fetch and compare two mdgrok URLs about myPKA, then asked me to "remember these so I can come back to them later."

## The two URLs

| URL | What it is |
|---|---|
| `https://mdgrok.com/files/355997` | Single-file detail page for `AGENTS.md` (v3, current). Shows full document content, version history (v3 ← v2 ← v1), and a diff/comparison tool between versions. |
| `https://mdgrok.com/repos/TomSolid/myPKA` | Repository overview page for the entire `TomSolid/myPKA` repo. Shows repo description, token stats (120k tokens, 60% of context window), GitHub link, and a file tree listing of all files with their full content embedded. |

## Key insight

These are two views of the same repo on mdgrok:
- `/files/355997` — focused, version-aware single-file view
- `/repos/TomSolid/myPKA` — full multi-file project browser

Both contain the same `AGENTS.md` root orchestration contract content, but the repo view also includes CONTRIBUTING.md, Deliverables/README.md, Expansions/INDEX.md, NOTICE.md, PKM files (INDEX, seeded CRM samples for Dr. Schmidt, passport document stub, Images index), and more. The file view has version-switching and diff tools that the repo view lacks.
