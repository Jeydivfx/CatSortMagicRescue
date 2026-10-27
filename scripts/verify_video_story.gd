extends SceneTree
var completed:=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,960)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en")
	var unlocked: int=g.unlocked
	var coins: int=g.wallet.coins
	g.play_story(-1,true)
	var film=g.story_scene
	assert(film.player.stream is VideoStreamTheora and g.ads.banner_hidden)
	assert(g.audio.suspension_reasons.has("intro_video"))
	await create_timer(.8).timeout
	g.audio.set_suspended("verify_focus",true)
	await create_timer(.1).timeout
	var at: float=film.player.stream_position
	await create_timer(.3).timeout
	assert(absf(film.player.stream_position-at)<.05 and film.score.stream_paused)
	g.audio.set_suspended("verify_focus",false)
	await create_timer(.1).timeout
	assert(film.player.volume_db==-80 and film.score.volume_db==-80)
	assert(absf(film.player.size.x/film.player.size.y-9.0/16)<.001)
	assert(film.clip_contents)
	assert(film.player.position.x<=.01 and film.player.position.y<=.01)
	assert(film.player.position.x+film.player.size.x>=film.size.x-.01)
	assert(film.player.position.y+film.player.size.y>=film.size.y-.01)
	for extent in [Vector2i(540,840),Vector2i(540,960),Vector2i(720,1600),Vector2i(1080,2340)]:
		root.size=extent
		await process_frame
		film.layout_video()
		assert(absf(film.player.size.x/film.player.size.y-9.0/16)<.001)
		assert(film.player.position.x<=.01 and film.player.position.y<=.01)
		assert(film.player.position.x+film.player.size.x>=film.size.x-.01)
		assert(film.player.position.y+film.player.size.y>=film.size.y-.01)
	root.size=Vector2i(540,840)
	await process_frame
	film.layout_video()
	if DisplayServer.get_name()!="headless":
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://video_work/intro_in_game.png")
	film.finished.connect(func():completed=true)
	var deadline:=Time.get_ticks_msec()+55000
	while not completed and Time.get_ticks_msec()<deadline:
		# Automated window resizing/tool focus must not pause the natural-EOF check.
		# Suspension itself is exercised explicitly above.
		g.audio.set_suspended("focus",false)
		await process_frame
	assert(completed,"Film must reach its natural end")
	await process_frame
	assert(not is_instance_valid(g.story_scene))
	assert(not g.ads.banner_hidden and not g.audio.suspension_reasons.has("intro_video"))
	assert(g.unlocked==unlocked and g.wallet.coins==coins)
	g.play_story(-1,true)
	await create_timer(.2).timeout
	g.story_scene.finish_story()
	await process_frame
	assert(not is_instance_valid(g.story_scene) and not g.ads.banner_hidden)
	g.play_story(-1,true)
	g.show_menu()
	await process_frame
	assert(not g.audio.suspension_reasons.has("intro_video") and not g.ads.banner_hidden)
	g.story_progress.intro_seen=false
	g.start_game(0,true)
	assert(is_instance_valid(g.story_scene) and g.entering)
	g.story_scene.finish_story()
	await process_frame
	assert(g.story_progress.intro_seen and not is_instance_valid(g.story_scene))
	g.cancel_witch_entry();g.show_menu()
	assert(g.unlocked==unlocked and g.wallet.coins==coins)
	g.free();await process_frame
	print("PASS full Theora playback and natural EOF; focus pause, independent mute, portrait fit, skip, menu cancellation, audio/banner restore, unchanged progress")
	quit()
