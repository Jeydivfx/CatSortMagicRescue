extends SceneTree
func _initialize() -> void:call_deferred("run")
func shot(name: String) -> void:
	RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/"+name+".png")
func run() -> void:
	root.size=Vector2i(540,1200)
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.change_language("en")
	g.environment_override=6;g.apply_environment();g.start_game(10);g.cancel_witch_entry()
	g.tubes=[[0,0,0,0],[1,1,1,1],[2,3],[3,2],[4],[],[]];g.refresh()
	var initial_limit: int=g.move_limit()
	for i in range(6):
		g.transfer(4 if i%2==0 else 5,5 if i%2==0 else 4,1)
		await create_timer(.96).timeout
		assert(g.mischief.successful_moves==i+1)
		if i<5:assert(g.mischief.phase.is_empty())
	assert(g.mischief.phase=="cast" and g.wizard.reaction=="mischief")
	await create_timer(.55).timeout;shot("cabin_witch_cast")
	await create_timer(.55).timeout;shot("cabin_witch_swap")
	await create_timer(.30).timeout
	assert(g.mischief.smoke_points.size()==2 and is_instance_valid(g.mischief.smoke_layer))
	for i in range(g.mischief.moving.size()):
		var actor=g.mischief.moving[i]
		assert(actor.position==g.mischief.starts[i] or actor.position==g.mischief.finishes[i],"Smoke exchange must never slide through the board")
		assert(actor.modulate.a<.1,"Exchange must be hidden inside the smoke")
	shot("cabin_smoke_exchange")
	await create_timer(.50).timeout
	assert(not g.busy and g.tubes[0][3]==1 and g.tubes[1][3]==0)
	assert(g.moves==6 and g.mischief.next_due==12)
	assert(g.move_limit()==initial_limit+3)
	shot("cabin_after_swap")
	g.undo();assert(g.is_complete(g.tubes[0]) and g.is_complete(g.tubes[1]))
	assert(g.mischief.extra_moves==0 and g.mischief.successful_moves==6)
	g.mischief.successful_moves=12;g.mischief.next_due=12;g.tubes=[[0,0,0,0],[1,1,1,1],[2,3,2,3]]
	assert(not g.mischief.try_cast(g),"No empty buffer means the spell waits")
	g.wizard.frames.tension=0;g.wizard.frames.clock+=1;g.wizard.frames.sample("evil_idle",1)
	var calm: float=g.wizard.frames.current_pose.sweat
	g.wizard.frames.tension=.9;g.wizard.frames.clock+=1;g.wizard.frames.sample("evil_idle",2)
	assert(g.wizard.frames.current_pose.sweat>calm+.5)
	g.free();print("PASS every-six-valid-move cast, actual staff impact, two completed-tube top cats swapped, preserved moves, +3 recovery allowance, atomic undo, no-buffer guard, graded sweat and cabin rendering");quit()
