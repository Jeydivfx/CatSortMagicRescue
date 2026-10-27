extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var heights: Array=[]
	for kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:
		var actor=preload("res://scripts/cat_actor.gd").new();root.add_child(actor)
		actor.setup(null,kind,0)
		var h: float=actor.sprite.region_rect.size.y*actor.sprite.scale.y
		heights.append(h)
		actor.set_stack_count(4)
		for frame in range(30):actor.animate(frame*.05,false)
		assert(actor.stack_weight>.99 and is_instance_valid(actor.victory_mesh))
		# Upper paws end at y=-17 relative to the lower kitten's origin.
		# The upper edge of the lower eye region is at least six pixels below.
		var eyes: float=40-h+h*.29+10
		assert(eyes-(-17)>=6)
		assert(250-(44+3*57)+40-h+10>=0)
		actor.free()
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.start_game(0)
	for frame in range(30):g._process(.05)
	for actor in g.actors:
		assert(actor.z_index==int(actor.get_meta("slot"))*2)
		assert(actor.stack_weight>.99)
	var before: Array=g.tubes.duplicate(true)
	var moves: int=g.moves
	var coins: int=g.wallet.coins
	g.provoke_witch()
	assert(g.message==g.witch_reply and not g.witch_reply.is_empty())
	assert(g.wizard.laugh_left>0 and not g.wizard.spells.is_empty())
	var cooldown: float=g.witch_tap_until
	g.provoke_witch()
	assert(g.witch_tap_until==cooldown)
	assert(g.tubes==before and g.moves==moves and g.wallet.coins==coins)
	g.selected=0
	g._process(.05)
	assert(g.wizard.gaze_target.y<0 and g.wizard.gaze_target.x>0)
	g.selected=-1
	await g.transfer(0,2)
	await g.transfer(1,0)
	g.update_actors()
	for actor in g.actors:assert(actor.z_index==int(actor.get_meta("slot"))*2)
	g.free();await process_frame
	print("PASS nine breeds: visible eyes, four-cat fit, anchored compact rigs and slot layering after moves; witch gaze, touch reaction, cooldown and unchanged board/economy")
	quit()
