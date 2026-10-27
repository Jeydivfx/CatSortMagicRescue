extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,960)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	for code in ["en","fa"]:
		g.change_language(code);g.show_menu("rescue_home")
		await create_timer(.4).timeout
		for n in g.menu_ui.get_child(0).content.get_children():
			if n is Button or n is Panel or n is ProgressBar:print(n.get_class(), " ", n.position," ",n.size," ",n.visible," ",n.modulate)
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://video_work/sanctuary_"+code+".png")
	g.free();await process_frame;quit()
