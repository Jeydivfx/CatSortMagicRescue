extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(720,1120)
	var stage := Node2D.new()
	root.add_child(stage)
	stage.draw.connect(func(): stage.draw_rect(Rect2(0,0,720,1120),Color("172638")))
	var heading := Label.new()
	heading.text = "Meet the kittens"
	heading.position = Vector2(0,45)
	heading.size.x = 720
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size",36)
	stage.add_child(heading)
	var catalog = preload("res://scripts/cat_breeds.gd")
	for index in range(catalog.ACTIVE_IDS.size()):
		var kind: int = catalog.ACTIVE_IDS[index]
		var actor = preload("res://scripts/cat_actor.gd").new()
		actor.setup(null,kind,kind*.7)
		actor.forced_face = 0
		actor.position = Vector2(140+(index%3)*220,230+(index/3)*300)
		actor.animate(0,false,0,0)
		actor.scale = Vector2.ONE*1.65
		stage.add_child(actor)
		var label := Label.new()
		label.text = catalog.NAMES[kind]
		label.position = actor.position+Vector2(-105,85)
		label.size = Vector2(210,36)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",17)
		stage.add_child(label)
	await create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://cat_breeds_preview.png")
	quit()
