# Challenge pacing v1

The campaign retains 1000 stages and its existing nine kitten designs. The first ten stages are unchanged. Two deterministically chosen slots in each subsequent block of ten now use mixed, full starting tubes plus two empty tubes: 198 challenges and 802 unchanged normal stages. Hard stages have a purple map marker and a localized label in the HUD.

build_challenge_levels.py uses a bounded weighted heuristic search under the actual top-group transfer rule. Every accepted layout has both a grouped solution and an expanded single-cat certificate. Stored grouped goals allow roughly ten percent extra moves over the found route for three stars; normal move-limit and star logic still applies. These routes prove solvability within the budget, not global optimality or measured human difficulty. Human playtesting should guide the next tuning pass.

Original campaign and goal files are backed up in audio_work/campaign_before_challenge_v1.json and goals_before_challenge_v1.json. Player progress, settings, coins and records are not reset. Re-running the generator is deterministic. Validation: verify_challenge_campaign.py, verify_pacing_magic.gd, and the existing 1000-stage runtime verification.

Speech starts transparent, waits for the witch entrance/tutorial to finish, then fades in over 0.6 seconds after a short pause. A completed tube triggers her staff strike, a purple ground splash and flying spell; a gold shield around the kittens repels it. These effects are short and do not block input or alter tube contents. Alternate idle taunts include a staff strike. Reduced motion tones down particle travel; sound follows the effects volume/mute controls.
