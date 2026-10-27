extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	var checked:=0
	for extent in [Vector2i(360,640),Vector2i(360,780),Vector2i(360,800),Vector2i(414,896),Vector2i(540,1200),Vector2i(768,1024),Vector2i(900,1200),Vector2i(430,932)]:
		root.size=extent
		await process_frame
		for inset in [Vector2.ZERO,Vector2(48,28)]:
			g.layout_safe_override=inset
			g.layout_banner_override=140 if inset.x>0 else 102
			g.fit_mobile_screen()
			g.change_language("fa" if inset.x>0 else "en")
			g.show_menu()
			var decor=g.menu_ui.get_node("HomeDecoration")
			var journey_bottom: float=(g.menu_ui.get_global_transform()*decor.journey_rect.end).y
			var banner_top: float=g.to_global(g.get_banner_rect().position).y
			assert(journey_bottom<banner_top-8)
			assert(g.menu_ui.get_node("HomeJourneyCount").get_global_rect().end.y<banner_top-8)
			var baseline: float=(g.menu_ui.get_global_transform()*Vector2(0,decor.book_rect.position.y+24)).y
			var cat_top:=100000.0
			for actor in g.menu_cats.get_children():
				for time in [0.0,.3,1.1,2.7]:
					actor.animate_menu(time,actor.get_meta("menu_origin"),actor.get_meta("menu_scale"),false)
					var feet: float=actor.to_global(Vector2(0,40)).y
					assert(absf(feet-baseline)<1,"Paws must stay on the book")
				var half: float=actor.sprite.region_rect.size.y*actor.sprite.scale.y*.5
				cat_top=minf(cat_top,actor.to_global(Vector2(0,actor.sprite.position.y-half)).y)
			assert(g.menu_ui.get_node("HomeLogo").get_global_rect().end.y<cat_top)
			assert(g.menu_ui.get_node("HomePlay").get_global_rect().end.y<g.menu_ui.get_node("HomeLevels").get_global_rect().position.y)
			g.start_game(41)
			g.fit_mobile_screen()
			assert(absf(g.get_banner_rect().position.y-(g.undo_button.position.y+g.undo_button.size.y)-18)<.1)
			for level in g.levels:
				g.tubes=level.tubes
				var bounds: Array[Rect2]=[]
				for i in range(g.tubes.size()):
					var r: Rect2=g.tube_rect(i)
					var s: float=g.board_scale()
					var visual:=Rect2(r.position-Vector2(8*s,9*s),r.size+Vector2(16*s,4+27*s))
					for prior in bounds:assert(not prior.intersects(visual),"Tube visuals overlap")
					bounds.append(visual)
					assert(visual.position.x>=0 and visual.end.x<=720)
					assert(visual.position.y>g.hud.get_rect().end.y)
					assert(visual.end.y<g.wizard.position.y)
				checked+=1
	g.free();await process_frame
	print("PASS ",checked," campaign layouts: eight phone/tablet ratios, notch/bottom insets, simulated larger banner; grounded cats, visible progress, footer gap and separated enlarged tubes")
	quit()

