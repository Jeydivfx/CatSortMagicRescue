# Ads preparation — no live SDK connected yet

Reward choice: one free Hint per level; one Extra Tube per level granted after earned rewarded-video completion. Desktop explicitly labels its three-second preview as a simulation. Cancelling, closing, unavailable ads, duplicate and stale callbacks do not grant a tube. Android with no provider reports unavailable rather than granting a free tube.

scripts/ads_manager.gd exposes request IDs and a provider hook. A future Android provider implements show_rewarded(request_id) and calls finish_reward only with the appropriate terminal result. COMPLETED must be tied to the SDK earned-reward callback, never the dismiss callback. Bind the callback to the original level/request ID.

The gameplay footer reserves Rect2(0, 1018, 720, 102) in the 720x1120 reference viewport. All interactive controls sit above this reservation. A future native anchored adaptive banner must report its actual rendered height in device units; resize this reservation and gameplay bounds to match, accounting for system insets. The current area is a layout placeholder, not an ad view.

Before Android integration: choose and verify a Godot 4 compatible Android AdMob adapter, install export templates, supply the Android App ID and separate rewarded and banner ad-unit IDs, configure consent, then test with Google's test ad units on device. No credentials or IDs have been embedded in this project.

Official references:
- https://developers.google.com/admob/android/rewarded
- https://developers.google.com/admob/android/banner
