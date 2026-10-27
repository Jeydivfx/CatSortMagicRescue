extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	for kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:
		var cat=preload("res://scripts/cat_actor.gd").new();root.add_child(cat)
		cat.setup(null,kind,float(kind)*.73)
		cat.set_stack_count(4,true)
		var last_blink: float=cat.blink_amount(0)
		var max_flick:=0.0
		for frame in range(1200):
			var t:=frame/120.0
			var blink: float=cat.blink_amount(t)
			assert(absf(blink-last_blink)<.22,"Blink must have a continuous close/open envelope")
			last_blink=blink
			max_flick=maxf(max_flick,absf(cat.ear_flick(t)))
			cat.animate(t,false)
			assert(cat.ear_material.get_shader_parameter("head_tilt")==cat.face_material.get_shader_parameter("head_tilt"))
		assert(max_flick>.5)
		cat.free()
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	assert(g.ordered_key([[1,1,0],[]])!=g.ordered_key([[11,0],[]]),"Multi-digit breed IDs must never collide in hint lookup")
	var hard: int=30
	while g.levels[hard].get("difficulty","")!="hard":hard+=1
	g.start_game(hard);g.moves=6
	g.curse.try_cast(g);assert(g.curse.pending>=0)
	g.curse.update(1.3,g)
	assert(g.curse.impact(g));assert(g.curse.casts==1)
	g.curse.update(8.1,g);g.curse.try_cast(g);assert(g.curse.pending==-1)
	g.moves+=7;g.curse.try_cast(g);assert(g.curse.pending>=0)
	g.curse.update(1.3,g)
	assert(g.curse.impact(g));assert(g.curse.casts==2)
	g.curse.update(8.1,g);g.moves+=7;g.curse.try_cast(g);assert(g.curse.pending==-1)
	g.load_level(hard);assert(g.curse.casts==0)
	g.free();await process_frame
	print("PASS nine breeds: continuous blink, ear flick and synchronized ear/head motion; two separated hard-round curses, maximum two, reset on new round")
	quit()
