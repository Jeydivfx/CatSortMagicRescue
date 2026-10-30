# Royal home menu reference redesign

Generated with the built-in image generation tool; existing files retained.

Active assets:

- `assets/environments/menu_royal_terrace_v1.png`
- `assets/branding/menu_navigation_cards_v1.png`

Background prompt: edit the user's portrait home-menu reference into a clean
background plate; remove logo, text, counters, buttons and cats; preserve the
moonlit blue castle valley, waterfalls, bridge, flowering stone arch, warm
lanterns and red rug. Bake an empty red velvet cushion, gold piping, tassels,
blue jewel and contact shadow into the scene at center x .5 and seat y .588.
Leave the lower terrace open for runtime navigation.

Card prompt: three equal rounded-square premium 3D navigation cards with
champagne-gold beveled borders and blank dark caption pills. Navy blue with
parchment map/compass, royal purple with gold paw trophy, deep teal with a
purple-roof rescue cottage and glowing heart window. No rendered words.

Runtime labels support all existing languages. The original three kitten
actors retain their animations. `royal_home_layout.gd` uses one background
transform to anchor their paw baseline to the baked cushion. There is no
separate cushion sprite. Native controls provide Play, its level subtitle,
Settings and selectable cards. The compact header uses the existing generated
gold star/paw coin assets. Its plus button reveals coin-earning information.

Validation: EN/FA native captures and navigation; four viewport ratios;
eight phone/tablet/banner cases; kitten paw anchors, non-overlapping controls,
safe footer bounds. Campaign, scoring, advertisements and saved progress are
not changed by this visual redesign.
