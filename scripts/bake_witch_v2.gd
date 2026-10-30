extends SceneTree
const POSES=preload("res://scripts/witch_pose_v2.gd")
const MODEL=preload("res://scripts/witch_model_v2.gd")
const CELL=Vector2i(320,368)
const PIVOT=Vector2(144,344)
const FPS=24.0
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var output:="res://assets/witch_v2/sheets"
	DirAccess.make_dir_recursive_absolute(output)
	var viewport:=SubViewport.new();viewport.size=CELL;viewport.transparent_bg=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
	var model=MODEL.new();viewport.add_child(model);model.position=PIVOT;model.build()
	var catalog:={"fps":FPS,"cell":[320,368],"pivot":[144,344],"impact_time":POSES.IMPACT_TIME,"animations":{}}
	for state in POSES.DURATIONS:
		if not OS.get_cmdline_user_args().is_empty() and not state in OS.get_cmdline_user_args():
			var old: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/witch_v2/sheets.json"))
			catalog.animations[state]=old.animations[state]
			continue
		var count:=ceili(POSES.duration(state)*FPS)
		var pages: Array=[]
		var page: Image
		model.was_dropped=false
		for i in range(count):
			if i%64==0:page=Image.create(CELL.x*8,CELL.y*8,false,Image.FORMAT_RGBA8)
			model.apply_pose(POSES.sample(state,i/FPS))
			await process_frame;RenderingServer.force_draw()
			var frame:=viewport.get_texture().get_image()
			page.blit_rect(frame,Rect2i(Vector2i.ZERO,CELL),Vector2i((i%8)*CELL.x,((i%64)/8)*CELL.y))
			if i%64==63 or i==count-1:
				var path:=output+"/%s_%02d.png"%[state,i/64]
				assert(page.save_png(path)==OK);pages.append(path)
		catalog.animations[state]={"duration":POSES.duration(state),"frames":count,"loop":state in ["evil_idle","nervous","defeated_idle","broom_entry"],"pages":pages}
		print("BAKED ",state," ",count," frames")
	var file:=FileAccess.open("res://assets/witch_v2/sheets.json",FileAccess.WRITE);file.store_string(JSON.stringify(catalog,"\t"));file.close()
	viewport.free();await process_frame
	print("PASS fixed canvas / fixed pivot witch v2 sprite sheets");quit()
