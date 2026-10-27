extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	for dimensions in [Vector2i(720,1120), Vector2i(720,1600), Vector2i(900,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		var full := Rect2(-scene.position, scene.get_viewport_rect().size)
		assert(full.has_point(Vector2(360,560)))
		assert(is_equal_approx(scene.get_banner_rect().end.y+scene.position.y, scene.get_viewport_rect().size.y))
		scene.start_game(0)
		var local: Vector2 = scene.cat_position(0,0)
		var viewport_point: Vector2 = scene.get_global_transform_with_canvas()*local
		assert((scene.get_global_transform_with_canvas().affine_inverse()*viewport_point).distance_to(local)<0.01)
		assert(scene.status.get_theme_font("font").get_font_name().contains("Montserrat"))
	print("PASS full-screen layout, bottom banner, input coordinates and Montserrat Bold theme")
	scene.free()
	quit()
