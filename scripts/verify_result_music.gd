extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var b=load("res://scripts/sound_bank.gd").new();root.add_child(b);b.set_music_enabled(true)
 b.play("result_victory_jingle");assert(b.result_cheering and b.music.stream_paused and b.result_voice.playing)
 b.play("hud_star_1");assert(b.music.stream_paused)
 await create_timer(.3).timeout
 b.set_suspended("focus",true);assert(b.result_voice.stream_paused and b.music.stream_paused)
 await create_timer(.2).timeout
 b.set_suspended("focus",false);assert(not b.result_voice.stream_paused and b.music.stream_paused)
 await create_timer(3.3).timeout;assert(not b.result_cheering and not b.music.stream_paused)
 await create_timer(.7).timeout;assert(absf(b.music.volume_db-b.music_base_db())<.1)
 b.play("result_victory_jingle");b.stop_cue("result_victory_jingle");assert(not b.result_cheering and not b.result_voice.playing and not b.music.stream_paused)
 b.set_enabled(false);b.play("result_victory_jingle");assert(not b.result_cheering)
 b.free();await process_frame;print("PASS result joy exclusively pauses music, survives focus suspension, resumes on real completion with fade, cleans up and respects mute");quit()
