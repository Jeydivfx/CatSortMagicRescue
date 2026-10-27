# Android AdMob test setup

Account IDs supplied by the project owner are stored in
`assets/admob_config.json`. `test_mode` defaults to true; ads_manager.get_ad_unit
selects Google's demo units until explicitly switched to production. The owner's
App ID is `ca-app-pub-8683775581688444~2374561987`, banner is
`ca-app-pub-8683775581688444/2182990299`, and rewarded is
`ca-app-pub-8683775581688444/3227856538`. These are production account IDs, not
Google demo IDs. For this project configure the plugin with the owner's App ID;
keep demo ad unit selection enabled during development.

Current state (October 24): Poing AdMob 5.1.0 and the official Godot 4.7.2
Android AARs are installed. Gradle build and Internet permission are enabled.
The Android provider initializes MobileAds, requests a fixed bottom test banner,
preloads rewarded video, grants an extra tube only from earned reward, and
handles dismissal, failure and retry. Desktop still uses the preview.
The vendor headless binary installer is locally patched to skip disabled iOS.
Google demo units remain enabled. Actual ad delivery requires an Android device
with network access; local builds and unit tests do not prove ad delivery.

1. In Godot AssetLib install **AdMob by Poing Studios**, compatible with Godot
   4.5+. Enable it under Project > Project Settings > Plugins.
2. Install its Android native dependency using Project > Tools > AdMob Manager
   > Android > Download & Install (if automatic installation did not complete).
3. Project > Install Android Build Template. In the Android export preset enable
   **Use Gradle Build**. Keep Internet permission enabled.
4. Project Settings > Admob > General: enable Android and use Google's test
   App ID: `ca-app-pub-3940256099942544~3347511713`.
5. Initialize MobileAds once. Create a bottom banner using the plugin's AdView
   API and load the banner test unit below. For an extra tube, preload a rewarded
   ad, present it after the user selects the tube button, then forward ONLY the
   SDK earned-reward callback to ads_manager.finish_reward(id, COMPLETED).
   Dismissal without reward, load failure, or show failure must finish the request
   as CANCELLED/UNAVAILABLE. Guard against duplicate callbacks and level changes.
6. Export a fresh debug APK and deploy to the Android phone. A Google test banner
   must visibly identify itself as a test ad. Desktop preview is not proof that
   the Android SDK works.

Google Android demo ad units:
- Fixed banner: `ca-app-pub-3940256099942544/6300978111`
- Anchored adaptive banner: `ca-app-pub-3940256099942544/9214589741`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

For an adaptive banner reserve its reported height in the UI. The existing
102-unit bottom reservation is intended for a standard banner; do not let an
ad overlap gameplay controls. Replace test IDs only when preparing production.

Primary documentation:
- https://poingstudios.github.io/godot-admob-plugin/
- https://developers.google.com/admob/android/test-ads
- https://codelabs.developers.google.com/codelabs/admob-ads-in-flutter

UI update: the project now expands its canvas to the screen aspect ratio, centers
the board without stretching cats, fills the background, anchors the reserved
banner at the physical bottom, and requests fullscreen on Android. Android's
immersive export option was already enabled. Montserrat Bold 700 is bundled with OFL.
