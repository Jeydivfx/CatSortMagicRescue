extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.start_game(16)
	var tubes: Array=g.tubes.duplicate(true)
	var coins: int=g.wallet.coins
	var music: bool=g.music_enabled
	var effects: bool=g.sound_enabled
	for code in g.L.CODES:
		g.change_language(code);g.show_menu("pause")
		g.menu_ui.get_node("PauseMusic").pressed.emit()
		assert(g.music_enabled!=music and g.sound_enabled==effects and g.screen=="pause")
		g.menu_ui.get_node("PauseEffects").pressed.emit()
		assert(g.sound_enabled!=effects and g.music_enabled!=music)
		g.menu_ui.get_node("PauseMusic").pressed.emit()
		g.menu_ui.get_node("PauseEffects").pressed.emit()
		assert(g.music_enabled==music and g.sound_enabled==effects)
		g.resume_game();assert(g.screen=="game" and g.tubes==tubes and g.wallet.coins==coins)
	g.free();await process_frame
	print("PASS independent pause music/effects switches in nine languages, resume preserves board and coins")
	quit()
