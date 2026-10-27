# Audio reference and selected track

User reference: Panda Pop, both map/menu and in-level sound.
Specific reference video: https://youtu.be/bRFrO2VHmno
The web fetch and browser session could not play this video in this environment;
no claim is made that its audio was heard or that exact instruments, melody,
tempo or mix were measured. The notes below are our proposed direction.

## Verified game structure

Jam City's official material describes matching bubbles to rescue panda pups,
world progression, character animation and sound effects. Its help center
describes worlds containing 10 or 20 levels, collectible Panda Pals, achievements,
events and a Zen Garden. Those support a visible rescue/reward/progression loop.
This does not establish the sound design of the user's linked video.

Sources:
- https://www.jamcity.com/game/panda-pop/
- https://jamcity.helpshift.com/hc/en/11-panda-pop/section/75-how-to-play/

## Direction for Cat Sort Lab

Use a calm, light, character-led mix. One short tactile cue for each move,
clear vocal reward for completing four cats, and one restrained musical
confirmation for victory. Leave space between layers. Do not add a chime to
every cat voice and do not stack three star chimes over the completion vocal.
The current revision uses Kenney CC0 effects and the existing dry CC0 cat takes.
The user should judge the listening preview and actual phone mix before this
is treated as the final sound set.

## Final music choice

The user selected Clear Air after an earlier Ripples response. Clear Air by
Kevin MacLeod is now the runtime track, with its complete recorded arrangement,
gain normalization and Ogg conversion. Its official page lists guitar and piano,
68 BPM, and a calming/relaxed mood. We do not claim it reproduces Panda Pop's score.
Required attribution is accessible inside Settings > Audio credits.
License/source details: assets/audio/CLEAR_AIR_LICENSE.md.

Other researched alternatives, not installed as the main track:
- Cattails: https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100743
- Ripples: https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100691
- Easy Lemon: https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1200076

## Victory layout fix

Score and coin reward are now separate rows inside the enlarged card. Home is
below the card, with a gap. Underlying HUD text/buttons are hidden while the
victory panel is open and restored on next level. Scrim covers the full screen.
Verified at short and tall portrait sizes by verify_victory_layout.gd, including
non-overlap checks and restored navigation. Actual capture: victory_fixed_preview.png.
