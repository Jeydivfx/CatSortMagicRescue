extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var catalog = preload("res://scripts/cat_breeds.gd")
	var regions := {}
	for kind in catalog.ACTIVE_IDS:
		var actor = preload("res://scripts/cat_actor.gd").new()
		actor.setup(null,kind,0)
		root.add_child(actor)
		assert(actor.modulate==Color.WHITE)
		var path: String = actor.sprite.texture.resource_path
		var signature: String = path+str(actor.sprite.region_rect)
		assert(not regions.has(signature))
		regions[signature] = true
		if kind<3: assert(path=="res://assets/cats_expressions.png")
		var stable: Rect2 = actor.sprite.region_rect
		for expression in range(4):
			var frame: Rect2 = actor.frame_rects[Vector2i(actor.art_kind,expression)]
			assert(frame.size.x>100 and frame.size.y>100)
			assert(Rect2(Vector2.ZERO,actor.sprite.texture.get_size()).encloses(frame))
			actor.animate(expression*.3,false,0,expression)
			assert(actor.sprite.region_rect==stable)
		actor.free()
	var campaign: Array = JSON.parse_string(FileAccess.get_file_as_string("res://levels/campaign.json"))
	var seen := {}
	for level in campaign:
		for tube in level.tubes:
			for kind in tube: seen[int(kind)] = true
	assert(seen.size()==9 and campaign[250].new_cat=="Russian Blue")
	for removed in [7,8,9]: assert(not seen.has(removed))
	print("PASS nine distinct breed artworks, retired breeds absent, no recolor tints, original three preserved and four expressions")
	quit()
