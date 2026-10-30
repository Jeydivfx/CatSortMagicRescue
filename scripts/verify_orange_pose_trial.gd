extends SceneTree
func _initialize() -> void:call_deferred("run")
func shot(path: String) -> void:
	RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/"+path+".png")
func run() -> void:
	root.size=Vector2i(540,1200)
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.change_language("en")
	g.clock=20;g.cat_last_activity=20;g.show_menu();await create_timer(.6).timeout
	shot("orange_pose_awake")
	g.cat_last_activity=g.clock-13;await create_timer(.15).timeout;shot("orange_pose_drowsy")
	g.cat_last_activity=g.clock-17;await create_timer(.6).timeout;shot("orange_pose_sleep")
	var orange=g.menu_cats.get_child(0)
	assert(orange.orange_pose.visible and orange.orange_pose.sleeping)
	assert(orange.victory_mesh.visible and not orange.sprite.visible,"Sleep keeps original body visible; no pose cut")
	assert(orange.orange_pose.z_strength>.9,"ZZZ appears only after eyes finish closing")
	assert(is_instance_valid(g.menu_cats.get_child(1).orange_pose),"Silver shares the approved motion controller")
	var touch:=InputEventScreenTouch.new();touch.pressed=true;touch.position=Vector2.ZERO;g._input(touch)
	await create_timer(.1).timeout
	assert(orange.orange_pose.z_strength==0 and orange.victory_mesh.visible,"Touch removes ZZZ immediately and still wakes without blocking input")
	g.start_game(4);g.cancel_witch_entry();g.tubes=[[0,0],[0],[1,1,1,1],[]];g.refresh()
	g.transfer(0,1,2);await create_timer(.5).timeout
	shot("orange_pose_jump")
	var flying:=0
	for actor in g.actors:
		if actor.kind==0 and int(actor.get_meta("tube"))<0:
			assert(actor.orange_pose.visible and actor.orange_pose.current=="air")
			assert(not actor.victory_mesh.visible and not actor.sprite.visible)
			flying+=1
	assert(flying==2)
	await create_timer(.8).timeout
	assert(g.tubes[1].size()==3 and not g.busy)
	for actor in g.actors:
		if actor.kind==0:assert(not actor.orange_pose.visible)
	g.free();print("PASS orange sleep onset, one silhouette, instant touch wake, shared silver-cat behavior, group air poses and landing restore");quit()
