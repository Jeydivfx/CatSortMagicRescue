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
	scene.change_language("fa")
	scene.show_menu("levels")
	await create_timer(.3).timeout
	await snap("language_fa_map")
	scene.start_game(0)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	await scene.transfer(2,1)
	await create_timer(1).timeout
	await snap("language_fa_result")
	scene.change_language("ar")
	scene.start_game(0)
	scene.tubes = [[0,0],[1,0,1,0],[],[1,1]]
	scene.moves = scene.move_limit()-1
	await scene.transfer(0,2)
	await create_timer(.3).timeout
	await snap("language_ar_loss")
	scene.change_language("en")
	scene.free()
	quit()
