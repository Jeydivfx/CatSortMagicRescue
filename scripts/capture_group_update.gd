extends SceneTree

func _initialize() -> void:
	call_deferred("demo")

func shot(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func demo() -> void:
	root.gui_disable_input = true
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.set_process_unhandled_input(false)
	scene.reduced_motion = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(true)
	scene.start_game(0)
	scene.tubes = [[0,1,1],[1,1],[0,0,0],[],[]]
	scene.update_actors()
	await create_timer(0.4).timeout
	var start: Vector2 = scene.cat_position(0,1)
	var finish: Vector2 = scene.cat_position(1,2)
	scene.begin_drag(0,start)
	var motion: Tween = scene.create_tween()
	motion.tween_method(func(t: float):
		scene.drag_anchor = start.lerp(finish,t)+Vector2(0,-sin(t*PI)*30)
		scene.drag_pointer = scene.drag_anchor,0.0,1.0,1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await motion.finished
	scene.finish_drag(1)
	await scene.flight_tween.finished
	await create_timer(0.25).timeout
	await scene.transfer(0,2)
	await create_timer(2.2).timeout
	await shot("res://win_preview.png")
	await create_timer(2.4).timeout
	scene.show_menu()
	scene.level_page = 99
	scene.show_menu("levels")
	await shot("res://campaign_1000_preview.png")
	scene.start_game(999)
	await create_timer(0.25).timeout
	await shot("res://level_1000_preview.png")
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
