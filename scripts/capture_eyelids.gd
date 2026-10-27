extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(900,660)
	var stage:=Node2D.new();root.add_child(stage)
	var bg:=ColorRect.new();bg.color=Color("182238");bg.size=Vector2(900,660);stage.add_child(bg)
	var actors: Array=[]
	for row in range(3):
		for col in range(5):
			var cat=preload("res://scripts/cat_actor.gd").new();stage.add_child(cat)
			cat.setup(null,row,0);cat.animate(1,false)
			cat.position=Vector2(90+180*col,126+210*row);cat.scale=Vector2.ONE*2
			var closure: float=[0.0,.3,.6,.85,1.0][col]
			cat.face_material.set_shader_parameter("weights",Vector4(1-closure,closure,0,0))
			actors.append(cat)
	await process_frame;RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://video_work/eyelid_phases.png")
	for cat in actors:cat.free()
	for i in range(9):
		var cat=preload("res://scripts/cat_actor.gd").new();stage.add_child(cat)
		cat.setup(null,preload("res://scripts/cat_breeds.gd").ACTIVE_IDS[i],0);cat.animate(1,false)
		cat.position=Vector2(150+300*(i%3),126+210*(i/3));cat.scale=Vector2.ONE*2
		cat.face_material.set_shader_parameter("weights",Vector4(0,1,0,0))
	await process_frame;RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://video_work/eyelids_all_breeds.png")
	stage.free();await process_frame;quit()
