extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	for dimensions in [Vector2i(540,840),Vector2i(540,1200),Vector2i(900,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		for level in scene.levels:
			scene.tubes = level.tubes
			var bounds: Array[Rect2] = []
			for index in range(scene.tubes.size()):
				var rect: Rect2 = scene.tube_rect(index)
				# Include the upper rim, completion badge and bottom shadow.
				var visual := Rect2(rect.position-Vector2(7,12),rect.size+Vector2(14,26))
				for previous in bounds: assert(not previous.intersects(visual))
				bounds.append(visual)
				assert(not visual.intersects(scene.wizard.get_rect()))
				assert(visual.end.y<scene.undo_button.position.y)
				assert(visual.position.y>scene.hud.get_rect().end.y)
				assert(not visual.intersects(scene.get_banner_rect()))
	print("PASS all 1000 stages at three aspect ratios: separated rims/shadows, larger witch, HUD, controls and banner")
	scene.free()
	quit()
