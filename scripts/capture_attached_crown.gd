extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var view:=SubViewport.new();view.size=Vector2i(720,1018);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view)
	var p=preload("res://scripts/victory_screen.gd").new();view.add_child(p)
	p.setup(load("res://assets/cats_expressions.png"),12,11,false,false)
	p.show_score({"stars":3,"score":276,"coins":30})
	await create_timer(1.4).timeout
	p.set_process(false);p.hero_reveal=1
	var sheet:=Image.create(2160,1018,false,Image.FORMAT_RGB8)
	for i in range(3):
		p.age=[.9,1.2,1.7][i];p._process(0)
		await process_frame;await RenderingServer.frame_post_draw
		var shot:=view.get_texture().get_image();shot.convert(Image.FORMAT_RGB8)
		sheet.blit_rect(shot,Rect2i(0,0,720,1018),Vector2i(i*720,0))
		if i==1:shot.save_png("res://attached_crown_preview.png")
	sheet.save_png("res://attached_crown_motion.png")
	view.free();quit()
