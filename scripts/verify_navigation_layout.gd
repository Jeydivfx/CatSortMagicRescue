extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	for extent in [Vector2i(540,960),Vector2i(540,1200),Vector2i(768,1024)]:
		root.size=extent;await process_frame
		for inset in [Vector2.ZERO,Vector2(52,28)]:
			g.layout_safe_override=inset;g.layout_banner_override=110;g.fit_mobile_screen()
			for locale in ["en","fa"]:
				g.change_language(locale)
				for page in ["levels","rescue_home","settings","credits","pause"]:
					g.show_menu(page);await process_frame
					var nav=g.menu_ui.get_node("NavigationBar")
					assert(nav.get_global_transform().origin.distance_to(g.hud.get_global_transform().origin)<.01,"Header differs from gameplay HUD: "+page)
					var back=nav.get_node("Back").get_global_rect()
					assert(back.size.distance_to(Vector2(58,58))<.01)
					assert(back.position.y>=inset.x+12)
					if page=="levels":assert(g.level_map.scroll.get_global_rect().position.y>back.end.y)
					if extent==Vector2i(540,1200) and inset.x>0 and locale=="en":
						RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/navigation_"+page+".png")
	g.show_menu("credits");g.navigate_back();assert(g.screen=="settings");g.navigate_back();assert(g.screen=="menu")
	g.show_menu("levels");g.navigate_back();assert(g.screen=="menu")
	g.show_menu("pause");g.navigate_back();assert(g.screen=="game")
	g.free();print("PASS 60 safe-area/page/language layouts, stable back button size, map clearance, navigation routes");quit()
