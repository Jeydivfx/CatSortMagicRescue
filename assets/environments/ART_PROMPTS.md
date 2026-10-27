# Environment assets

Generated with the built-in image_gen tool; no CLI/API fallback. Final raster
assets are saved alongside this file: laboratory.png, cafe.png and garden.png.
All three use an opaque portrait 9:16 composition. The runtime uses cover-crop
instead of stretching and applies a readable world-specific color overlay.

## Laboratory final prompt

Use case: stylized-concept. Create ONE finished portrait mobile puzzle-game background, 9:16 composition, full bleed, opaque. Environment 1: cozy magical cat laboratory at blue twilight. Premium hand-painted 2D casual game art, soft rounded architecture and painterly textures, warm amber lanterns, muted indigo/teal stone walls, small potion bottles and botanical plants confined to the extreme left/right edges. The central 75 percent width and middle 75 percent height is a spacious, quiet, softly shaded empty interior, low-detail deep blue gradients for excellent readability of glass tubes and bright kitten sprites overlaid later. Interesting arch/window in the upper background, subtle firefly specks only near outer edges, inviting not spooky. No horizontal shelves across the central play area, no tables blocking middle, no characters, cats, lettering, numbers, logos, user interface, buttons, tubes, border or frame. Mobile game production background asset, cohesive storybook illustration.

## Cafe final prompt

Use case: stylized-concept. Create ONE finished portrait mobile puzzle-game background, 9:16 composition, full bleed, opaque. Environment 2: cozy little cat cafe at warm late afternoon, premium hand-painted 2D casual game art, storybook painterly textures, rounded charming shapes. Distinct caramel wood and dusty rose/plum/coffee color palette. Very tall arched cafe windows at the top with sunset glow, delicate hanging plants, cups and small pastries confined to narrow far left/right margins, a coffee machine on a narrow far-side counter near edge. CENTRAL 75 PERCENT WIDTH and middle 75 PERCENT HEIGHT MUST BE QUIET EMPTY dark muted cocoa/plum wall and spacious wooden floor, no furniture across center, so bright kitten sprites and glass tubes overlaid later are easy to see. Harmonious warm lighting, no harsh busy pattern, charming cozy casual puzzle world. No animals, people, lettering, text, logos, UI, tubes, icons, buttons, borders or frame. Finished mobile game production background.

## Garden final prompt

Use case: stylized-concept. Create ONE finished portrait mobile puzzle-game background, 9:16 composition, full bleed, opaque. Environment 3: magical spring blossom garden in a peaceful blue-green evening. Premium hand-painted 2D casual game illustration, soft rounded storybook shapes, polished painterly textures. Dusty rose cherry blossom branches arc delicately from the extreme upper corners, a distant small garden arch and soft evening sky at upper quarter, tiny warm garden lanterns and lush leaves only at far left and right perimeter. CENTER 75 percent width and middle 75 percent height is quiet empty muted deep sage/teal garden air and a smooth mossy stone path, low detail and gently shaded to allow bright kitten sprites and transparent glass puzzle tubes overlaid later. A few pink petals near outer edges, soft magical glints, pleasant calm garden atmosphere. No horizontal barriers across central playfield. No cats, animals, people, lettering, text, logos, game UI, buttons, tubes, icons, border or frame. Distinct teal-and-blush-pink palette with warm cream lantern light. Finished mobile game production background.

## Runtime behavior

Auto: levels 1–100 Laboratory, 101–200 Cafe, 201–300 Garden. The three-world
sequence repeats in later hundred-level blocks until more worlds are added.
Settings > World cycles Auto, Laboratory, Cafe, Garden and saves the preference.
World changes crossfade in half a second; reduced motion disables the fade and
freezes ambient specks/petals. UI button accents follow the world palette.

## Sound change

Only four matching cats completing a tube trigger a recorded meow. A move starts
one of three original 200–236 ms spring sounds. Dragging plays the sound at pickup
and does not replay it at release. Invalid drops never meow. Menu cats still
greet visually but no longer meow on click. Jump synthesis source:
scripts/create_jump_audio.py. Validation: scripts/verify_environments_audio.gd.
