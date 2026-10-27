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
	scene.change_language("fa")
	var sheet := Image.create(1620,1200,false,Image.FORMAT_RGB8)
	for i in range(3):
		scene.environment_override = i+3
		scene.start_game(40)
		await create_timer(.6).timeout
		await RenderingServer.frame_post_draw
		var shot := root.get_texture().get_image()
		shot.convert(Image.FORMAT_RGB8)
		sheet.blit_rect(shot,Rect2i(0,0,540,1200),Vector2i(i*540,0))
	sheet.save_png("res://new_worlds_preview.png")
	scene.free()
	quit()
