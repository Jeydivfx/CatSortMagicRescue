extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,840)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en");g.show_menu()
	g.set_process(false)
	await create_timer(.7).timeout
	var times: Array=[.20,2.06,5.90]
	for i in range(times.size()):
		g.clock=times[i]
		for actor in g.menu_cats.get_children():actor.animate_menu(g.clock,actor.get_meta("menu_origin"),actor.get_meta("menu_scale"),false)
		await process_frame
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://video_work/menu_ears_%02d.png"%i)
	if "--quick" in OS.get_cmdline_user_args():
		g.free();await process_frame;quit();return
	DirAccess.make_dir_recursive_absolute("res://video_work/menu_motion")
	for frame in range(216):
		g.clock=frame/24.0
		for actor in g.menu_cats.get_children():actor.animate_menu(g.clock,actor.get_meta("menu_origin"),actor.get_meta("menu_scale"),false)
		await process_frame
		RenderingServer.force_draw()
		root.get_texture().get_image().get_region(Rect2i(80,240,380,200)).save_png("res://video_work/menu_motion/frame_%03d.png"%frame)
	g.free();await process_frame
	quit()
