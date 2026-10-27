# Mobile, rewards and progression

- Poing AdMob plugin 5.1.0 installed, including Android native libraries for 4.7.2.
- Native banner and rewarded video provider; test ad units retained, owner App ID
  included in Android manifest. SDK rewards, dismissals and failures are handled.
- Gradle Android build template installed; Internet permission fixed.
- Tall screens spread game controls and tube rows. Cats scale up without changing
  their aspect ratio. One-row introductory levels have larger tubes and cats.
- Starts with 100 coins. Hints cost 25 coins, increasing 5 per hundred levels up to
  70 at level 1000. Failed searches and an already visible hint cost nothing.
- First completion earns 20–45 coins based on stars and progression. Repeating
  the same result earns nothing; improving a record earns 5 coins once per record
  improvement. Total score tracks best scores instead of replay farming.
- Three stars require meeting the move goal without hints or extra tubes. Goals
  tighten after level 20 and again after 200; all levels remain completable even
  when exceeding the goal. No energy system or forced loss timer.
- Tube completion sparkles; victory shows score, actual stars and earned coins.
- Wallet, scores and records persist with existing progress/settings.

Validation: verify.gd (1000 levels), verify_drag_input.gd, verify_mobile_layout.gd,
verify_economy.gd. Android test APK builds with native SDK. No physical device
was connected during the build, so real ad display still needs device testing.
