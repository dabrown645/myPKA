---
agent_id: larry
session_id: ollama-purge-voice-programming-doctrine
timestamp: 2026-09-08T20:20:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Ollama purged, voice/programming doctrine agreed, session parked in planning

## Context

David came in on local Ollama models hanging under full Larry, pivoted through voice and programming scope, and parked everything in planning with a purge executed in Build.

## What we did

- Rex diagnosed the hang (deepseek-r1:7b at -c 4096, 1226 reasoning tokens then client cancel) and executed the full purge to verified clean (Larry orchestrated, user ran the one sudo command).
- Larry mapped the myPKA launcher into a flowchart and confirmed the vault/code split against ~/.local/bin/myPKA (read-only).
- Larry clarified voice (Whisper/Piper, no local LLM) and the fork/personal-to-public rules with David.

## Decisions made

- **Question:** Keep local LLMs? **Decision:** No — full purge, cloud-only (muse-spark-1.3 + mimo-v2.5-free) until 24GB+ VRAM exists.
- **Question:** One vault or two? **Decision:** One vault, many repos; SSOT WHY/WHAT in Deliverables, HOW in repo, links vault→repo only.
- **Question:** External handoff shape? **Decision:** Frozen export with provenance, or repo-canonical if client co-owns from day one.
- **Question:** Voice architecture? **Decision:** Interface layer (local STT/TTS, cloud brain), on-demand processes, no wake-word daemon.

## Insights

- Voice interface ≠ local LLM: 1GB ears + 100MB mouth fit the 8GB 4060; 5GB reasoning brains don't fit full Larry.
- The myPKA launcher's sync gates (stash-before-rebase, force-with-lease, commit prompt) are the reusable pattern for code repos and forks.

## Realignments

- "So they would be usable in other context just not in myPKA" — corrected to: usable for chat/small code, not for full orchestration as configured.
- "are you saying I can install a local llm for just doing the voice" — corrected: no local LLM needed; Whisper/Piper aren't LLMs.
- "doesn't this fall into system administration? I know you Larry provided all the info" — acknowledged; routed to Rex explicitly from there.

## Open threads

- [ ] Hire dev specialist via Nolan vs informal programming help.
- [ ] Voice wrapper mode: explicit speak/hear vs session-long voice.
- [ ] Launcher: parameterize myPKA with target dir vs thin second launcher.
- [ ] my-cli-tool was hypothetical; no remote, nothing committed — no action.

## Next steps

- Flip to Build when ready; Larry writes this log file first, then takes the next locked decision.

## Cross-links

- (none — no prior session log referenced this session)
