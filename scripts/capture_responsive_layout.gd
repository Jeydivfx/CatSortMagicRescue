extends SceneTree
func _initialize() -> void:call_deferred("run")
func capture(file: String) -> void:
	await create_timer(.65).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://"+file+".png")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en")
	for extent in [Vector2i(360,780),Vector2i(540,840),Vector2i(768,1024)]:
		root.size=extent
		await process_frame
		g.fit_mobile_screen()
		g.show_menu()
		await capture("responsive_home_%d"%extent.x)
		g.start_game(41)
		g.fit_mobile_screen()
		await capture("responsive_game_%d"%extent.x)
	g.free();quit()
