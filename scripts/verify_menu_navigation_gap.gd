extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	for extent in [Vector2i(540,840),Vector2i(540,960),Vector2i(540,1200),Vector2i(768,1024)]:
		root.size=extent;await process_frame
		for banner in [0,110]:
			g.layout_banner_override=banner;g.fit_mobile_screen();g.show_menu()
			var play=g.menu_ui.get_node("HomePlay")
			for key in ["HomeLevels","HomeGlobalRankings","HomeSanctuary"]:
				var button=g.menu_ui.get_node(key)
				print(extent," ",key," y=",button.position.y," play=",play.position.y," height=",play.size.y)
				assert(button.position.y>=play.position.y+play.size.y+5)
				var scene=preload("res://scripts/royal_home_layout.gd").background_rect(g)
				var seat_bottom:float=scene.position.y+scene.size.y*.633
				assert(absf((play.position.y-seat_bottom)-(button.position.y-play.position.y-play.size.y))<.1)
				assert(button.position.y+button.size.y<=g.content_rect().size.y/g.menu_ui.scale.y)
	g.free();print("PASS centered Play, equal clearances, separated navigation row, eight phone/tablet/banner layouts");quit()
