extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var metrics: Array=JSON.parse_string(FileAccess.get_file_as_string("res://cat_size_metrics.json"))
	for metric in metrics:
		var actor=preload("res://scripts/cat_actor.gd").new()
		root.add_child(actor)
		actor.setup(null,int(metric.kind),0)
		var h: float=actor.sprite.region_rect.size.y*actor.sprite.scale.y
		var w: float=actor.sprite.region_rect.size.x*actor.sprite.scale.x
		var profile: Dictionary=actor.size_profiles[str(int(metric.kind))]
		var area: float=profile.opaque_pixels*actor.sprite.scale.x*actor.sprite.scale.y
		assert(h>=74.99 and h<=84.01 and w<=82.01)
		assert(area>4450 and area<4950)
		assert(absf(actor.sprite.position.y+h*.5-40)<.01)
		actor.enable_victory_rig()
		assert(actor.victory_mesh.mesh.get_aabb().size.y<=84.01)
		actor.free()
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false)
	g.audio.set_music_enabled(false)
	g.start_game(16)
	g.moves=5
	g.curse.try_cast(g)
	assert(g.curse.pending>=0 and g.curse.warning_left>0)
	g.curse.update(1.3,g)
	assert(g.wizard.reaction=="curse")
	g.wizard._process(.34)
	assert(g.curse.left>0 and g.curse.used and g.curse.has_alternative(g,g.curse.tube))
	var before: Array=g.tubes.duplicate(true)
	var moves: int=g.moves
	var coins: int=g.wallet.coins
	var undos: int=g.undo_left
	var blocked: int=g.curse.tube
	g.choose(blocked)
	g.begin_drag(blocked,g.cat_position(blocked,0))
	assert(not g.drag_active)
	for a in range(g.tubes.size()):
		for b in range(g.tubes.size()):
			if (a==blocked or b==blocked) and g.legal(g.tubes,a,b):await g.transfer(a,b)
	assert(g.tubes==before and g.moves==moves and g.wallet.coins==coins and g.undo_left==undos)
	g.show_menu("pause")
	var remaining: float=g.curse.left
	g._process(1)
	assert(g.curse.left==remaining)
	g.resume_game()
	g.audio.set_suspended("test",true)
	g._process(1)
	assert(g.curse.left==remaining)
	g.audio.set_suspended("test",false)
	g._process(8.1)
	assert(g.curse.left==0 and not g.curse.blocked(blocked))
	g.curse.try_cast(g)
	assert(g.curse.pending==-1,"At most one curse per round")
	g.load_level(0)
	g.moves=5
	g.curse.try_cast(g)
	assert(g.curse.pending==-1,"No beginner obstacle")
	g.load_level(16)
	g.moves=5
	g.tubes=[[0,1],[1,0]]
	g.curse.try_cast(g)
	assert(g.curse.pending==-1,"Never seal without an alternative legal move")
	g.free()
	await process_frame
	print("PASS all nine silhouettes within size/area limits with anchored paws; real staff-triggered seal; blocked input has no cost; pause/ad freeze; auto expiry; once per round; no beginner or stuck-board curse")
	quit()
