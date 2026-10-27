extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.show_menu()
	for cat in g.menu_cats.get_children():
		assert(cat.menu_ears_enabled==(cat.kind!=1))
		var previous:=Vector2.ZERO
		var maximum:=0.0
		var independent:=false
		for frame in range(3600):
			var t:=frame/120.0
			var pose: Vector2=cat.menu_ear_pose(t,false)
			if frame>0:assert(pose.distance_to(previous)<.12)
			previous=pose;maximum=maxf(maximum,pose.length())
			if absf(pose.x-pose.y)>.4:independent=true
		assert(maximum>.5 and independent)
		cat.animate_menu(6,cat.get_meta("menu_origin"),cat.get_meta("menu_scale"),false)
		if cat.menu_ears_enabled:assert(cat.face_material.get_shader_parameter("head_tilt")==0.0)
		cat.animate(7,false)
		assert(cat.face_material.get_shader_parameter("menu_ears")==Vector2.ZERO)
	g.free();await process_frame
	print("PASS side-cat head turns removed; independent smooth ear flicks, reduced motion and no gameplay carryover")
	quit()
