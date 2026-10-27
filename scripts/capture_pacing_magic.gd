extends SceneTree
func _initialize() -> void: call_deferred("run")
func shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://"+file+".png")
func run() -> void:
	root.size=Vector2i(540,1000)
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false)
	g.audio.set_music_enabled(false)
	g.environment_override=0
	g.change_language("fa")
	g.start_game(15)
	g.set_process(false)
	g.update_actors()
	await process_frame
	await shot("challenge_stage_preview")
	assert(g.status.modulate.a==0)
	g.update_speech(1.0)
	await shot("challenge_speech_preview")
	g.start_game(0)
	g.update_speech(1.0)
	g.tubes=[[0,0,0,0],[1,1,1],[1]]
	g.update_actors()
	g.refresh()
	g.reaction_tube=0
	g.wizard.react_to_sort()
	g.on_witch_staff_impact()
	g.magic_exchange.set_process(false)
	g.magic_exchange.bursts[0].age=.46
	g.magic_exchange.queue_redraw()
	await shot("witch_magic_flight_preview")
	g.magic_exchange.bursts[0].age=1.03
	g.magic_exchange.queue_redraw()
	await shot("witch_magic_shield_preview")
	g.free()
	quit()
