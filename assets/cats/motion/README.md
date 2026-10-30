# Shared cat motion — 9 active breeds

Active IDs: 0 Ginger Tabby, 1 Silver Tabby, 2 Calico, 3 Tuxedo, 4 Bombay,
5 White Persian, 6 Siamese, 10 Ragdoll, 11 Russian Blue.
Sphynx, Scottish Fold and Bengal remain excluded.

Eight individual transparent jumping illustrations were created with the built-in
imagegen tool. Each uses its own original neutral character crop as reference,
not a recolored orange kitten. The approved orange jumping illustration is reused.
Files: air_1.png, air_2.png, air_3.png, air_4.png, air_5.png, air_6.png,
air_10.png and air_11.png in this directory.

Prompt set: exact referenced breed/individual, preserve frontal face, original fur
rendering, juvenile proportions, markings, eye color and ears; airborne body with
both forepaws bent at chest, hind legs lifted/tucked, one curved tail on viewer right,
open delighted eyes, tiny smile. Transparent alpha, generous margin, full silhouette,
no ground, shadows, text, props, extra paws, extra tails or redesign.
Breed-specific constraints: silver gray stripes/amber eyes; orange-gray-white calico;
black-white tuxedo blaze and bib; solid charcoal Bombay/amber eyes; fluffy white
Persian/blue eyes; cream/brown-point Siamese/blue eyes; fluffy Ragdoll white blaze/blue
eyes; gray Russian Blue/green eyes.

Runtime: scripts/cat_pose_motion.gd + cat_motion_catalog.gd + cat_face.gdshader.
Per-breed registration: assets/cats/motion_profiles.json. Head width at eye level
matches the original reference; the averaged eye center is anchored through the swap.
No new skeleton or frame sheet. Sleep uses the same original body/alpha throughout,
with 12–16 seconds staggered idle delay, 2.6-second curved eye closure/head settle,
slow breathing/ear/tail motion, rising/fading Zs, immediate input response and eased wake.
Sleep works on the main menu, idle top cats in tubes and sanctuary residents.
Gentle-motion settings are respected. Air poses are used for tap, drag and group moves.
The head, cheeks, ears, body and alpha remain fixed during smiling; only a registered
mouth region and clean procedural eyelids change. Closed-pose lash bands are removed
continuously before drawing the moving lid, avoiding detached dark specks.

Calibration scripts: calibrate_breed_motion.py and calibrate_air_art.py.
Reference extraction: extract_breed_references.gd. Recalibrate faces first, then air art.
Native review: video_work/all_breed_faces.png, all_breed_jump_review.png,
and all_breed_motion_preview.mp4. Showcase motions are synchronized for comparison;
normal gameplay phases differ per kitten.

Pre-expansion backup:
C:/Users/javad/Downloads/CatSortMagicRescue_AllBreedBackup_20261028
Original atlas artwork and save data are unchanged. No APK/AAB or GitHub push.

Silver eyelid cleanup: silver_clean_lids.png was created with the built-in imagegen
tool using the actual silver tabby reference. Prompt: preserve exact cat body, width,
stripes, pink nose/ears, paws and one tail; replace open eyes with seamlessly continuous
matching fur and thin curved closed lids; no circular eye sockets, pale rings or shadows,
transparent background. Only its face paint is registered as a continuous underlay;
the original silhouette/body/alpha and original muzzle remain anchored. Silver lid
calibration lives in silver_lid_profile.json and is retained on calibration rebuilds.
Current Silver rendering uses silver_face_fur.png, a dedicated technical fur plate,
not the earlier painted closed-eye portrait. Built-in imagegen edit prompt: preserve
the exact Silver Tabby, framing, gray/white fur, stripes, pink ears/nose, muzzle,
paws, body and single tail; remove ONLY closed-eyelid ink from both eyes and fill
those areas with continuous matching fur; no eyeballs, pupils, lashes, eye sockets,
circles or shadows; preserve transparent alpha. Mode: transparent reference edit.
The plate is sampled only inside moving eyelid patches; it never replaces the
whole neutral face, forehead or eyebrows. Silver's aperture is fitted to the
original eye bounds (.085, .082) so its moving rim starts on the eye rather than
forming a second brow above it. One continuous curved aperture handles the whole
closure, without a final-frame renderer switch or runtime fur inpainting.
Blink and smile closure weights add rather than compete,
preventing an unintended reopen between two closed-eye expressions.
Actual menu regression: capture_main_menu_eye_motion.gd exercises the real click
handler on all three menu cats, followed by staggered sleep. Latest recording:
video_work/main_menu_eye_review.mp4. All nine breeds also pass body/root/scale,
sleep continuity, air silhouette and grouped transfer checks.
verify_silver_neutral_render.gd additionally compares the rendered neutral frame
pixel-for-pixel with the original-only rendering and verifies that four blink
stages leave the original forehead/eyebrow pixels unchanged.

Eye-corner regression: Silver cleanup coverage is wider horizontally than its
moving aperture. The original antialiased outer eyeliner must be fully covered,
not left at the feather boundary as two faint dots. Aperture and brow guard stay
unchanged. The render test replaces the base portrait with diagnostic magenta and
checks all four outer corners during sleep and smile; identical corner pixels
prove no residual original eye ink contributes there.
