extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	await create_timer(.65).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://"+name+".png")
func run() -> void:
	root.size=Vector2i(540,1000)
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false)
	g.audio.set_music_enabled(false)
	g.environment_override=0
	for locale in ["en","fa"]:
		g.change_language(locale)
		g.show_menu()
		await capture("redesign_home_"+locale)
		g.start_game(41)
		await capture("redesign_game_"+locale)
	g.show_menu("levels")
	await capture("redesign_map_fa")
	g.free()
	quit()
