---
agent_id: larry
session_id: opencode-free-models-coding-research-defaults
timestamp: 2026-09-04T15:18:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions"]
---

# Free-model picks: Muse Spark for coding, MiMo for research

## Context

You asked which of OpenCode's free models is best for general product research vs coding, picked MiniMax + MiMo from the first recommendation, then asked whether making them defaults means automatic switching — and approved writing the config.

## What we did

- Pax cross-checked the OpenCode docs, Zen catalog, and models.dev: confirmed the current free tier (`big-pickle`, `mimo-v2.5-free`, `muse-spark-1.2/1.3-contributor-free`, Nemotron trials) and SWE-bench ordering for the coding picks.
- Larry corrected the first recommendation before writing anything: "MiniMax M2.5 Free" from a third-party ranking does not exist on Zen — paid M2.5 is deprecated Aug 2026, M2.7/M3 are paid ($0.30/$1.20 per 1M). You picked `Muse Spark 1.3 free` as the coding default via the question prompt; MiMo-V2.5 Free stayed as research pick.
- Larry wrote `~/.config/opencode/opencode.jsonc` (global scope): `model` = `opencode/muse-spark-1.3-contributor-free`, `agent.general` + `agent.explore` = `opencode/mimo-v2.5-free`, `small_model` = `opencode/mimo-v2.5-free`. Verified valid JSON with correct keys.
- Larry explained the switching model: per-agent assignment, not per-prompt intent detection — build/plan run Muse Spark, delegated research subagents run MiMo.

## Decisions made

- **Question:** Coding default given MiniMax free is unavailable?
  **Decision:** `opencode/muse-spark-1.3-contributor-free` (1M context, coding-tuned, $0).
- **Question:** Research model?
  **Decision:** `opencode/mimo-v2.5-free` (large context, general reasoning, $0), also assigned to `general`/`explore` subagents and `small_model`.
- **Question:** Config scope?
  **Decision:** Global (`~/.config/opencode/opencode.jsonc`) so defaults apply in every project, including myPKA.

## Insights

- Third-party "free model" rankings (e.g. free-coding-models repos) go stale fast — the Zen pricing/deprecation tables are the authority for what is actually $0 today. Always reconcile before recommending.
- OpenCode config model IDs use the `opencode/<model-id>` prefix for Zen (e.g. `opencode/mimo-v2.5-free`), per the Zen docs endpoint table.
- Free Zen models carry training-data terms (MiMo/Big Pickle may be used for improvement; Muse Spark contributor tier trains future Meta models) — worth surfacing whenever recommending $0 picks.

## Realignments

- _(none this session — the MiniMax correction was Pax self-correcting from docs before any write, not user pushback)_

## Open threads

- [ ] You to quit and restart OpenCode so the new config loads (config is read once at startup).
- [ ] If either free model disappears or rate-limits bite, revisit: `big-pickle` is the next free coding fallback.
- [ ] Open offer stands: switch to a paid zero-retention default for sensitive work on request.

## Next steps

- After restart, verify with `/models` in the TUI that both defaults resolve.
- Next session continues with Muse Spark on build, MiMo on delegated research — no manual switching needed.

## Cross-links

- `[[2026-09-04-15-00_larry_luks-recovery-codes-and-procedure-fix]]` — earlier session today (LUKS recovery procedures).
