extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_music_enabled(false)
	scene.audio.set_enabled(true)
	scene.start_game(0)
	var cues: Array[String] = []
	scene.hud.star_reached.connect(func(index: int): cues.append("hud_star_%d" % index))
	var hud = scene.hud
	hud.reset_progress(0,3)
	hud.update_progress(1.0/3,3,1,3,12)
	await create_timer(.25).timeout
	assert(hud.earned==1 and cues==["hud_star_1"])
	hud.update_progress(2.0/3,3,2,3,12)
	await create_timer(.3).timeout
	assert(hud.earned==2 and cues==["hud_star_1","hud_star_2"])
	hud.update_progress(1.0/3,3,1,3,12)
	assert(hud.earned==1)
	hud.update_progress(2.0/3,3,2,3,12)
	await create_timer(.3).timeout
	assert(cues.size()==2,"Undo must not farm milestone sounds")
	hud.update_progress(1,3,3,3,12)
	await create_timer(.3).timeout
	assert(hud.earned==3 and cues.back()=="hud_star_3")
	hud.update_progress(1,2,3,3,12)
	assert(hud.earned==2 and scene.wallet.star_rating(5,12,true)==2)
	hud.reset_progress(0,3)
	assert(hud.highest_earned==0 and hud.pending.is_empty())
	# Directly from zero to three must emit three ordered, staggered milestones.
	cues.clear()
	hud.update_progress(1,3,3,3,12)
	await create_timer(.85).timeout
	assert(cues==["hud_star_1","hud_star_2","hud_star_3"])
	for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		var bounds: Rect2 = hud.get_global_rect()
		assert(bounds.position.y>=0)
		assert(bounds.end.y < scene.to_global(scene.tube_rect(0).position).y)
		var items: Array = [scene.level_label,scene.coin_label,scene.move_label,scene.progress_label]
		for i in range(items.size()):
			for j in range(i+1,items.size()):
				assert(not items[i].get_global_rect().intersects(items[j].get_global_rect()))
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	await process_frame
	print("PASS HUD layout, ordered star cues, rating cap, level reset and no duplicate rewards after Undo")
	quit()
