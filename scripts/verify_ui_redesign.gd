extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false)
	g.audio.set_music_enabled(false)
	for dimensions in [Vector2i(540,840),Vector2i(540,1000),Vector2i(540,1200)]:
		root.size=dimensions
		await process_frame
		g.fit_mobile_screen()
		for locale in g.L.CODES:
			g.change_language(locale)
			g.show_menu()
			await process_frame
			for key in ["HomeLogo","HomePlay","HomeLevels","HomeSettings"]:
				var item=g.menu_ui.get_node(key)
				var r: Rect2=item.get_global_rect()
				assert(r.position.x>=0 and r.end.x<=g.get_viewport_rect().size.x+1,locale+key+str(r))
				assert(r.position.y>=0 and r.end.y<=g.get_viewport_rect().size.y+1,locale+key+str(r))
			assert(not g.menu_ui.has_node("StoryReplayButton"))
			var play=g.menu_ui.get_node("HomePlay")
			assert(play.symbol=="paw" and not play.subtitle.is_empty())
			assert(g.menu_cats.get_child_count()==3)
		g.show_menu("levels")
		await process_frame
		var map=g.level_map
		for index in map.buttons:
			assert(map.buttons[index].disabled==(int(index)>=g.unlocked))
		g.start_game(999)
		g.fit_mobile_screen()
		for control in g.hud.get_children():
			if control.get("symbol")=="pause":
				assert(control.icon_center().distance_to(control.size*.5)<.01)
		assert(g.hud.get_global_rect().end.y<g.to_global(g.tube_rect(0).position).y)
		for button in [g.undo_button,g.hint_button,g.tube_button]:
			assert(button.get_global_rect().size.y>=72 and not button.symbol.is_empty())
		assert(g.get_banner_rect().position.y>g.tube_button.position.y+g.tube_button.size.y)
	g.free()
	await process_frame
	print("PASS nine languages, three phone ratios, visible menu logo/buttons, locked map, crowded-board HUD clearance, footer targets and banner reservation")
	quit()
