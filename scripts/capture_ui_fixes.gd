extends SceneTree
func _initialize() -> void:call_deferred("run")
func shot(file: String) -> void:
	await create_timer(.25).timeout;RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://video_work/"+file+".png")
func run() -> void:
	root.size=Vector2i(540,960)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("fa");g.start_game(48);g.cancel_witch_entry();g.speech_age=2
	await shot("ui_fixes_game_fa")
	assert(g.game_ui.get_node("WitchSpeech").position.x==206)
	assert(g.hud.mascot is AtlasTexture)
	g.show_menu("rescue_home");await shot("ui_fixes_sanctuary_fa")
	g.show_menu("levels");await shot("ui_fixes_map_fa")
	g.level_map.scroll.scroll_vertical+=380;await shot("ui_fixes_map_scrolled_fa")
	g.change_language("en");g.show_menu();await create_timer(.7).timeout;await shot("ui_fixes_menu_en")
	g.free();await process_frame;quit()
