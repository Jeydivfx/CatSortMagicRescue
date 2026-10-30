extends SceneTree
func _initialize() -> void:
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/witch_v2/sheets.json"))
	var frames:=SpriteFrames.new();frames.remove_animation("default")
	for key in data.animations:
		var clip: Dictionary=data.animations[key]
		frames.add_animation(key);frames.set_animation_speed(key,data.fps);frames.set_animation_loop(key,clip.loop)
		for i in range(int(clip.frames)):
			var texture:=AtlasTexture.new();texture.atlas=load(clip.pages[i/64]);texture.region=Rect2((i%8)*320,((i%64)/8)*368,320,368);texture.filter_clip=true
			frames.add_frame(key,texture)
	assert(ResourceSaver.save(frames,"res://assets/witch_v2/witch_frames.tres")==OK)
	print("PASS native SpriteFrames resource: ",frames.get_animation_names());quit()
