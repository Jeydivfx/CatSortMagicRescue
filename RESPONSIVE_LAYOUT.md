# Responsive mobile layout

Home uses one uniform content transform with explicit header, logo, cat/book anchor, action-button and journey regions. The paws share the measured painted-book contact line, so idle breathing and tall aspect ratios cannot pull kittens away from the surface. The journey card is anchored above the native banner reservation. Level subtitle has extra line separation; Play uses a native rounded pink paw icon.

Gameplay footer is anchored 18 logical pixels above the reserved ad area. Witch and speech position follow the footer. The tube grid uses the resulting free rectangle, with separate horizontal and vertical scale limits, centered partial rows and explicit 26-pixel column / 44-pixel row gutters. Glass rims and bases are included in spacing checks.

On Android the display safe area supplies top/bottom insets. AdView.get_height_in_pixels() updates the banner reservation on load through banner_geometry_changed. Fallback reservation is 102 logical pixels plus bottom safe inset. No publisher ID or ad-serving behavior changed.

Verification: verify_responsive_layout.gd checks 16,000 stage layouts (all 1000 stages, eight phone/tablet ratios, with/without simulated cutout and enlarged banner), including cat/book contact, complete journey visibility, footer gap and non-overlapping glass/base geometry. verify_ui_redesign.gd checks nine languages. Menu entry and cat-size/temporary-curse regression tests also pass. Native Android banner sizing uses the installed plugin API; this turn uses desktop previews and simulated insets, without APK export.
