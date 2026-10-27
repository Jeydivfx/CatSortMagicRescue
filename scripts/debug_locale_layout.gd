extends SceneTree
func _initialize() -> void: call_deferred("run_test")
func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.change_language("fa")
	scene.show_menu("settings")
	await create_timer(.2).timeout
	print("MENU ROOT ",scene.menu_ui.position," ",scene.menu_ui.size," direction ",scene.menu_ui.layout_direction)
	for child in scene.menu_ui.get_children():
		if child is Button or child is HSlider: print(child.text if child is Button else "SLIDER"," pos ",child.position," size ",child.size," dir ",child.layout_direction," rtl ",child.is_layout_rtl())
	print("GAME ROOT ",scene.game_ui.position," ",scene.game_ui.size," HUD ",scene.hud.position," Undo ",scene.undo_button.position)
	quit()
