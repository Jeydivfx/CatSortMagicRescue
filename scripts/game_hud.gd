extends Control

const L = preload("res://scripts/localization.gd")

signal star_reached(index: int)

var world_icon_x := 243.0
var moves_icon_x := 527.0
var world_index := 0
var fraction := 0.0
var displayed_fraction := 0.0
var earned := 0
var highest_earned := 0
var possible := 3
var gentle := false
var pulse_ages := [10.0,10.0,10.0]
var pending: Array[int] = []
var cue_delay := 0.0
var detail: Label
var rule: Label
var mascot: AtlasTexture
func make_mascot() -> void:
	# Reuse the actual transparent silver kitten, without the app-icon backdrop.
	var cat=preload("res://scripts/cat_actor.gd").new();cat.setup(null,1,0)
	mascot=AtlasTexture.new();mascot.atlas=cat.sprite.texture
	mascot.region=cat.frame_rects[Vector2i(1,0)];mascot.filter_clip=true
	cat.free()

func _ready() -> void:
	make_mascot()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(696,110)
	detail = small_label(Vector2(578,12),Vector2(110,42),25,Color("fff0cf"))
	rule = small_label(Vector2.ZERO,Vector2.ZERO,1,Color("a9bdce"))
	rule.hide()
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func small_label(point: Vector2, extent: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.set_meta("l10n_x",point.x)
	L.style(label)
	label.position = point
	label.size = extent
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func reset_progress(value: float, cap: int) -> void:
	fraction = clampf(value,0,1)
	possible = clampi(cap,1,3)
	displayed_fraction = minf(fraction,possible/3.0)
	earned = mini(possible,int(floor(fraction*3+0.0001)))
	highest_earned = earned
	pending.clear()
	pulse_ages = [10.0,10.0,10.0]
	cue_delay = 0
	queue_redraw()

func update_progress(value: float, cap: int, complete_count: int, total: int, goal: int) -> void:
	fraction = clampf(value,0,1)
	possible = clampi(cap,1,3)
	earned = mini(possible,int(floor(fraction*3+0.0001)))
	pending = pending.filter(func(index): return index<=earned)
	if earned>highest_earned:
		for index in range(highest_earned+1,earned+1):
			if not pending.has(index):
				pending.append(index)
	detail.text = L.t("%d/%d" % [complete_count,total])
	rule.text = L.t("3 stars: %d moves, no help" % goal if possible==3 else "%d stars available" % possible)
	tooltip_text = L.t(rule.text + ". Fill matching tubes to light stars.")
	queue_redraw()

func _process(delta: float) -> void:
	displayed_fraction = move_toward(displayed_fraction,minf(fraction,possible/3.0),delta*2.0)
	for i in range(3):
		pulse_ages[i] += delta
	cue_delay -= delta
	if not pending.is_empty() and cue_delay<=0 and displayed_fraction>=pending[0]/3.0-0.0001:
		var index: int = pending.pop_front()
		highest_earned = maxi(highest_earned,index)
		pulse_ages[index-1] = 0
		cue_delay = 0.24
		star_reached.emit(index)
	queue_redraw()

func rounded_box(rect: Rect2, color: Color, radius: int, border: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(1)
	draw_style_box(style,rect)

func draw_star(center: Vector2, radius: float, tint: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI/2+i*PI/5
		points.append(center+Vector2.from_angle(angle)*radius*(1 if i%2==0 else 0.47))
	draw_colored_polygon(points,tint)
	points.append(points[0])
	draw_polyline(points,Color("b48338") if tint.r>0.7 else Color("73849b"),1.5,true)

func _draw() -> void:
	rounded_box(Rect2(0,0,696,64),Color(0.025,0.045,0.15,0.94),20,Color("656c9f"))
	for chip in [Rect2(0,74,205,34),Rect2(222,74,270,34),Rect2(508,74,188,34)]:
		rounded_box(chip,Color(.03,.06,.18,.88),17,Color("535f91"))
	draw_world_icon(Vector2(world_icon_x,91))
	draw_footprints(Vector2(moves_icon_x,91))
	# Coin token is code-native and remains readable at phone scale.
	draw_circle(Vector2(81,32),16,Color("b67d26"))
	draw_circle(Vector2(81,30),14,Color("ffcf63"))
	draw_line(Vector2(81,21),Vector2(81,39),Color("ad7424"),2,true)
	if mascot:
		var icon_size:=mascot.get_size()*(48.0/maxf(mascot.get_width(),mascot.get_height()))
		draw_texture_rect(mascot,Rect2(Vector2(548,31)-icon_size*.5,icon_size),false)
	rounded_box(Rect2(220,12,286,40),Color("0c192a"),19,Color("f8e6bd"))
	if displayed_fraction>0.001:
		rounded_box(Rect2(225,17,maxf(10,276*displayed_fraction),30),Color("efc44f"),14,Color("ffe7a0"))
	for i in range(3):
		var center := Vector2(245+238*(i+1)/3.0,33)
		var age: float = pulse_ages[i]
		var scale_value := 1.0
		if age<0.65 and not gentle:
			scale_value += sin(age/0.65*PI)*0.65
		var tint := Color("ffdc7c") if i<earned and displayed_fraction>=(i+1)/3.0-0.0001 else Color("2a3c51")
		if age<0.8:
			var glow := 1-age/0.8
			draw_circle(center,28,Color(1,0.83,0.35,glow*0.3))
			if not gentle:
				draw_arc(center,18+age*32,0,TAU,40,Color(1,0.91,0.60,glow),2.5,true)
		draw_star(center+Vector2(0,2),17*scale_value,Color("1b283b"))
		draw_star(center,15*scale_value,tint)
		if age<0.8 and not gentle:
			var alpha := 1-age/0.8
			for ray in range(12):
				var direction := Vector2.from_angle(ray*TAU/12)
				var point := center+direction*(20+age*55)
				draw_circle(point,3.5*alpha,Color(1,0.86,0.5,alpha))

func oval_icon(center: Vector2, radius: Vector2, tint: Color, angle: float = 0) -> void:
	var points:=PackedVector2Array()
	for i in range(24):
		var a:=i*TAU/24
		points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y).rotated(angle))
	draw_colored_polygon(points,tint)
func draw_footprints(p: Vector2) -> void:
	var gold:=Color("ffdc72")
	for i in range(2):
		var q:=p+Vector2(-5 if i==0 else 5,-4 if i==0 else 4)
		oval_icon(q,Vector2(3.3,5.2),gold,.4)
		oval_icon(q+Vector2(2,-5.5),Vector2(3,2.7),gold,.4)
func draw_world_icon(p: Vector2) -> void:
	match world_index:
		0:
			draw_circle(p,11,Color("d5e9ff"))
			draw_circle(p+Vector2(4,-4),9,Color("101d3e"))
		1:
			rounded_box(Rect2(p-Vector2(9,6),Vector2(16,15)),Color("f4d6b0"),3,Color("ffecce"))
			draw_arc(p+Vector2(7,0),5,-PI*.5,PI*.5,16,Color("ffe9c7"),2,true)
			draw_line(p+Vector2(-10,12),p+Vector2(10,12),Color("ffe9c7"),2,true)
		2:
			for i in range(5):draw_circle(p+Vector2.from_angle(i*TAU/5)*7,5,Color("f3b1d5"))
			draw_circle(p,4,Color("ffe393"))
		3:
			draw_colored_polygon(PackedVector2Array([p+Vector2(-11,7),p+Vector2(2,-13),p+Vector2(9,7)]),Color("ba8ef1"))
			oval_icon(p+Vector2(0,8),Vector2(14,3),Color("e3c4ff"))
		4:
			draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-5),p+Vector2(0,-13),p+Vector2(9,-5),p+Vector2(0,13)]),Color("7bdff6"))
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-13),p+Vector2(4,-4),p+Vector2(0,13),p+Vector2(-3,-4)]),Color("d0f5ff"))
		5:
			draw_colored_polygon(PackedVector2Array([p+Vector2(-12,-1),p+Vector2(0,-12),p+Vector2(12,-1)]),Color("e8bc76"))
			rounded_box(Rect2(p+Vector2(-8,-1),Vector2(16,13)),Color("ad825c"),2,Color("e8bc76"))
			draw_rect(Rect2(p+Vector2(-2,5),Vector2(4,7)),Color("ffe1a1"))

func center_caption(label: Label, world: bool) -> void:
	var chip:=Rect2(222,74,270,34) if world else Rect2(508,74,188,34)
	var font:=label.get_theme_font("font")
	var fs:=17
	while fs>12 and font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>chip.size.x-52:fs-=1
	label.add_theme_font_size_override("font_size",fs)
	var text_width:=font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x+2
	var group_width:=24+8+text_width
	var start:=chip.get_center().x-group_width*.5
	if world:world_icon_x=start+12
	else:moves_icon_x=start+12
	label.position.x=start+32
	label.set_meta("l10n_x",label.position.x)
	label.size.x=text_width
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	queue_redraw()
