extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,1200)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_music_enabled(false)
	scene.audio.set_enabled(false)
	var sheet := Image.create(1080,800,false,Image.FORMAT_RGB8)
	for index in range(3):
		scene.environment_override = index
		scene.start_game(24)
		await create_timer(0.8).timeout
		await RenderingServer.frame_post_draw
		var screenshot := root.get_texture().get_image()
		screenshot.save_png("res://environment_%d_preview.png" % index)
		screenshot.resize(360,800,Image.INTERPOLATE_LANCZOS)
		screenshot.convert(Image.FORMAT_RGB8)
		sheet.blit_rect(screenshot,Rect2i(0,0,360,800),Vector2i(index*360,0))
	sheet.save_png("res://environments_preview.png")
	scene.free()
	quit()
