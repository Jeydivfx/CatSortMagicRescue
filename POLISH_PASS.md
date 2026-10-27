# Whole-game polish pass — 2026-10-27

Implemented:
- All campaign boards, including 11–14 tubes with the rewarded extra tube, use
  at most two rows. Beginner single-row scale is capped at 1.10 instead of 1.55.
  The first two levels use 82% helper-icon scale; button hit areas stay unchanged.
- Group selection raises the whole matching group, displays its count and marks
  legal destinations. Hovering a target previews capacity. Hit tests select the
  nearest tube in expanded touch areas; dropping back on the source cancels
  quietly. Blocked/full destinations never consume moves.
- Pacing retains 396 hard puzzles and all existing breed unlocks/IDs. Equal-roster
  puzzle swaps remove all 76 consecutive hard pairs. The following normal round
  gets two extra maximum moves; three-star goals remain certificate-based. This
  is a pacing change, not a claim of measured human difficulty or optimal routes.
- The witch telegraphs her target for 1.25 s. A successful move involving it
  counters the spell. A landed seal clears after two successful drags, with an
  eight-second safety expiry and immediate release if no alternative remains.
  Pauses, ads, reward requests, entrances and drags freeze its timer; beginners,
  completed tubes and near-victory boards remain protected.
- Rescue home is accessed through the progress card on the main menu. It derives
  rescued-cat totals, visible breeds and six room unlocks from existing progress;
  rooms open every ten completions, with distinct cushions/window/flowers/toys/
  books/lanterns and keepsake counts. It does not charge coins or reset saves.
- The story auto-plays on the first entry to level 1 only, with replay in Settings.
  Timed, runtime subtitles cover all nine interface languages, including RTL
  shaping and font fitting. No video re-encode or music/credit overlay changes.
- Twenty runtime effects are peak-matched by semantic role, repeat-limited to
  avoid stacking, and routed through a -1 dB limiter. Existing music, actual cat
  recordings, separate volume/mute settings and the authored movie mix remain.
- Rewarded ads have load/show watchdogs, clear unavailable/cancelled messages,
  stale callback protection and no reward unless the earned callback confirms it.
- Local aggregate playtest counters support later tuning without a new analytics
  SDK, network endpoint or player identifiers. Test runs disable persistence.
- Eye-shader texture work is restricted to the visible face/eye regions and
  active expressions. Neutral bodies avoid redundant expression/eyelid samples.

Validation completed: all 1,000 single-move solution certificates, 396 grouped
hard routes, 16,000 campaign layouts across eight ratios and safe-area/banner
variants, the main gameplay regression, new integration tests, existing curse,
intro, audio/economy and animation checks, and native Godot UI/RTL screenshots.

Remaining external validation: physical Android performance, battery use, actual
AdMob network/presentation behaviour and observed sessions with five new players.
See `PLAYTEST_AND_DEVICE_CHECK.md`. No APK was built. No release was submitted.
