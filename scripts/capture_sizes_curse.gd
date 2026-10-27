extends SceneTree
const BREEDS=preload("res://scripts/cat_breeds.gd")
func _initialize() -> void:call_deferred("run")
func label_at(parent: Node,value: String,p: Vector2,extent: Vector2,font_size: int) -> void:
	var l:=Label.new()
	l.text=value;l.position=p;l.size=extent
	l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font",load("res://assets/fonts/game_font.tres"))
	l.add_theme_font_size_override("font_size",font_size)
	parent.add_child(l)
func run() -> void:
	root.size=Vector2i(1000,520)
	var gallery:=SubViewport.new()
	gallery.size=Vector2i(1000,520)
	gallery.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(gallery)
	var display:=Control.new()
	gallery.add_child(display)
	var bg:=ColorRect.new();bg.color=Color("14213b");bg.size=Vector2(1000,520);display.add_child(bg)
	label_at(display,"Before — same height, unequal visual size",Vector2(0,20),Vector2(1000,40),24)
	label_at(display,"After — matching silhouettes, original proportions",Vector2(0,275),Vector2(1000,40),24)
	for row in range(2):
		for i in range(BREEDS.ACTIVE_IDS.size()):
			var kind: int=BREEDS.ACTIVE_IDS[i]
			var actor=preload("res://scripts/cat_actor.gd").new()
			display.add_child(actor)
			actor.setup(null,kind,0)
			if row==0:
				var r: Rect2=actor.sprite.region_rect
				actor.sprite.scale=Vector2.ONE*minf(82/r.size.y,94/r.size.x)
				actor.sprite.position.y=40-r.size.y*actor.sprite.scale.y*.5
			actor.position=Vector2(56+i*111,160+row*240)
			actor.scale=Vector2.ONE*1.35
			label_at(display,BREEDS.NAMES[kind],Vector2(i*111,224+row*240),Vector2(111,28),13)
	await create_timer(.1).timeout
	await RenderingServer.frame_post_draw
	gallery.get_texture().get_image().save_png("res://cat_size_comparison.png")
	gallery.free()
	root.size=Vector2i(540,1000)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false
	g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("fa")
	g.start_game(16)
	g.moves=5
	g.curse.try_cast(g)
	await create_timer(.8).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://witch_curse_preview.png")
	g.free();quit()
