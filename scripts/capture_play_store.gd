extends SceneTree
const OUT="res://store_assets/"
func _initialize() -> void:call_deferred("run")
func save_game(g,name: String) -> void:
	g.hint_pair.clear()
	g.selected=-1
	await create_timer(.65).timeout
	await RenderingServer.frame_post_draw
	var shot:=root.get_texture().get_image()
	var h:=roundi(g.to_global(g.get_banner_rect().position).y/g.get_viewport_rect().size.y*shot.get_height())
	shot=shot.get_region(Rect2i(0,0,shot.get_width(),h))
	shot.convert(Image.FORMAT_RGB8)
	shot.save_png(OUT+"raw/"+name+".png")
func run() -> void:
	root.size=Vector2i(1080,1920)
	await process_frame
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en");g.wallet.coins=660
	g.environment_override=0;g.start_game(19)
	g.game_ui.get_node("BannerReservation").hide()
	await save_game(g,"01_match_four")
	g.environment_override=4;g.start_game(16)
	g.game_ui.get_node("BannerReservation").hide()
	for step in range(12):
		var key: String=g.ordered_key(g.tubes)
		if not g.solution_lookup.has(key):break
		var pair: Array=g.solution_lookup[key]
		await g.transfer(pair[0],pair[1])
		if g.curse.pending>=0:await create_timer(.38).timeout
		if g.curse.left>0:break
	assert(g.curse.left>0,"Capture must show a real gameplay-triggered curse")
	g.wizard.begin_gesture(1)
	await save_game(g,"02_witch")
	g.environment_override=2;g.start_game(75)
	g.game_ui.get_node("BannerReservation").hide()
	await save_game(g,"03_kittens")
	g.environment_override=0;g.start_game(0)
	await g.transfer(0,2);await g.transfer(1,0);await g.transfer(2,1)
	await create_timer(1.3).timeout
	await save_game(g,"04_rescue")
	g.free();await process_frame
	print("PASS four actual gameplay/result captures, English, no player-save writes, no advertisement content")
	quit()
