extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	for size_value in [Vector2i(360,780),Vector2i(360,800),Vector2i(414,896),Vector2i(540,1200)]:
		root.size=size_value;await process_frame;g.layout_safe_override=Vector2(38,20);g.layout_banner_override=110;g.fit_mobile_screen()
		for level in [0,1]:
			g.start_game(level);g.cancel_witch_entry();g.fit_mobile_screen()
			var area: Rect2=g.board_area();var cols: int=g.board_columns();var expected: float=minf(1.4,minf((area.size.x-26*(cols-1))/(108*cols),area.size.y/250))
			assert(absf(g.board_scale()-expected)<.001 and g.board_scale()>1.10)
			for i in range(g.tubes.size()):
				var a: Rect2=g.tube_rect(i)
				assert(a.position.x>=0 and a.end.x<=720 and a.end.y<g.wizard.position.y)
				for j in range(i):assert(not a.intersects(g.tube_rect(j)))
	assert(g.wizard.frames.model.get_script().resource_path.ends_with("witch_model_classic.gd"))
	var model=g.wizard.frames.model
	model.apply_pose(preload("res://scripts/witch_pose_v2.gd").sample("fake_cry",1.2))
	assert(model.pose_data.tear>.9 and model.pose_data.staff_drop==1)
	assert(model.shoulder_l.z_index>model.neck.z_index and model.shoulder_r.z_index>model.neck.z_index,"Wiping hands must be in front of the face")
	model.apply_pose(preload("res://scripts/witch_pose_v2.gd").sample("evil_laugh",1.2))
	assert(model.pose_data.mouth>.5 and model.pose_data.tear==0)
	g.free();await process_frame;print("PASS first two levels use normal 1.4 scale cap across four tall-phone sizes; no tube overlap; classic witch attached to current animator");quit()
