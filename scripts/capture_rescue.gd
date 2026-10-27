extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,1200)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.reduced_motion = false
	scene.start_game(0)
	scene.wizard.last_activity = scene.wizard.age-10
	scene.wizard.next_laugh = scene.wizard.age
	await create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://witch_preview.png")
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	scene.transfer(2,1)
	await create_timer(1.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://rescue_preview.png")
	await create_timer(2).timeout
	scene.free()
	quit()
