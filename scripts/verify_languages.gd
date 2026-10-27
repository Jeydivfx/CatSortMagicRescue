extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var L = preload("res://scripts/localization.gd")
	L.initialize()
	assert(L.CODES.size()==9 and L.strings.size()>=100)
	for key in L.strings:
		for code in L.CODES:
			assert(L.strings[key].has(code) and not str(L.strings[key][code]).is_empty())
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	for code in L.CODES:
		scene.undo_left = 3
		scene.change_language(code)
		var restored: Dictionary = JSON.parse_string(JSON.stringify(scene.progress_snapshot()))
		assert(restored.language==code)
		scene.show_menu("settings")
		var selector = scene.menu_ui.get_node("LanguageSelector")
		assert(selector.item_count==9 and selector.selected==L.CODES.find(code))
		assert(L.t("Level 41")==L.strings["Level %d"][code]%41)
		assert(scene.status.text==L.t(scene.message))
		assert(scene.undo_button.text.contains("3"))
		if L.rtl():
			assert(scene.status.text_direction==Control.TEXT_DIRECTION_RTL)
			assert(scene.status.get_theme_font("font").has_char(0x06CC))
		var controls: Array = []
		for child in scene.menu_ui.get_children():
			if child is Button or child is HSlider:
				assert(child.position.x>=0 and child.get_rect().end.x<=720)
				for other in controls: assert(not child.get_rect().intersects(other))
				controls.append(child.get_rect())
		scene.start_game(0)
		assert(scene.hud.get_rect().position.x>=0 and scene.undo_button.position.x==48)
		scene.undo_left = 0
		scene.refresh()
		assert(not scene.undo_button.get_rect().intersects(scene.hint_button.get_rect()))
		assert(scene.undo_button.size.x==192)
	scene.show_menu("settings")
	scene.menu_ui.get_node("LanguageSelector").item_selected.emit(8)
	assert(scene.language=="fa" and scene.menu_ui.get_node("LanguageSelector").selected==8)
	scene.change_language("en")
	assert(scene.status.get_theme_font("font").get_font_name().contains("Montserrat"))
	L.set_locale("invalid")
	assert(L.locale=="en")
	scene.free()
	print("PASS nine complete catalogues, dynamic values, live selector, saved locale field, Arabic/Persian glyphs and RTL, layout and English fallback")
	quit()
