extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,960)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en");g.show_menu()
	await create_timer(1.0).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://liveliness_menu_preview.png")
	g.start_game(42)
	await create_timer(1.0).timeout
	g.moves=6;g.curse.try_cast(g)
	await create_timer(.4).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://liveliness_game_preview.png")
	g.free();quit()
