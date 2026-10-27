extends SceneTree
func _initialize() -> void:call_deferred("run")
func label_at(parent: Node,value: String,p: Vector2,extent: Vector2,font_size: int) -> void:
	var l:=Label.new();l.text=value;l.position=p;l.size=extent
	l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font",load("res://assets/fonts/game_font.tres"))
	l.add_theme_font_size_override("font_size",font_size);parent.add_child(l)
func run() -> void:
	var viewport:=SubViewport.new();viewport.size=Vector2i(1080,360);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
	var bg:=ColorRect.new();bg.size=Vector2(1080,360);bg.color=Color("14213b");viewport.add_child(bg)
	label_at(viewport,"Visible ears — all nine breeds",Vector2(0,8),Vector2(1080,34),24)
	var breeds=preload("res://scripts/cat_breeds.gd")
	for i in range(9):
		var kind: int=breeds.ACTIVE_IDS[i]
		for slot in range(4):
			var cat=preload("res://scripts/cat_actor.gd").new();viewport.add_child(cat)
			cat.setup(null,kind,0);cat.set_stack_count(4,slot<3)
			cat.stack_weight=1;cat.animate(0,false)
			cat.position=Vector2(60+i*120,300-(44+slot*57));cat.z_index=slot*2
		label_at(viewport,breeds.NAMES[kind],Vector2(i*120,318),Vector2(120,24),12)
	await create_timer(.1).timeout;await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://all_breed_ears_preview.png")
	viewport.free()
	var rig_view:=SubViewport.new();rig_view.size=Vector2i(210,240);rig_view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(rig_view)
	var background:=ColorRect.new();background.size=Vector2(210,240);background.color=Color("14213b");rig_view.add_child(background)
	var rig=preload("res://scripts/witch_rig.gd").new();rig_view.add_child(rig);rig.position=Vector2(10,5);rig.set_process(false)
	var sheet:=Image.create(1260,720,false,Image.FORMAT_RGB8)
	for kind in range(3):
		rig.reset();rig.allow_idle=true;rig.begin_gesture(kind)
		for phase in range(6):
			for frame in range(18):rig._process(1.0/60)
			await process_frame;await RenderingServer.frame_post_draw
			var shot:=rig_view.get_texture().get_image();shot.convert(Image.FORMAT_RGB8)
			sheet.blit_rect(shot,Rect2i(0,0,210,240),Vector2i(phase*210,kind*240))
	sheet.save_png("res://witch_gestures_preview.png")
	rig_view.free();quit()
