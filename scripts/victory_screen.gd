extends Control

const L = preload("res://scripts/localization.gd")

signal next_pressed
signal home_pressed
signal audio_cue(name: String)

var age := 0.0
var gentle_motion := false
var scrim := 0.0
var hero_reveal := 0.0
var star_scales := [0.0, 0.0, 0.0]
var banner: Control
var card: Panel
var stars: Node2D
var effects: Node2D
var hero: Node2D
var crown: Node2D
var cat: Node2D
var next_button: Button
var home_button: Button
var move_label: Label
var sequence: Tween
var cue_history: Array[String] = []
var target_moves := 0
var earned_stars := 3
var score_label: Label
var reward_label: Label

func show_score(result: Dictionary) -> void:
	if result.is_empty():
		return
	earned_stars = int(result.stars)
	score_label.text = L.t("Score %d" % result.score)
	reward_label.text = L.t("+%d coins" % result.coins)
	if result.get("keepsake",false):
		home_button.text=L.t("New keepsake!")
		home_button.set_meta("l10n_source","New keepsake!")
		home_button.add_theme_font_size_override("font_size",18)

func setup(atlas: Texture2D, moves: int, best: int, last_level: bool, gentle: bool) -> void:
	size = Vector2(720, 1018)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 10
	gentle_motion = gentle
	target_moves = moves
	effects = drawing_layer(draw_effects)
	banner = Control.new()
	banner.set_meta("l10n_x",0)
	banner.size = Vector2(720, 280)
	banner.pivot_offset = Vector2(360, 230)
	add_child(banner)
	var ribbon := Node2D.new()
	ribbon.draw.connect(func(): draw_banner(ribbon))
	banner.add_child(ribbon)
	label("Level Complete!", Rect2(70, 205, 580, 65), 43, Color("66401f"), banner)
	stars = drawing_layer(draw_stars)
	hero = drawing_layer(draw_hero)
	cat = preload("res://scripts/cat_actor.gd").new()
	cat.setup(atlas, 1, 0.8)
	cat.forced_face = 2
	cat.position = Vector2(360, 408)
	hero.add_child(cat)
	crown=Node2D.new()
	crown.name="AttachedCrown"
	crown.z_index=2
	crown.draw.connect(func():draw_crown(crown))
	cat.add_child(crown)
	crown.position=cat.victory_head_anchor(0,gentle)
	card = Panel.new()
	card.set_meta("l10n_x",150)
	card.position = Vector2(150, 556)
	card.size = Vector2(420, 330)
	card.add_theme_stylebox_override("panel", box(Color("f1debc"), 30, Color("c49c65")))
	add_child(card)
	move_label = label("Moves: 0", Rect2(0, 22, 420, 42), 29, Color("674731"), card)
	label("Best: %d" % best, Rect2(0, 79, 420, 42), 27, Color("946a3d"), card)
	score_label = label("",Rect2(20,132,380,34),23,Color("674731"),card)
	reward_label = label("",Rect2(20,174,380,38),21,Color("946a3d"),card)
	var line := ColorRect.new()
	line.set_meta("l10n_x",44)
	line.color = Color("d9be95")
	line.position = Vector2(44, 70)
	line.size = Vector2(332, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(line)
	next_button = button("Back to Home" if last_level else "Next Level", Rect2(40, 220, 340, 78), Color("579d60"), card)
	next_button.pressed.connect(func():
		if last_level:
			home_pressed.emit()
		else:
			next_pressed.emit())
	home_button = button("Home", Rect2(260, 922, 200, 56), Color("3d4b61"), self)
	home_button.pressed.connect(func(): home_pressed.emit())
	next_button.disabled = true
	home_button.disabled = true
	banner.modulate.a = 0
	banner.position.y = -20 if not gentle else 0
	card.modulate.a = 0
	card.position.y += 22 if not gentle else 0
	hero.modulate.a = 0
	home_button.modulate.a = 0
	sequence = create_tween()
	sequence.tween_callback(func(): cue("win"))
	create_tween().tween_property(self, "scrim", 1.0, 0.28).set_trans(Tween.TRANS_SINE)
	var entry := create_tween().set_parallel(true)
	entry.tween_property(banner, "modulate:a", 1.0, 0.30).set_delay(0.08)
	entry.tween_property(banner, "position:y", 0.0, 0.55).set_delay(0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry.tween_property(hero, "modulate:a", 1.0, 0.35).set_delay(0.26)
	entry.tween_property(self, "hero_reveal", 1.0, 0.65).set_delay(0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry.tween_property(card, "modulate:a", 1.0, 0.35).set_delay(0.62)
	entry.tween_property(card, "position:y", 556.0, 0.50).set_delay(0.62).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry.tween_property(home_button, "modulate:a", 1.0, 0.30).set_delay(0.95)
	for i in range(3):
		var index := i
		var delay := 0.30 + i * 0.23
		var pop := create_tween()
		pop.tween_interval(delay)
		pop.tween_callback(func():
			if index<earned_stars: cue("star_%d" % index))
		pop.tween_method(func(value: float): star_scales[index] = value, 0.0, 1.0, 0.40).set_trans(Tween.TRANS_SINE if gentle else Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var count := create_tween()
	count.tween_interval(0.68)
	count.tween_method(func(value: float): move_label.text = L.t("Moves: %d" % roundi(value)), 0.0, float(moves), 0.50).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	create_tween().tween_callback(func():
		next_button.disabled = false
		home_button.disabled = false).set_delay(0.94)

func cue(name: String) -> void:
	if name in cue_history:
		return
	cue_history.append(name)
	audio_cue.emit(name)

func drawing_layer(callback: Callable) -> Node2D:
	var node := Node2D.new()
	node.draw.connect(func(): callback.call(node))
	add_child(node)
	return node

func label(value: String, rect: Rect2, font_size: int, color: Color, parent: Node) -> Label:
	var item := Label.new()
	item.set_meta("l10n_x",rect.position.x)
	L.style(item)
	item.text = L.t(value)
	item.position = rect.position
	item.size = rect.size
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

func box(color: Color, radius: int, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.17)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 5)
	return style

func button(value: String, rect: Rect2, color: Color, parent: Node) -> Button:
	var item := Button.new()
	item.set_meta("l10n_x",rect.position.x)
	L.style(item)
	item.text = L.t(value)
	item.position = rect.position
	item.size = rect.size
	item.add_theme_font_size_override("font_size", 29)
	item.add_theme_stylebox_override("normal", box(color, 23, color.lightened(0.25)))
	item.add_theme_stylebox_override("hover", box(color.lightened(0.12), 23, color.lightened(0.3)))
	item.add_theme_stylebox_override("pressed", box(color.darkened(0.16), 23, color.lightened(0.15)))
	parent.add_child(item)
	return item

func _process(delta: float) -> void:
	age += delta
	if is_instance_valid(cat):
		cat.animate_victory(age, gentle_motion)
		cat.position.y += (1.0 - hero_reveal) * 26
		crown.position=cat.victory_head_anchor(age,gentle_motion)
	for layer in [stars, effects, hero]:
		if is_instance_valid(layer):
			layer.queue_redraw()
	queue_redraw()

func _draw() -> void:
	var origin: Vector2 = get_parent().position if get_parent() is Node2D else Vector2.ZERO
	draw_rect(Rect2(-origin,get_viewport_rect().size), Color(0.025, 0.04, 0.075, 0.96 * scrim))

func star(canvas: Node2D, center: Vector2, radius: float, tint: Color, rotation: float = 0.0) -> void:
	if radius <= 0.2:
		return
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI / 2 + i * PI / 5 + rotation
		points.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.0 if i % 2 == 0 else 0.48))
	canvas.draw_colored_polygon(points, tint)
	points.append(points[0])
	canvas.draw_polyline(points, Color("d39b32"), 2, true)

func draw_banner(canvas: Node2D) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(128,209),Vector2(83,228),Vector2(107,255),Vector2(85,278),Vector2(160,263)]),Color("cf933d"))
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(592,209),Vector2(637,228),Vector2(613,255),Vector2(635,278),Vector2(560,263)]),Color("cf933d"))
	canvas.draw_style_box(box(Color("f4d48b"),22,Color("ffebae")),Rect2(110,192,500,81))

func draw_stars(canvas: Node2D) -> void:
	for i in range(3):
		var center := Vector2(250+i*110,137 if i!=1 else 114)
		var scale_value: float = star_scales[i]
		var turn := (1.0-minf(scale_value,1.0))*(-0.24 if i!=1 else 0.24) if not gentle_motion else 0.0
		star(canvas,center+Vector2(0,5),(43 if i!=1 else 55)*scale_value,Color("ad6e2b"),turn)
		star(canvas,center,(40 if i!=1 else 52)*scale_value,Color("ffe081") if i<earned_stars else Color("6b6875"),turn)
		var flash := age-(0.30+i*0.23)
		if flash>0 and flash<0.55 and not gentle_motion:
			for ray in range(8):
				var direction := Vector2.from_angle(ray*TAU/8.0)
				canvas.draw_line(center+direction*(48+flash*55),center+direction*(58+flash*65),Color(1,0.87,0.52,(1-flash/0.55)*0.7),2,true)

func draw_hero(canvas: Node2D) -> void:
	canvas.draw_style_box(box(Color("536a82"),30,Color("8095ad")),Rect2(207,493,306,37))

func draw_crown(canvas: Node2D) -> void:
	var points:=PackedVector2Array([Vector2(-14,0),Vector2(-18,-14),Vector2(-8,-9),Vector2(0,-20),Vector2(8,-9),Vector2(18,-14),Vector2(14,0)])
	canvas.draw_colored_polygon(points,Color("efba4c"))
	canvas.draw_circle(Vector2(0,-7),2.2,Color("fff0aa"))

func draw_effects(canvas: Node2D) -> void:
	if age < 0.32:
		return
	for i in range(12):
		var angle := i*2.399+age*0.07
		var pos := Vector2(360,390)+Vector2.from_angle(angle)*(148+i%4*24)
		star(canvas,pos,2.4+sin(age*2+i)*1.1,Color(1,0.83,0.4,0.48*scrim))
	if gentle_motion:
		return
	var t := age-0.32
	if t > 3.1:
		return
	for i in range(44):
		var angle := -PI+float(i)*2.399
		var speed := 95.0+i%7*23
		var start := Vector2(360,350)
		var pos := start+Vector2(cos(angle)*speed*t,sin(angle)*speed*t+90*t*t)
		if pos.x<40 or pos.x>680 or pos.y<40 or pos.y>930:
			continue
		var tint: Color = [Color("f1cc73"),Color("90c6c1"),Color("d9a5b8")][i%3]
		tint.a = clampf(1-t/3.1,0,1)*0.8
		canvas.draw_set_transform(pos,t*2+i)
		canvas.draw_rect(Rect2(-2,-4,4,8),tint)
	canvas.draw_set_transform(Vector2.ZERO)
