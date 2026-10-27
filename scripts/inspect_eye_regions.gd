extends SceneTree
func _initialize() -> void:
	var entries: Array=[]
	for kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:
		var cat=preload("res://scripts/cat_actor.gd").new();root.add_child(cat);cat.setup(null,kind,0)
		var r: Rect2=cat.sprite.region_rect
		entries.append({"kind":kind,"path":cat.sprite.texture.resource_path.trim_prefix("res://"),"rect":[r.position.x,r.position.y,r.size.x,r.size.y]})
		cat.free()
	FileAccess.open("res://video_work/eye_regions.json",FileAccess.WRITE).store_string(JSON.stringify(entries))
	quit()
