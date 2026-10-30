extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://video_work/breed_references")
	var data:={}
	for kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:
		var cat=preload("res://scripts/cat_actor.gd").new();cat.setup(null,kind,0)
		var frames:={}
		for row in range(4):
			var r: Rect2=cat.frame_rects[Vector2i(kind%4,row)]
			cat.sprite.texture.get_image().get_region(Rect2i(r)).save_png("res://video_work/breed_references/%d_%d.png"%[kind,row])
			frames[str(row)]=[r.position.x,r.position.y,r.size.x,r.size.y]
		data[str(kind)]={"texture":cat.sprite.texture.resource_path,"frames":frames,"eyes":cat.face_material.get_shader_parameter("eye_centers"),"display_scale":cat.sprite.scale.x}
		cat.free()
	var file=FileAccess.open("res://video_work/breed_references/source_frames.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));file.close();quit()
