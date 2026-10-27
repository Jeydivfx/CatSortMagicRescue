extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,1200)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	scene.reduced_motion = false
	scene.start_game(0)
	scene.wizard.last_activity = scene.wizard.age-10
	scene.wizard.next_laugh = scene.wizard.age+.3
	await create_timer(2.2).timeout
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	await scene.transfer(2,1)
	await create_timer(.8).timeout
	scene.audio.set_enabled(false)
	scene.free()
	quit()
