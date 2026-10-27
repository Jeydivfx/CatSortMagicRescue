# Menu ears and blink

At the user's request, the side-cat head-turn feature has been removed, including
the yaw/pitch mesh deformation and menu head tilt. Instead, the side kittens'
ears rotate slightly and independently around fixed bases, using short smooth
pulses at different intervals/phases. Gentle motion reduces movement to 25%.
Existing breathing, tail motion and the centre kitten's idle behaviour remain.
The menu-only ear pose is reset in ordinary gameplay animation.

Blinking uses moving upper/lower occlusion masks over an opaque neutral eyeball,
rather than cross-dissolving eye images. The closed lid samples the original
painted closed-eye frame at unchanged UV coordinates: forehead stripes are
never stretched over the lid. Each breed has measured eye centres. Fast close,
soft reopening, staggered rhythms and occasional double blinks are retained.

Validation: `verify_menu_ears.gd`, `verify_liveliness_v2.gd`; native Godot renders
via `capture_menu_ears.gd` and `capture_eyelids.gd`. Saves, story media, audio and
export settings are unchanged. No APK built.
