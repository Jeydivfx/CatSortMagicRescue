extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	var wallet_before: int=g.wallet.coins
	var unlocked_before: int=g.unlocked
	for index in [0,1]:
		g.start_game(index)
		assert(g.board_scale()<=1.101 and g.undo_button.symbol_scale==.82)
		assert(g.undo_button.size.y>=80)
	g.start_game(127)
	assert(g.tubes.size()==11 and g.board_columns()==6)
	assert(ceili(float(g.tubes.size())/g.board_columns())==2)
	g.tubes.append([]);assert(g.board_columns()==6)
	g.start_game(999);assert(g.tubes.size()==13 and g.board_columns()==7)
	g.tubes.append([]);assert(g.tubes.size()==14 and g.board_columns()==7)
	for code in g.L.CODES:
		g.change_language(code);g.show_menu("rescue_home")
		var home=g.menu_ui.get_child(0)
		assert(home.completed==maxi(g.unlocked-1,g.wallet.records.size()))
		assert(home.residents.size()<=5)
		assert(home.milestone_bar.max_value==10)
		await process_frame
		for node in home.content.get_children():
			if node is Button:assert(node.position.x>=0 and node.position.x+node.size.x<=680)
		var cues: Array=JSON.parse_string(FileAccess.get_file_as_string("res://assets/video/subtitles.json"))
		for cue in cues:assert(not g.L.t(cue.text).is_empty())
	g.change_language("en")
	g.start_game(16);g.moves=6;g.curse.try_cast(g)
	assert(g.curse.pending>=0 and not g.curse.launched)
	var aim: int=g.curse.pending
	var pair: Array=[]
	for a in range(g.tubes.size()):
		for b in range(g.tubes.size()):
			if (a==aim or b==aim) and g.legal(g.tubes,a,b):pair=[a,b];break
		if not pair.is_empty():break
	assert(not pair.is_empty())
	await g.transfer(pair[0],pair[1],g.top_group_count(g.tubes,pair[0]))
	assert(g.curse.pending==-1 and g.curse.left==0 and g.curse.casts==1)
	g.load_level(16);g.moves=6;g.curse.try_cast(g);g.curse.update(1.3,g)
	assert(g.curse.impact(g) and g.curse.turns_left==2)
	g.curse.on_move(g,-1,-1);assert(g.curse.turns_left==1)
	g.curse.on_move(g,-1,-1);assert(g.curse.left==0)
	var ads=preload("res://scripts/ads_manager.gd").new();root.add_child(ads)
	var id: int=ads.begin_reward();ads._process(15.1)
	assert(ads.pending_id==-1 and ads.last_result==ads.Result.UNAVAILABLE)
	ads.finish_reward(id,ads.Result.COMPLETED);assert(ads.last_result==ads.Result.UNAVAILABLE)
	id=ads.begin_reward();ads.mark_presented(id);ads._process(120)
	assert(ads.pending_id==id);ads.finish_reward(id,ads.Result.CANCELLED)
	ads.free()
	assert(g.wallet.coins==wallet_before and g.unlocked==unlocked_before)
	g.start_game(0);g.best_moves["0"]=3
	g.level_reward={"score":250,"stars":3,"coins":30,"keepsake":true}
	g.show_win()
	assert(g.win_ui.home_button.text==g.L.t("New keepsake!"))
	g.win_ui.home_pressed.emit();assert(g.screen=="rescue_home")
	await process_frame
	g.free();await process_frame
	if not Engine.has_singleton("PoingGodotAdMob"):
		for plugin in [MobileAds._plugin,AdView._plugin,AdSize._plugin,RewardedAd._plugin]:
			if plugin is Node and is_instance_valid(plugin) and not plugin.is_inside_tree():plugin.free()
		MobileAds._plugin=null;AdView._plugin=null;AdSize._plugin=null;RewardedAd._plugin=null
	print("PASS small beginner board/icons, 11–14 tubes in two rows, nine-language rescue home/subtitles, counterable spell/two-move release, reward timeout/late-event protection, unchanged progress")
	quit()
