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
	scene.start_game(24)
	await create_timer(.7).timeout
	scene.tubes = [[],[2,2],[3,3,3,3],[1,1,1,1],[0,0,0,0],[2,2]]
	scene.moves = 5
	scene.refresh()
	await create_timer(.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://star_hud_preview.png")
	scene.free()
	quit()
