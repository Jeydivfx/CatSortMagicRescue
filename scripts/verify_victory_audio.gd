extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var bank = load("res://scripts/sound_bank.gd").new()
	root.add_child(bank)
	bank.music.play()
	assert(bank.celebration.stream.get_length()>2 and bank.celebration.stream.get_length()<2.4)
	bank.start_celebration()
	assert(bank.celebrating and bank.music.stream_paused)
	var playback = bank.celebration.get_stream_playback()
	bank.start_celebration()
	assert(playback==bank.celebration.get_stream_playback())
	bank.set_suspended("ad",true)
	assert(bank.celebration.stream_paused)
	bank.set_suspended("focus",true)
	bank.set_suspended("ad",false)
	assert(bank.celebration.stream_paused and bank.music.stream_paused)
	bank.set_suspended("focus",false)
	assert(not bank.celebration.stream_paused and bank.music.stream_paused)
	bank.celebration.finished.emit()
	assert(not bank.celebrating and not bank.music.stream_paused)
	bank.start_celebration()
	bank.set_enabled(false)
	assert(not bank.celebrating and not bank.celebration.playing)
	bank.start_celebration()
	assert(not bank.celebrating)
	print("PASS victory music replaces background, is idempotent, pauses with ads/focus, resumes background and respects mute")
	bank.set_music_enabled(false)
	await create_timer(.25).timeout
	bank.free()
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.start_game(0)
	scene.best_moves["0"] = 3
	scene.audio.start_celebration()
	assert(scene.audio.celebrating)
	scene.show_win()
	assert(not scene.audio.celebrating and not scene.audio.celebration.playing)
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS results screen always ends dance music")
	quit()
