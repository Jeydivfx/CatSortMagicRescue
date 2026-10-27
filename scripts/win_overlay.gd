extends Control

signal next_pressed
signal home_pressed

var age := 0.0
var star_pop := [0.0, 0.0, 0.0]
var group: Control
var cat: Node2D

func setup(atlas: Texture2D, moves: int, best: int, last_level: bool, gentle: bool) -> void:
	size = Vector2(720, 1018)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 10
	group = Control.new()
	group.size = size
	group.pivot_offset = Vector2(360, 500)
	add_child(group)
	var canvas := Node2D.new()
	canvas.draw.connect(func(): draw_card(canvas))
	group.add_child(canvas)
	group.set_meta("canvas", canvas)
	text("Level Complete!", 205, 43, Color("66401f"))
	text("PURRFECT LITTLE PAWS", 272, 16, Color("d6bd86"))
	cat = preload("res://scripts/cat_actor.gd").new()
	cat.setup(atlas, 1, 0.8)
	cat.position = Vector2(360, 408)
	cat.forced_face = 2
	group.add_child(cat)
	text("Moves: %d" % moves, 579, 29, Color("674731"))
	text("Best: %d" % best, 635, 27, Color("946a3d"))
	var next := action_button("Back to Home" if last_level else "Next Level", Rect2(190, 715, 340, 78), Color("579d60"))
	next.pressed.connect(func():
		if last_level:
			home_pressed.emit()
		else:
			next_pressed.emit())
	var home := action_button("Home", Rect2(260, 858, 200, 56), Color("3d4b61"))
	home.pressed.connect(func(): home_pressed.emit())
	group.modulate.a = 0.0
	group.scale = Vector2.ONE * (0.96 if gentle else 0.84)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(group, "modulate:a", 1.0, 0.24)
	tween.tween_property(group, "scale", Vector2.ONE, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for i in range(3):
		var index := i
		create_tween().tween_method(func(value: float): star_pop[index] = value, 0.0, 1.0, 0.35).set_delay(0.18 + i * 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func text(value: String, y: float, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = Vector2(60, y)
	label.size.x = 600
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_child(label)

func box(color: Color, radius: int, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(2)
	return style

func action_button(value: String, rect: Rect2, color: Color) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 29)
	button.add_theme_stylebox_override("normal", box(color, 23, color.lightened(0.25)))
	button.add_theme_stylebox_override("hover", box(color.lightened(0.12), 23, color.lightened(0.3)))
	button.add_theme_stylebox_override("pressed", box(color.darkened(0.16), 23, color.lightened(0.15)))
	group.add_child(button)
	return button

func _process(delta: float) -> void:
	age += delta
	if is_instance_valid(cat):
		cat.animate(age, false, 0, 2)
		cat.scale *= 2.3
		group.get_meta("canvas").queue_redraw()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 720, 1018), Color(0.025, 0.04, 0.075, 0.88))

func star(canvas: Node2D, center: Vector2, radius: float, tint: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI / 2 + i * PI / 5
		points.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.0 if i % 2 == 0 else 0.48))
	canvas.draw_colored_polygon(points, tint)
	points.append(points[0])
	canvas.draw_polyline(points, Color("d39b32"), 2, true)

func draw_card(canvas: Node2D) -> void:
	for i in range(18):
		var angle := i * 2.399 + age * 0.035
		var radius := 125.0 + fmod(i * 29.0 + age * 10, 125)
		var pos := Vector2(360, 385) + Vector2(cos(angle), sin(angle)) * radius
		star(canvas, pos, 3 + sin(age * 2 + i) * 1.5, Color(1, 0.83, 0.4, 0.6))
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(128, 209), Vector2(83, 228), Vector2(107, 255), Vector2(85, 278), Vector2(160, 263)]), Color("cf933d"))
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(592, 209), Vector2(637, 228), Vector2(613, 255), Vector2(635, 278), Vector2(560, 263)]), Color("cf933d"))
	canvas.draw_style_box(box(Color("f4d48b"), 22, Color("ffebae")), Rect2(110, 192, 500, 81))
	for i in range(3):
		var center := Vector2(250 + i * 110, 137 if i != 1 else 114)
		star(canvas, center + Vector2(0, 4), (43 if i != 1 else 55) * star_pop[i], Color("ad6e2b"))
		star(canvas, center, (40 if i != 1 else 52) * star_pop[i], Color("ffe081"))
	canvas.draw_style_box(box(Color("536a82"), 30, Color("8095ad")), Rect2(207, 493, 306, 37))
	canvas.draw_style_box(box(Color("f1debc"), 30, Color("c49c65")), Rect2(150, 556, 420, 271))
	canvas.draw_line(Vector2(194, 626), Vector2(526, 626), Color("d9be95"), 2)
	# Crown floats above the happy kitten's head.
	var crown := PackedVector2Array([Vector2(327, 322), Vector2(319, 289), Vector2(341, 301), Vector2(359, 276), Vector2(377, 301), Vector2(399, 289), Vector2(391, 322)])
	canvas.draw_colored_polygon(crown, Color("efba4c"))
	canvas.draw_circle(Vector2(359, 306), 5, Color("fff0aa"))
