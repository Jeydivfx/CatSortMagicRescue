# Development and validation

Godot 4.7.2, GL Compatibility. Open `project.godot` and run `main.tscn`.
Android publishing uses the existing export preset; keep signing credentials outside Git.

## Campaign and scores

- 1,000 existing levels, 20 chapters of 50. `chapter_catalog.gd` owns chapter/environment scheduling.
- Six existing environment images recur across chapters. Manual theme overrides remain available.
- Scoring version 2: 20/30/40 base points, +5 hard, +5 unassisted under-target solution; maximum 50.
- Only improvements to per-level best scores increase the total.
- Three free undos per round; thereafter one completed rewarded video grants one undo.

## Supabase

The client uses the public app configuration. Never commit service-role keys, player sessions or signing keys.
Apply `SUPABASE_AVATAR_MIGRATION.sql` and `SUPABASE_SCORE_V2.sql` to the intended database when deploying these features. Local presence of a migration does not mean it has run on the server.
`SUPABASE_RUN_THIS.sql` is the older ranking setup retained for compatibility; review it before applying to an existing installation.

## Checks

Run with the Godot console binary:

```
godot --path . --script scripts/verify_chapters.gd
```

Current regression checks:

- `verify_polish_pass.gd`: gameplay, localization, spells, reward lifecycle.
- `verify_chapters.gd`: 20 chapters, all stage indexes, locks, parallax bounds and chapter card layout.
- `verify_compact_scoring.gd`, `verify_score_v2_client.gd`: scores/migration and isolated HTTP protocol checks.
- `verify_paid_undo.gd`: three free undos and rewarded recovery; historical filename retained.
- `verify_result_music.gd`, `verify_detail_audio.gd`: exclusive result jingle, music restoration and effect timing.
- `verify_royal_home.gd`, `verify_settings_redesign.gd`, `verify_sanctuary_redesign.gd`, `verify_rankings_redesign.gd`: responsive EN/FA UI.
- `verify_witch_v2.gd`: stable character poses and animation timing.

Older focused checks are retained as development references; some assert historical layouts. Use the list above for the current regression suite.
UI checks generate screenshots under `video_work/`, which is ignored by Git. Checks disable gameplay persistence; HTTP-double tests avoid live writes. Main-scene initialization can still contact the configured leaderboard.

## Assets and repository hygiene

Keep Godot `.import` and `.uid` metadata alongside source assets. `.godot/` is regenerated locally.
Build outputs, source-film editing work, previews, credentials and local backups are ignored.
Reusable composition/generation tools remain in `scripts/`; one-time code rewriting and obsolete screenshot capture scripts were removed.
Asset licenses and credits remain alongside their source folders. Original result fanfare is reproducible with `scripts/create_result_jingle.py` (NumPy required).
