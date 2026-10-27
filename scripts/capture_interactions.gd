extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func snap(path: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://"+path+"_preview.png")

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
	await create_timer(.7).timeout
	await snap("witch_laugh_new")
	scene.load_level(0)
	scene.tubes = [[0,1,1],[1],[0,0,0],[]]
	await scene.transfer(0,1,2)
	await create_timer(.25).timeout
	await snap("witch_surprise")
	scene.load_level(0)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	await create_timer(1.4).timeout
	await snap("witch_nervous")
	scene.load_level(0)
	scene.tubes = [[0,0],[1,0,1,0],[],[1,1]]
	for move in range(scene.move_limit()):
		await scene.transfer(0 if move%2==0 else 2,2 if move%2==0 else 0)
	await create_timer(.7).timeout
	await snap("move_limit_loss")
	scene.free()
	quit()
