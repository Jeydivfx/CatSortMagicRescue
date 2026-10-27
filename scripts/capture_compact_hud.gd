extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,840)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_suspended("focus",false)
	scene.audio.set_levels(.45,.85)
	scene.audio.set_enabled(true)
	scene.reduced_motion = false
	scene.start_game(2)
	scene.tubes = [[0,0,0],[0],[1,1,1],[1],[2,2,2],[2]]
	scene.hud.reset_progress(0,3)
	scene.refresh()
	await create_timer(.7).timeout
	await scene.transfer(1,0)
	await create_timer(.9).timeout
	await scene.transfer(3,2)
	await create_timer(.23).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://compact_hud_preview.png")
	await create_timer(.7).timeout
	await scene.transfer(5,4)
	await create_timer(.8).timeout
	scene.audio.set_music_enabled(false)
	scene.audio.set_enabled(false)
	await create_timer(.2).timeout
	scene.free()
	quit()
