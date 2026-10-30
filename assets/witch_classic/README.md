# Classic witch appearance on the current animation rig

The artwork is rendered from the original game's vector drawing paths:
purple angular hat/robe, green collar, gold diamond, white bob hair and mint orb.
`build_classic_witch_art.gd` creates the fixed twelve-part atlas and metadata.
No new AI character design is used.

`witch_model_classic.gd` keeps the current articulated skeleton, smooth pose
transitions and gameplay event timing. It adjusts the hand/grip position to the
old character's proportions. There is exactly one staff during held/drop poses.

Idle breathes and blinks, with quiet gaps between gestures. Supported reactions
include staff inspection, taunt, evil laugh, mock, anger/staff strike, shock,
spell, nervous/panic, defeat, crying with falling tears and broom entry.

The root and global character scale stay fixed. Face and hat follow the neck;
the hat has a small counter-rotation. Crying keeps the dropped staff on the floor.
