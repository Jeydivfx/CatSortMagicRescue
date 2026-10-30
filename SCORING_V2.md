# Compact scoring (version 2)

| Component | Points |
|---|---:|
| One star | 20 |
| Two stars | 30 |
| Three stars | 40 |
| Hard level bonus | +5 |
| Fewer moves than the target, without assistance | +5 |

Maximum: 50 per level. Level number no longer increases points. Existing
move-budget star thresholds and the assisted two-star ceiling remain intact.
Only an improvement over that level's best score increases the total. Repeating
an equal/worse result grants neither ranking points nor repeat coins. Coin
prices, first-clear rewards and the small improvement reward are unchanged.

On restoring an older save, each recorded level is converted from its saved
stars and campaign difficulty. An efficiency bonus cannot be reconstructed
without historical move data, so players may earn it through a better replay.
The original score remains in `legacy_score`, and its aggregate is retained in
`legacy_total_score`. Conversion is idempotent. Coins, unlocked levels, story
and identities are not reset. New save snapshots include `score_version: 2`.

Run `SUPABASE_SCORE_V2.sql` in the existing Supabase project's SQL Editor.
It creates a separate v2 best-score table and `players.total_score_v2` without
deleting the old scoring history. The authenticated RPC serializes each player's
updates, accepts 20–50 and adds only best-score deltas. It cannot update another
player. The game requeues converted local records after profile connection.
Old-version pending submissions are discarded and rebuilt from those records.

The new leaderboard reads only v2 scores, so old high numbers cannot dominate
the compact scale. Existing players appear with their new total after opening
the updated game and syncing. Until SQL is applied, submissions remain queued
and rankings show a server-setup message rather than mixing the two scales.

Validation: bounded scores over combinations of level, moves, difficulty and
assistance; first/repeat awards; legacy conversion and repeated restore; client
RPC/query behavior tested with an isolated HTTP double. Live SQL execution has
not been performed by Codex.
