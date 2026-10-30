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
var best_icon:Texture2D
var result_art:Texture2D
var cushion_art:Texture2D
var star_art:Texture2D
var coin_art:Texture2D

func show_score(result: Dictionary) -> void:
	if result.is_empty():
		return
	earned_stars = int(result.stars)
	score_label.text = L.digits(str(int(result.score)))
	reward_label.text = L.t("+%d coins" % result.coins)

func setup(atlas: Texture2D, moves: int, best: int, last_level: bool, gentle: bool) -> void:
	size=Vector2(720,1120);layout_direction=Control.LAYOUT_DIRECTION_LTR;mouse_filter=Control.MOUSE_FILTER_STOP;z_index=10
	gentle_motion=gentle;target_moves=moves
	result_art=preload("res://assets/branding/result_royal_assets_v1.png")
	cushion_art=art_region(Rect2(40,242,738,323));star_art=art_region(Rect2(847,96,552,523));coin_art=art_region(Rect2(1572,105,525,527))
	var shell=Panel.new();shell.name="ResultPanel";shell.size=Vector2(560,830);shell.mouse_filter=Control.MOUSE_FILTER_IGNORE;shell.add_theme_stylebox_override("panel",box(Color(.04,.065,.15,.88),38,Color("ddbd7e")));add_child(shell);shell.position=Vector2(80,130)
	effects=drawing_layer(draw_effects)
	banner=Control.new();banner.size=Vector2(720,340);banner.layout_direction=Control.LAYOUT_DIRECTION_LTR;add_child(banner);banner.position=Vector2.ZERO;banner.set_meta("l10n_x",0)
	label("Level Complete!",Rect2(115,270,490,60),38,Color("fff0cd"),banner)
	stars=drawing_layer(draw_stars);hero=drawing_layer(draw_hero)
	cat=preload("res://scripts/cat_actor.gd").new();cat.setup(atlas,1,.8);cat.forced_face=2;hero.add_child(cat)
	crown=Node2D.new();crown.name="AttachedCrown";cat.add_child(crown);crown.z_index=2;crown.draw.connect(func():draw_crown(crown))
	card=Panel.new();card.name="ResultStats";card.size=Vector2(492,270);card.add_theme_stylebox_override("panel",box(Color(.09,.12,.24,.92),28,Color("434c83")));add_child(card);card.position=Vector2(114,575)
	for i in range(3):
		var caption=label(["Moves:","Best:","Score:"][i],Rect2(114,12+i*55,230,44),23,Color("d8dbe5"),card);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	move_label=label("0",Rect2(327,10,80,44),25,Color("ffe8b7"),card)
	label(L.digits(str(best)),Rect2(327,65,80,44),25,Color("ffe8b7"),card)
	score_label=label("0",Rect2(302,120,105,44),25,Color("ffe8b7"),card)
	var decor=Node2D.new();card.add_child(decor);card.move_child(decor,0)
	best_icon=preload("res://scripts/ranking_badges.gd").texture(0)
	decor.draw.connect(func():
		for y in [10,65,120]:decor.draw_style_box(box(Color("1a2644"),24,Color("404b7a")),Rect2(30,y,432,49))
		var gold=Color("ffd57c")
		for pos in [Vector2(47,25),Vector2(56,19),Vector2(66,21),Vector2(73,28)]:decor.draw_circle(pos,4,gold)
		decor.draw_circle(Vector2(59,36),8,gold)
		decor.draw_texture_rect(best_icon,Rect2(39,70,43,36),false)
		decor.draw_texture_rect(star_art,Rect2(41,125,36,36),false))
	var reward=Panel.new();reward.size=Vector2(444,64);reward.add_theme_stylebox_override("panel",box(Color(.13,.14,.20,.95),22,Color("a3895c")));add_child(reward);reward.position=Vector2(138,773)
	reward_label=label("",Rect2(166,8,244,48),25,Color("ffdc86"),reward)
	var coin=Node2D.new();reward.add_child(coin);coin.draw.connect(func():
		if coin_art:coin.draw_texture_rect(coin_art,Rect2(107,3,58,58),false))

	next_button=button("Back to Home" if last_level else "Next Level",Rect2(369,861,244,76),Color("259c43"),self);next_button.symbol="play";next_button.title_size=29
	next_button.pressed.connect(func():
		if last_level:home_pressed.emit()
		else:next_pressed.emit())
	home_button=button("Home",Rect2(107,861,244,76),Color("514399"),self);home_button.symbol="home";home_button.title_size=25;home_button.pressed.connect(func():home_pressed.emit())
	next_button.name="ResultNext";home_button.name="ResultHome"
	next_button.disabled=true;home_button.disabled=true
	banner.modulate.a=0;hero.modulate.a=0;card.modulate.a=0;reward.modulate.a=0;next_button.modulate.a=0;home_button.modulate.a=0
	sequence=create_tween();sequence.tween_callback(func():cue("win"))
	create_tween().tween_property(self,"scrim",1.0,.3)
	var entry=create_tween().set_parallel(true)
	for pair in [[banner,.08],[hero,.25],[card,.6],[reward,.75],[next_button,.85],[home_button,.95]]:entry.tween_property(pair[0],"modulate:a",1.0,.35).set_delay(pair[1])
	entry.tween_property(self,"hero_reveal",1.0,.65).set_delay(.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for i in range(3):
		var index=i;var pop=create_tween();pop.tween_interval(.3+i*.23);pop.tween_callback(func():
			if index<earned_stars:cue("star_%d"%index))
		pop.tween_method(func(v:float):star_scales[index]=v,0.0,1.0,.4).set_trans(Tween.TRANS_SINE if gentle else Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	cue("result_victory_jingle")
	var count=create_tween();count.tween_interval(.68);count.tween_method(func(v:float):move_label.text=L.digits(str(roundi(v))),0.0,float(moves),.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	create_tween().tween_callback(func():next_button.disabled=false;home_button.disabled=false).set_delay(.94)
	get_viewport().size_changed.connect(layout_result);layout_result()

func layout_result()->void:
	var parent=get_parent();var safe:Rect2=parent.content_rect() if parent.has_method("content_rect") else Rect2(Vector2.ZERO,get_viewport_rect().size)
	var factor=minf(1.08,minf((safe.size.x-36)/560.0,(safe.size.y-36)/830.0));scale=Vector2.ONE*factor;position=safe.get_center()-Vector2(360,545)*factor

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
	item.position=rect.position
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
	var item := preload("res://scripts/jewel_button.gd").new()
	item.set_meta("l10n_x",rect.position.x)
	L.style(item)
	item.text = L.t(value)
	item.tint=color
	item.position = rect.position
	item.size = rect.size
	item.add_theme_font_size_override("font_size", 29)
	item.add_theme_stylebox_override("normal", box(color, 23, color.lightened(0.25)))
	item.add_theme_stylebox_override("hover", box(color.lightened(0.12), 23, color.lightened(0.3)))
	item.add_theme_stylebox_override("pressed", box(color.darkened(0.16), 23, color.lightened(0.15)))
	parent.add_child(item)
	item.position=rect.position
	item.caption_override="\u200b"
	var caption=Label.new();L.style(caption);caption.text=L.t(value);caption.size=Vector2(rect.size.x-92,rect.size.y);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;caption.add_theme_font_size_override("font_size",22 if rect.size.x<300 else 26);caption.mouse_filter=Control.MOUSE_FILTER_IGNORE;item.add_child(caption);caption.position=Vector2(76,0);caption.set_meta("l10n_x",76)
	return item

func _process(delta: float) -> void:
	age += delta
	if is_instance_valid(cat):
		cat.animate_victory(age, gentle_motion)
		cat.scale*=.88
		cat.position.y += 30+(1.0 - hero_reveal)*26
		crown.position=cat.victory_head_anchor(age,gentle_motion)
	for layer in [stars, effects, hero]:
		if is_instance_valid(layer):
			layer.queue_redraw()
	queue_redraw()

func _draw() -> void:
	var inverse=get_global_transform().affine_inverse();var target=Rect2(inverse*Vector2.ZERO,get_viewport_rect().size/scale)
	draw_rect(target,Color("080b14"))

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
		var center := Vector2(268+i*92,232 if i!=1 else 210)
		var scale_value: float = star_scales[i]
		var turn := (1.0-minf(scale_value,1.0))*(-0.24 if i!=1 else 0.24) if not gentle_motion else 0.0
		var radius:float=(40 if i!=1 else 52)*scale_value
		if radius>.2:
			canvas.draw_set_transform(center,turn)
			canvas.draw_texture_rect(star_art,Rect2(Vector2(-radius,-radius),Vector2.ONE*radius*2),false,Color.WHITE if i<earned_stars else Color(.25,.27,.36,.75))
			canvas.draw_set_transform(Vector2.ZERO)
		var flash := age-(0.30+i*0.23)
		if flash>0 and flash<0.55 and not gentle_motion:
			for ray in range(8):
				var direction := Vector2.from_angle(ray*TAU/8.0)
				canvas.draw_line(center+direction*(48+flash*55),center+direction*(58+flash*65),Color(1,0.87,0.52,(1-flash/0.55)*0.7),2,true)

func draw_hero(canvas: Node2D) -> void:
	if cushion_art:canvas.draw_texture_rect(cushion_art,Rect2(181,490,358,85),false)

func draw_crown(canvas: Node2D) -> void:
	if best_icon:canvas.draw_texture_rect(best_icon,Rect2(-17,-25,34,29),false)

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

func art_region(region:Rect2)->AtlasTexture:
	var texture=AtlasTexture.new();texture.atlas=result_art;texture.region=region;return texture
