extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.start_game(0)
	scene.wizard.last_activity = scene.wizard.age-10
	scene.wizard.next_laugh = scene.wizard.age
	await create_timer(.05).timeout
	assert(scene.wizard.emotion==1)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	assert(not scene.won and not scene.wizard.angry)
	for actor in scene.actors: assert(actor.modulate.a>.99)
	scene.transfer(2,1)
	await create_timer(.85).timeout
	assert(scene.won and scene.wizard.angry and not is_instance_valid(scene.win_ui))
	var saved_state: String = str(scene.tubes)
	scene.undo()
	assert(str(scene.tubes)==saved_state)
	await create_timer(.8).timeout
	assert(scene.rescue_sound_played and scene.wizard.emotion==2)
	assert(not is_instance_valid(scene.win_ui))
	await create_timer(.65).timeout
	var full := Rect2(-scene.position,scene.get_viewport_rect().size)
	for actor in scene.actors:
		assert(actor.modulate.a>.99)
		assert(not full.grow(60).has_point(actor.position))
	await create_timer(.9).timeout
	assert(is_instance_valid(scene.win_ui) and not scene.audio.celebrating)
	scene.start_game(0)
	assert(not scene.wizard.angry and not scene.rescue_sound_played)
	for actor in scene.actors: assert(actor.modulate.a>.99)
	print("PASS idle laugh, no early escape, all-jars rescue, angry witch, blocked Undo, escape before results and replay reset")
	scene.free()
	quit()
