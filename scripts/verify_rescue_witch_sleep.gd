extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 g.unlocked=g.levels.size();g.show_menu("rescue_home");await process_frame
 var home=g.menu_ui.get_child(0);var expected:Dictionary={};var total=0
 for i in range(g.unlocked-1):
  for tube in g.levels[i].tubes:
   for kind in tube:expected[int(kind)]=int(expected.get(int(kind),0))+1;total+=1
 assert(home.residents.size()==expected.size());assert(home.rescue_counts==expected and home.rescued==total);assert(home.residents.size()>5)
 home._process(.1);g.menu_ui.modulate=Color.WHITE;RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/sanctuary_all_breeds.png")
 g.start_game(4);g.cancel_witch_entry();g.busy=false
 var w=g.wizard;w.set_process(false);w.allow_idle=true;w.reaction="";w.reaction_left=0;w.last_activity=0;w.age=20;w.next_gesture=100;w._process(.05)
 assert(w.idle_sleeping and w.frame_state=="sleep");w._process(.5);assert(w.frames.current_pose.blink>.95)
 assert(not w.snore.playing)
 g.audio.set_enabled(true);w._process(.05);assert(w.snore.playing)
 w.note_move();assert(not w.idle_sleeping and not w.snore.playing);w._process(.05);assert(w.frame_state!="sleep")
 w.age=45;w.last_activity=0;w._process(.05);assert(w.idle_sleeping)
 g.show_menu("pause");w._process(.05);assert(not w.snore.playing)
 g.audio.set_enabled(false);g.free();await process_frame;print("PASS all rescued breeds/counts, witch idle sleep/closed eyes, looped snore, input wake, pause mute");quit()
