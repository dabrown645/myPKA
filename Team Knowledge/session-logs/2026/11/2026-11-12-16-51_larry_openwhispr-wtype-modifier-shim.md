---
agent_id: larry
session_id: openwhispr-wtype-modifier-shim
timestamp: 2026-11-12T23:51:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# OpenWhispr pasted a bare `v` on COSMIC — wtype drops modifiers; fixed with a PATH shim

## Context

David came in asking why OpenWhispr (AppImage, push-to-talk on RightAlt) inserted a
bare literal `v` instead of the transcript, and whether to abandon the tool for
another set. Transcription itself was healthy (six `completed` rows in
`~/.config/open-whispr/transcriptions.db`); the failure was in the paste step.

## What we did

- Larry traced the paste orchestrator inside `app.asar` and mapped the full
  decision tree for COSMIC + Wayland + terminal target: the app sends
  `wtype -M ctrl -M shift -k v -m shift -m ctrl` (ghostty's paste chord) and
  treats `wtype`'s exit code 0 as success, then returns before any fallback.
- Larry extracted the app's own `getCosmicActiveAppId()` module and ran it
  against the live Wayland socket — confirmed the focused window is
  `com.mitchellh.ghostty` (in the app's terminal-class list).
- Larry ran empirical keystroke tests into David's focused window, isolating the
  failure: stock `wtype` strips both Shift and Ctrl on cosmic-comp
  (`shift+a` → `a`, chord → bare `v`, always rc=0). `-s` delay did not help.
- Larry proved the working paths: `ydotool key <keycodes>` preserves modifiers,
  and the app's own `linux-fast-paste --uinput --terminal` pastes the clipboard
  correctly. Shift+Insert on this ghostty reads the **primary** selection, not
  the clipboard — and the app writes the transcript to both, so its fallbacks
  would have worked had they ever run.
- Larry installed the fix: `~/.nix-profile/bin/wtype`, a Python shim that
  translates `wtype` modifier chords (`-M/-m/-k/-P/-p`) into `ydotool key`
  evdev-keycode sequences and passes everything else through to
  `/usr/bin/wtype`. Placed first in PATH, which both David's shell and the
  running app (`/proc/28356/environ`) already had as their first entry — no
  sudo, no app restart needed.
- Larry verified all three paths live: Shift chord → `A`, the app's exact
  Ctrl+Shift+V chord → pasted clipboard marker, plain text → unchanged.
- David confirmed end-to-end: push-to-talk dictation now transcribes and pastes
  a full sentence into ghostty.
- David challenged the shim location (`~/.nix-profile/bin` vs `~/.local/bin`).
  Larry measured all three PATHs — app (`/proc/28356/environ`), shell, and
  `systemctl --user show-environment` — and established why they differ: the
  App menu launch inherits the systemd user session env (no `.local/bin`),
  while David's shell prepends `.local/bin` from his shell rc. The app's PATH
  does not contain `~/.local/bin` at all, so a shim there would have worked in
  the terminal but been invisible to OpenWhispr — the fix would have looked
  done and done nothing. Both chains resolve `wtype` → the shim (verified with
  a simulated login using David's exact PATH order).

## Decisions made

- **Question:** Abandon OpenWhispr for another dictation tool?
  **Decision:** No. The product was sound; one compositor-level bug was at
  fault. Keep OpenWhispr, fixed locally via the wtype shim.
- **Question:** Where does the fix live?
  **Decision:** `~/.nix-profile/bin/wtype` (shadows `/usr/bin/wtype`). Remove
  that one file to undo. Not a wiki SOP — it is machine-local config, recorded
  here as session memory.
- **Question:** Is PATH authority the AppImage, the session, or `.bashrc`?
  **Decision:** None globally — PATH is per-process inheritance. The only
  authority that matters for placing a shadow binary is the PATH of the broken
  process (`/proc/<pid>/environ`). Both branches resolve the shim, so no
  `environment.d` change was needed; offered as an optional follow-up.

## Insights

- cosmic-comp ignores modifier state on the virtual-keyboard protocol that
  `wtype` uses; `ydotool`/uinput (kernel-level) is unaffected. Any tool piping
  key chords through `wtype` on COSMIC is broken the same way.
- `wtype` exits 0 even when it silently drops modifiers — callers cannot detect
  the failure. OpenWhispr's paste code has no post-paste verification, so it
  declares success. Worth reporting upstream: cosmic-comp modifier handling,
  and OpenWhispr/wtype error visibility.
- OpenWhispr writes the transcript to **both** clipboard and primary selection
  before pasting; ghostty's Shift+Insert reads primary. Its fallback chain would
  have worked — it never ran because the wtype branch "succeeded" first.
- Diagnostic technique that worked: run the exact failing command into the
  user's own focused window with marker text, one candidate per slot, and have
  the user read back what landed. Faster than debug-logging round trips.
- Same machine, two PATHs: App-menu-launched GUI apps inherit the systemd user
  session env; terminals inherit session env **plus** shell-rc additions
  (`~/.local/bin` prepend here). The AppImage did not "fail to pick up" PATH —
  it correctly inherited a different parent (cosmic → PID 1, no shell ancestry).
  Shadow binaries must be placed by reading the *target process's* environ.

## Realignments

- David asked twice for status ("any update", "do you have a solution or should
  I look at another tool set") while Larry was still tracing — pressure to
  deliver a verdict. Larry held for the decisive test rather than guess; the
  `av` result confirmed the diagnosis and made the fix tractable.

## Open threads

- [ ] Optional upstream reports: cosmic-comp virtual-keyboard modifier bug;
      wtype exit-0-on-failure; OpenWhispr paste verification on COSMIC.
- [ ] If the shim ever misbehaves (e.g. layout change away from US QWERTY — the
      keysym→keycode table is US), revisit or drop it (`rm ~/.nix-profile/bin/wtype`).
- [ ] Optional: add `~/.local/bin` to the session PATH via
      `~/.config/environment.d/` so App-menu apps see David's personal scripts
      (relogin + app restart required; harmless to the shim either way).
- [ ] Caveat recorded: if a `wtype` is ever placed in `~/.local/bin`, terminal
      launches (`.local/bin` first) and App-menu launches (`.nix-profile` first)
      would resolve different binaries.

## Next steps

- Nothing required — dictation is working. Use push-to-talk as normal.
- If OpenWhispr updates its paste logic upstream to fix this, the shim can be
  deleted.

## Cross-links

- `[[2026-09-24-13-32_larry_cosmic-hotkeys-mypka-wrapper]]` — closest prior
  COSMIC input/keysym session.
- `[[2026-08-07-10-00_larry_cosmic-cheatsheet-and-routing-lesson]]` — earlier
  COSMIC environment notes.
