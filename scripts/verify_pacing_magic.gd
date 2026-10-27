extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false)
	g.audio.set_music_enabled(false)
	g.start_game(0)
	assert(g.status.modulate.a==0 and g.game_ui.get_node("WitchSpeech").modulate.a==0)
	g._process(.2)
	assert(g.status.modulate.a==0)
	g._process(.35)
	assert(g.status.modulate.a>0 and g.status.modulate.a<1)
	g._process(.4)
	assert(g.status.modulate.a==1)
	g.entering=true
	g._process(.1)
	assert(g.status.modulate.a==0)
	g.entering=false
	var hard:=0
	for index in range(g.levels.size()):
		var level: Dictionary=g.levels[index]
		if level.get("difficulty","")!="hard":continue
		hard+=1
		assert(index>=10)
		g.load_level(index)
		var count:=0
		for step in level.group_solution:
			var a:=int(step[0]);var b:=int(step[1])
			assert(g.legal(g.tubes,a,b))
			assert(g.solution_lookup.has(g.ordered_key(g.tubes)))
			var n: int=mini(g.top_group_count(g.tubes,a),4-g.tubes[b].size())
			for i in range(n):g.tubes[b].append(g.tubes[a].pop_back())
			count+=1
		assert(g.solved(g.tubes) and count<=g.move_target() and count<=g.move_limit())
	assert(hard==198)
	g.start_game(0)
	await g.transfer(0,2)
	await g.transfer(1,0)
	var before: Array=g.tubes.duplicate(true)
	await create_timer(.4).timeout
	assert(not g.magic_exchange.bursts.is_empty())
	assert(g.magic_exchange.bursts.back().protected)
	await create_timer(1.0).timeout
	assert(g.tubes==before and g.moves==2)
	g.load_level(0)
	assert(g.magic_exchange.bursts.is_empty() and g.status.modulate.a==0)
	g.free()
	await process_frame
	print("PASS delayed speech fade, entry suppression, 198 grouped challenge solutions within budgets and hints, staff-triggered spell exchange without board mutation, level reset")
	quit()
