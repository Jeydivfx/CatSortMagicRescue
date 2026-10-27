extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	var unlocked: int=g.unlocked
	var coins: int=g.wallet.coins
	# First entry presents the film; retries no longer repeat the whole story.
	g.story_progress.intro_seen=false
	g.start_game(0,true)
	assert(g.level_index==0 and g.entering and is_instance_valid(g.story_scene))
	assert(g.ads.banner_hidden and g.moves==0)
	g.choose(0)
	assert(g.selected==-1 and g.moves==0)
	g.story_scene.finish_story()
	assert(not is_instance_valid(g.story_scene) and g.entering)
	await process_frame
	g.cancel_witch_entry()
	g.start_game(0,true)
	assert(not is_instance_valid(g.story_scene))
	g.cancel_witch_entry()
	# Later levels do not interrupt play with the intro, including old saves.
	g.story_progress.intro_seen=false
	g.start_game(1,true)
	assert(not is_instance_valid(g.story_scene) and not g.ads.banner_hidden)
	g.cancel_witch_entry()
	assert(g.open_map_level(0))
	assert(is_instance_valid(g.story_scene) and g.entering)
	g.show_menu()
	await process_frame
	assert(not g.ads.banner_hidden and not g.audio.suspension_reasons.has("intro_video"))
	assert(g.unlocked==unlocked and g.wallet.coins==coins)
	g.free();await process_frame
	print("PASS first-entry intro, direct level-1 retry, no film on later levels, input blocking, map entry, unchanged progress")
	quit()
