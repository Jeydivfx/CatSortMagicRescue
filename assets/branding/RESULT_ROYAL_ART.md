# Royal result screen assets

`result_royal_assets_v1.png` was generated with the built-in image tool.
Prompt: three separate premium fantasy game assets on transparency: a low oval
royal purple tufted velvet cushion with gold piping and two tassels; a glossy
rounded beveled golden reward star; a gold coin embossed with a kitten paw.
No text, no characters, each object fully contained in its own atlas area.

Explicit source rectangles in `scripts/victory_screen.gd` trim atlas padding.
The original live silver kitten and animation remain active. The crown uses
the existing ranking crown image and is parented to the kitten with the head
anchor updated each frame. Numeric results and rewards still come from game
state; changing the layout does not change the economy or star thresholds.
