extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	for gentle in [false,true]:
		var panel=preload("res://scripts/victory_screen.gd").new();root.add_child(panel)
		panel.setup(load("res://assets/cats_expressions.png"),12,11,false,gentle)
		panel.set_process(false);panel.hero_reveal=1
		var positions: Array=[]
		for t in [.9,1.05,1.2,1.5,1.7,3.8,4.0]:
			panel.age=t;panel._process(0)
			assert(panel.crown.get_parent()==panel.cat)
			var anchor: Vector2=panel.cat.victory_head_anchor(t,gentle)
			assert(panel.crown.position.distance_to(anchor)<.001)
			assert(panel.crown.global_position.distance_to(panel.cat.to_global(anchor))<.001)
			assert(absf(panel.crown.global_rotation-panel.cat.global_rotation)<.001)
			var top: float=40-panel.cat.sprite.region_rect.size.y*panel.cat.sprite.scale.y
			assert(anchor.y>top+6 and anchor.y<top+22)
			positions.append(panel.crown.global_position.y)
		assert(positions.max()-positions.min()>(1 if gentle else 10))
		panel.free()
	var game=load("res://main.tscn").instantiate();root.add_child(game)
	game.persistence_enabled=false;game.audio.set_enabled(false);game.audio.set_music_enabled(false)
	game.start_game(0)
	for locale in game.L.CODES:
		game.change_language(locale)
		for world in range(6):
			game.environment_override=world;game.apply_environment();game.refresh()
			var world_left: float=game.hud.world_icon_x-12
			var world_right: float=game.progress_label.position.x+game.progress_label.size.x
			assert(absf((world_left+world_right)*.5-357)<.1)
			var move_left: float=game.hud.moves_icon_x-12
			var move_right: float=game.move_label.position.x+game.move_label.size.x
			assert(absf((move_left+move_right)*.5-602)<.1)
	game.free();await process_frame
	print("PASS crown parent/head anchor, jump/rotation/stretch tracking in both motion modes; centered icon-and-text groups across nine languages and six worlds")
	quit()
