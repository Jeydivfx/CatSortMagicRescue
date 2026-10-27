extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var report: Array=[]
	for kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:
		var actor=preload("res://scripts/cat_actor.gd").new()
		root.add_child(actor)
		actor.setup(null,kind,0)
		var r: Rect2=actor.sprite.region_rect
		report.append({"kind":kind,"file":actor.sprite.texture.resource_path.trim_prefix("res://"),"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"scale":actor.sprite.scale.x})
		actor.free()
	var file=FileAccess.open("res://cat_size_metrics.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report))
	quit()
