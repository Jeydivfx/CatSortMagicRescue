# Ear visibility, HUD groups, witch gestures and attached crown

The original painted ear pixels are reused through an ears-only mesh mask (top-side UV regions). Lower-ear patches render above the next kitten's paws/body while the main face remains below. Top kittens do not draw a redundant ear patch. Stationary slots use z=slot*2 and ear patches use relative z=3; drag/flight groups retain the same ordering above normal actors. Magic effects remain above the stationary stack. All nine active breeds were rendered in all_breed_ears_preview.png.

Both caption chips center the complete icon + gap + shaped-text width as one unit. This is recomputed for localized text, move count and environment. Moon, coffee cup, blossom, witch hat, crystal and cottage are native icons; movement uses two footprints. verify_attached_crown.gd checks centering in nine languages and six worlds.

The witch cycles three smoothly eased gestures (looking around, inspecting her wand, shrugging), only while idle. Active sort/curse/win/loss reactions keep priority. Motion is reduced under Gentle Motion. verify_ears_hud_gestures.gd checks distinct movement ranges, frame continuity and reaction priority. A native Godot frame strip is saved as witch_gestures_preview.png.

The results crown is now a child of the cat. Its anchor is sampled from the forehead region and includes the shader's lateral head sway. Parent scale, rotation, jump and entrance reveal therefore carry the crown without an independent bob animation. Crown tracking was checked in full/gentle motion and three captured jump phases. The results reward line was moved down five pixels to maintain clearance with the actual font height; the short/tall result-layout regression now passes.

No APK export or video generation. Player progress and the puzzle campaign were not changed.
