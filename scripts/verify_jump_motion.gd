extends SceneTree
const M=preload("res://scripts/cat_jump_motion.gd")
func _initialize() -> void:call_deferred("run")
func run() -> void:
	for gentle in [false,true]:
		for direction in [-1.0,0.0,1.0]:
			for i in range(121):
				var p=M.air_pose(i/120.0,direction,gentle)
				assert(p.scale.x>.95 and p.scale.y<=1.066)
				assert(absf(p.angle)<.1)
		assert(M.landing(0,gentle)==0 and M.landing(.38,gentle)==0)
	var a:=Vector2(100,450);var b:=Vector2(400,600)
	assert(M.arc(a,b,180,0)==a and M.arc(a,b,180,1)==b)
	root.size=Vector2i(540,1200)
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.start_game(4);g.cancel_witch_entry();g.tubes=[[0,0],[0],[1,1,1,1],[]];g.refresh()
	g.transfer(0,1,2)
	await create_timer(.45).timeout
	assert(g.busy and g.flight_cats.size()==2)
	RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/jump_motion_air.png")
	await create_timer(.8).timeout
	assert(not g.busy and g.tubes[0].is_empty() and g.tubes[1].size()==3 and g.moves==1)
	assert(g.landing_count==2)
	g.transfer(1,3,3,true)
	await create_timer(.6).timeout
	assert(not g.busy and g.tubes[1].is_empty() and g.tubes[3].size()==3 and g.moves==2)
	g.free();print("PASS bounded continuous jump poses, exact endpoints, two-cat tap flight, three-cat drag landing, move counts");quit()
