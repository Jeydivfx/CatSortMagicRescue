# Cat Sort: Magic Rescue

A portrait Godot puzzle game: bring four matching kittens together to break the witch's spell and rescue them.

## Open and play

Use **Godot 4.7.2 stable** (standard edition). Clone this repository, import `project.godot`, let Godot import the assets, then press F5. No Git LFS or external asset download is required to play the desktop project.

The project includes 1,000 solvable levels, nine languages (including Persian and Arabic), animated cats and witch, the edited story video and its separate soundtrack, coins, hints, limited undo, a rescue sanctuary, and an AdMob integration. Test ads are enabled in `assets/admob_config.json`.

## Android setup

Install the Godot 4.7.2 Android export templates, a compatible JDK and Android SDK, then set their paths in Godot's Editor Settings. Reinstall the Android build template using Project > Install Android Build Template if the downloaded Godot libraries are missing. The Gradle source configuration is included; downloaded engine AAR libraries, generated assets, build outputs and local credentials are excluded.

Configure your own release signing outside version control. Never commit keystores, passwords or API keys. No APK or AAB is included.

## Checks

Run from the repository root with your Godot console executable:

```text
godot --headless --path . --script scripts/verify.gd
godot --headless --path . --script scripts/verify_polish_pass.gd
godot --headless --path . --script scripts/verify_responsive_layout.gd
```

The game saves progress under Godot's user data directory, outside the repository. Existing Windows players retain the legacy `Cat Sort Lab` save directory. Tests disable progress writes.

## Repository size and production originals

Only source code, required runtime assets, licenses and small development documentation belong in this repository. `.godot`, Android build outputs, logs, preview renders, editing workspaces and store artwork are excluded. The final story video and soundtrack are included as normal Git files; the largest runtime file is about 29 MiB.

Original shots, audio editing work, previews and store artwork from this machine were preserved separately in the sibling folder `CatSortMagicRescue_ProductionArchive_20261027`. They are not required to run the game. To edit the film again, restore its source clips to `Cat sort video intro/` and working materials to `video_work/`, or use the sibling originals supported by `scripts/build_video_intro.py`.

Keep that production archive backed up separately. It is not uploaded with the game repository.

## Credits and rights

See `assets/audio/CREDITS.md`, `assets/audio/REAL_MEOW_CREDITS.md`, and `assets/video/MUSIC_LICENSE.md` for audio attribution and licenses. Third-party plugin licenses remain with their source. No blanket open-source license is granted for original game code or artwork by this repository.
