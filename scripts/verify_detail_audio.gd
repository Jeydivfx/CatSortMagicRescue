extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(true);g.audio.set_music_enabled(false)
 var cues:Array=[];g.audio.cue_played.connect(func(name):cues.append(name))
 g.start_game(2);g.cancel_witch_entry();g.wizard.spells.clear();g.wizard.allow_idle=false;g.wizard.throw_magic(.85)
 await create_timer(.35).timeout;assert(not cues.has("magic_contact"))
 await create_timer(.5).timeout;assert(cues.count("magic_contact")==1)
 await create_timer(.3).timeout;assert(cues.count("magic_contact")==1)
 g.show_menu();g.clock+=2
 var actor=g.menu_cats.get_child(0);var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=g.get_canvas_transform()*actor.global_position
 g._unhandled_input(click);assert(cues.count("cat")==1)
 g._unhandled_input(click);assert(cues.count("cat")==1)
 g.start_game(2);g.cancel_witch_entry();g.best_moves["2"]=8;g.audio.set_music_enabled(true);g.show_win()
 await create_timer(.6).timeout;assert(cues.count("result_victory_jingle")==1)
 assert(g.audio.sounds.result_victory_jingle.get_length()>3.0)
 assert(g.audio.result_cheering and g.audio.result_voice.playing and g.audio.music.stream_paused)
 g.clear_win()
 assert(not g.audio.result_cheering and not g.audio.result_voice.playing)
 var before=cues.size();g.audio.set_enabled(false);g.audio.play("magic_contact");g.audio.play_soft_cat(0);g.audio.play("result_victory_jingle");assert(cues.size()==before)
 g.free();await process_frame;print("PASS exact magic arrival cue, varied click meow with debounce, 3.2s result joy, exit cleanup and mute");quit()
