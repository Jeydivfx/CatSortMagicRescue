extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var budget = preload("res://scripts/move_budget.gd")
	assert(budget.limits(12)==Vector3i(12,14,16))
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	assert(scene.wallet.star_rating(12,12,false)==3)
	assert(scene.wallet.star_rating(14,12,false)==2)
	assert(scene.wallet.star_rating(16,12,false)==1)
	for index in range(100,scene.levels.size()):
		var target: int = scene.levels[index].solution_length
		assert(budget.limits(target).z>=target)
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	scene.start_game(0)
	scene.wizard.last_activity = scene.wizard.age-9
	scene.wizard.next_laugh = scene.wizard.age
	await create_timer(.08).timeout
	assert(scene.wizard.reaction=="idle" and cues.has("witch_laugh"))
	scene.load_level(0)
	scene.tubes = [[0,1,1],[1],[0,0,0],[]]
	await scene.transfer(0,1,2)
	await create_timer(.12).timeout
	assert(scene.moves==1 and scene.wizard.reaction=="surprise" and scene.wizard.surprise>.5)
	scene.load_level(0)
	scene.tubes = [[0,1],[1,0],[],[]]
	var before: String = str(scene.tubes)
	scene.choose(0)
	scene.choose(1)
	assert(scene.moves==0 and str(scene.tubes)==before and scene.wizard.reaction=="mistake")
	scene.load_level(0)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	assert(scene.wizard.reaction=="sort" and scene.wizard.near_win and not scene.busy)
	await create_timer(.4).timeout
	assert(scene.wizard.sort_impact_played and cues.has("staff_thud"))
	await create_timer(1).timeout
	assert(scene.wizard.nervous>.8)
	scene.load_level(0)
	scene.tubes = [[0,0],[1,0,1,0],[],[1,1]]
	var coins: int = scene.wallet.coins
	for move in range(scene.move_limit()):
		await scene.transfer(0 if move%2==0 else 2,2 if move%2==0 else 0)
	assert(scene.lost and not scene.won and scene.wizard.player_lost and is_instance_valid(scene.loss_ui))
	assert(scene.wallet.coins==coins)
	var moves: int = scene.moves
	await scene.transfer(2,0)
	assert(scene.moves==moves)
	scene.undo_left = 0
	scene.request_undo()
	var reward: int = scene.pending_reward
	assert(reward>=0)
	scene.ads.finish_reward(reward,scene.ads.Result.COMPLETED)
	assert(not scene.lost and not scene.wizard.player_lost and scene.moves==moves-1 and scene.undo_left==2)
	assert(not is_instance_valid(scene.loss_ui))
	scene.ads.finish_reward(reward,scene.ads.Result.COMPLETED)
	assert(scene.undo_left==2)
	scene.load_level(0)
	assert(scene.moves==0 and scene.undo_left==3)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	scene.moves = scene.move_limit()-1
	await scene.transfer(2,1)
	assert(scene.won and not scene.lost and scene.moves==scene.move_limit())
	assert(scene.wizard.defeated and scene.wizard.impact_played and is_instance_valid(scene.win_ui))
	assert(scene.level_reward.stars==1)
	scene.start_game(0)
	assert(not scene.lost and not scene.wizard.defeated and scene.wizard.reaction=="")
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS seven witch situations, move budget 12/14/16, invalid move, no loss reward, rewarded Undo, reset and exact-last-move win")
	quit()
