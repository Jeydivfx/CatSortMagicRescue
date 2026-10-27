extends SceneTree
func _initialize() -> void:call_deferred("run")
func capture(file: String) -> void:
	await process_frame;RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/"+file+".png")
func run() -> void:
	root.size=Vector2i(540,960)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.change_language("en")
	g.start_game(0);g.choose(0)
	await create_timer(.35).timeout;await capture("polish_beginner")
	g.start_game(999);g.choose(0)
	await create_timer(.35).timeout;await capture("polish_crowded")
	g.show_menu("rescue_home")
	await create_timer(.35).timeout;await capture("polish_rescue_home")
	g.start_game(16);g.moves=6;g.curse.try_cast(g)
	await create_timer(.15).timeout;await capture("polish_witch_warning")
	g.show_menu();g.change_language("fa")
	g.play_story(-1,true)
	g.story_scene.subtitles=[{"start":0.0,"end":100.0,"text":"Bring four matching kittens together. Their chorus breaks the spell!"}]
	await create_timer(.15).timeout;await capture("polish_subtitles_fa")
	g.cancel_story();g.change_language("en")
	g.show_menu();g.free();await process_frame;quit()
