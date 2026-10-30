# Player profile avatars

Run `SUPABASE_AVATAR_MIGRATION.sql` in the existing project's Supabase SQL Editor.
It adds `players.avatar_id` and an authenticated RPC updating only the caller's
name and avatar. Existing player IDs, scores and level records remain intact.
The client saves changes locally and retries the RPC when offline or not migrated.
Rankings fall back to the old query until the migration has been applied.

The database stores a stable image identifier, rather than duplicating image
binaries per player. For a website, use the same image atlas and ID mapping:

| ID | Column | Row |
|---|---:|---:|
| orange | 0 | 0 |
| silver | 1 | 0 |
| black | 2 | 0 |
| white | 3 | 0 |
| siamese | 0 | 1 |
| clover | 1 | 1 |
| dreamer | 2 | 1 |
| calico | 3 | 1 |

Atlas: `assets/branding/player_avatars_v2.png`, four equal columns, two rows.
Unknown IDs use orange. Ranking queries return `avatar_id` beside `total_score`.

Generated with the built-in image generation tool. Prompt: eight premium cute
3D kitten bust portraits, four columns by two rows, orange/silver/black/white,
Siamese/clover/dreamer/calico, magical colored bokeh, coordinated accessories,
consistent camera and scale, no labels or frames. Full generation prompt and
reference context are in the Codex conversation.

Settings → Change name and avatar edits the existing account. Preview mode
never submits changes. Tests use a client double for mutation/retry behavior;
live Supabase schema execution requires the administrator's SQL Editor.

Active version 2 uses centered circular front-facing kitten faces, colored gradient
backgrounds, no accessories, consistent scale, transparency outside each circle.
Created with the built-in image tool from the updated ranking reference. Stable
IDs are unchanged, so saved profile choices do not require a new migration.

Ranking badges: `assets/branding/ranking_badges_v1.png`, generated using the
built-in image tool. Prompt: polished 3D gold crown with purple diamond and
scalloped gold/silver/bronze medals numbered 1/2/3 with colored ribbons, transparent
background. Explicit atlas regions in `ranking_badges.gd` prevent neighboring
icons from bleeding into one another.
