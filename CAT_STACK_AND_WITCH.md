# Readable kitten stacks and witch presence

Tube groups use the existing kitten artwork with a compact seated torso on a native subdivided mesh. compact_stack shifts the face rigidly by 10 logical pixels while compressing only the torso below UV y=.52; the paw baseline stays fixed. Four cats retain the existing 57-pixel pitch and now sit four pixels inside the tube bottom. Every active breed retains its calibrated proportions. Eyes remain below the overlapping upper paws; no head artwork is scaled independently or cropped.

Stationary draw order follows the slot index, so upper paws stay in front of lower ears even after transfers reorder actor objects. Dragged and flying groups also sort by relative slot. Group completion bounce uses a shared phase to avoid transient eye occlusion. Cats ease back to their full seated shape during escape; menu and result hero cats retain their original full pose.

The witch smoothly watches selected/dragged kittens. A transparent touch target stays within her existing reserved area, clear of the board and footer. Tapping triggers a short laugh/spell and localized taunt, or a startled reply near victory. A five-second cooldown prevents repeated audio; touching her does not change cats, moves or coins. Staff strikes, temporary tube seals and existing win/loss reactions remain connected to gameplay.

Validation: verify_cat_stack.gd checks all nine breeds' eye clearance, four-cat fit, mesh activation and draw ordering after moves, plus witch gaze/touch/cooldown with no economy mutation. Existing size/curse and cinematic tests are run as regressions. Preview fixtures use a temporary in-memory board and never write player progress.
