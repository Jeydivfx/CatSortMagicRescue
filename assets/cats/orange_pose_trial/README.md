# Orange kitten pose trial — 2026-10-28

Scope: Ginger Tabby (kind 0) only. Other breeds and the witch retain their existing artwork and animation.

New authored PNG cutouts:
- air.png — bent front paws, lifted hind legs, open happy eyes, one right-hand tail.
- yawn.png — yawning, one paw near chin, seated base.
- sleep.png — closed relaxed eyes, seated base.

Built-in imagegen was used with assets/cats_expressions.png as character reference.
Prompt set: preserve the first-column orange kitten exactly (fluffy painted 2.5D style,
frontal camera, original stripes, white bib/muzzle/paw tips, pink nose/ears,
one striped tail on viewer right), transparent alpha, no ground/text/props.
State prompts: airborne with bent paws; seated polite yawn; seated doze with lowered head.
Full prompts were supplied in this task's imagegen tool calls.

Runtime: scripts/orange_pose_trial.gd and orange_sleep_motion.gdshader.
No frame sheet, new skeleton, 3D model or opacity crossfade. Sleep uses spatial
shader motion for chest breathing, rigid head nod, independent ears and one tail.
Authored eyelids replace the old distorted orange eyelid samples. Air pose bypasses
happy/blink blending. Atlas silhouette is hidden whenever a new whole-body pose shows.

Timing: onset 12–16 seconds without touch/key/wheel input (staggered by phase),
2.2-second yawn, then doze. First input wakes immediately and still performs its action.
Only the top cat of a tube dozes; a selected, flying, entering or celebrating cat does not.
Menu orange can doze too. Gentle-motion preference reduces shader motion.

Alignment: seated paw plane y=40. Opaque bounds from alpha>1 are used to ignore
near-transparent border pixels. Air aligns head/eye center rather than tucked feet.
Group airborne spacing expands smoothly and contracts before landing.
Native 2.8x review: original 231 px occupied height, sleeping 228 px; paw planes differ
by 1 px from soft fur edges, with no movement at the sleeping paw baseline.

Rollback is available without a game UI toggle. Pre-trial source copies are kept at:
C:/Users/javad/Downloads/CatSortMagicRescue_OrangePoseBackup_20261028
Includes main.gd, cat_actor.gd, cat_jump_motion.gd and cat_face.gdshader.
Restore only this trial's edits if unrelated future edits have happened; do not replace
whole files blindly. New art is separate and original atlas PNGs are unchanged.

No APK/AAB was built, and no GitHub push was made.

## Smooth sleep / coherent smile correction
Sleep no longer replaces the whole character with yawn/sleep PNGs. The original body
and UV registration remain active throughout a 2.6-second eased eyelid/head transition.
This removes the body/size jump at sleep onset. The source yawn/sleep artwork remains
available for reference; sleep.png supplies only the aligned eyelid paint at runtime.
Smiling orange cats now sample one complete happy painted pose; the happy mouth is
not collaged with lids from a second pose. Other breeds retain their existing path.
Three animated Z/z glyphs appear only after full closure, rise/fade slowly, and disappear
on first input. Waking eyelids ease open over about 0.35 seconds without delaying input.

## Eyelid cleanup
Orange eye regions now use a continuous curved aperture with one analytic moving lid.
The baked lash is removed as one complete curved band (quadratic fits per eye),
including antialiased edges; per-pixel brightness thresholds had left isolated specks.
The original neutral silhouette stays active during click smiles; only the registered
mouth area changes, preserving head/body width and eliminating a ghost second face.
Native regression: both sleeping and happy eyes each have exactly one connected dark
lid in the measured eye regions, with no isolated dark components. Body and ear pixels
outside the face region match the neutral rendering exactly at a fixed pose.
