extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.start_game(0)
	await scene.transfer(0,2)
	assert(scene.wizard.irritation_left==0)
	await scene.transfer(1,0)
	await create_timer(.2).timeout
	assert(not scene.won and not scene.wizard.angry)
	assert(scene.wizard.emotion==2 and scene.wizard.anger>.5)
	assert(scene.wizard.laugh_left==0)
	await create_timer(2.2).timeout
	assert(scene.wizard.emotion!=2 and scene.wizard.anger<.05)
	scene.wizard.react_to_sort()
	scene.load_level(0)
	assert(scene.wizard.irritation_left==0 and scene.wizard.anger==0)
	print("PASS incomplete move has no reaction; completed tube causes eased temporary anger, cancels laugh, returns to idle and resets")
	scene.free()
	quit()
