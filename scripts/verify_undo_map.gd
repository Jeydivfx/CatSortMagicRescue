extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		quit(1)
		assert(value)

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.start_game(0)
	for step in range(4):
		scene.history.append([[0],[1],[],[]])
	scene.moves = 4
	for step in range(3): scene.request_undo()
	check(scene.undo_left==0 and scene.history.size()==1,"Three free undos only")
	scene.undo()
	check(scene.history.size()==1,"Direct undo cannot bypass budget")
	scene.request_undo()
	var id: int = scene.pending_reward
	check(id>=0,"Exhausted undo requests reward")
	scene.ads.finish_reward(id,scene.ads.Result.CANCELLED)
	check(scene.undo_left==0 and scene.history.size()==1,"Cancelled ad grants nothing")
	scene.request_undo()
	id = scene.pending_reward
	scene.ads.finish_reward(id,scene.ads.Result.COMPLETED)
	check(scene.undo_left==2 and scene.history.is_empty(),"Reward grants three and immediately uses one")
	scene.ads.finish_reward(id,scene.ads.Result.COMPLETED)
	check(scene.undo_left==2,"Duplicate callback grants nothing")
	scene.load_level(0)
	check(scene.undo_left==3,"New attempt resets budget")
	scene.unlocked = 18
	scene.show_menu("levels")
	await process_frame
	await process_frame
	var map = scene.level_map
	check(map.buttons.size()<20 and map.buttons.has(17),"Map virtualizes and focuses current level")
	check(not scene.open_map_level(18) and scene.screen=="levels","Locked level rejected")
	map.scroll.scroll_vertical = 0
	await process_frame
	check(map.buttons.has(999) and map.buttons[999].disabled,"Future final level locked")
	map.unlocked_count = 1000
	map.focus_current()
	await process_frame
	check(map.buttons.has(999),"Final level can be focused")
	print("PASS three free undos, reward, cancellation, duplicates, reset and virtualized locked map")
	scene.audio.set_enabled(false)
	await create_timer(0.25).timeout
	quit()
