extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.story_progress.intro_seen = true
	scene.story_progress.worlds = ["0","1","2","3","4","5"]
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.show_menu()
	var blinks := {}
	for actor in scene.menu_cats.get_children():
		assert(is_instance_valid(actor.victory_mesh) and not actor.sprite.visible)
		var origins: Vector2 = actor.get_meta("menu_origin")
		var maximum := 0.0
		var previous_scale: Vector2 = actor.scale
		for frame in range(600):
			actor.animate_menu(frame/60.0,origins,float(actor.get_meta("menu_scale")),false)
			maximum = maxf(maximum,actor.face_weights.y)
			assert(actor.scale.distance_to(previous_scale)<.1)
			previous_scale = actor.scale
		assert(maximum>.9 and actor.face_material.get_shader_parameter("idle_motion")==1.0)
		blinks[str(actor.phase)] = maximum
	assert(blinks.size()==3)
	scene.reduced_motion = false
	scene.start_game(0,true)
	assert(scene.entering and scene.hint_button.disabled and scene.tube_button.disabled)
	var before: String = str(scene.tubes)
	await scene.transfer(0,2)
	assert(scene.moves==0 and str(scene.tubes)==before)
	await create_timer(.4).timeout
	assert(scene.entering and scene.wizard.position.is_finite() and scene.wizard.scale.x>1.01)
	await create_timer(.45).timeout
	assert(scene.entering and scene.wizard.scale.x>1)
	await create_timer(1.15).timeout
	assert(not scene.entering and scene.wizard.scale==Vector2.ONE)
	assert(scene.wizard.position.distance_to(Vector2(8,scene.wizard_home_y()))<.1)
	await scene.transfer(0,2)
	assert(scene.moves==1)
	scene.start_game(0,true)
	scene.show_menu()
	await create_timer(1.5).timeout
	assert(not scene.entering and scene.screen=="menu")
	scene.reduced_motion = true
	scene.start_game(0,true)
	assert(scene.wizard.entry_flying)
	await create_timer(.35).timeout
	assert(scene.entering and scene.wizard.entry_flying and scene.wizard.modulate.a==1)
	await create_timer(.9).timeout
	assert(not scene.entering and scene.wizard.modulate.a==1)
	scene.free()
	print("PASS independent menu blinks, tail mesh, smooth breathing, foreground entry, input lock, cancellation and gentle entry")
	quit()
