extends Control

const L = preload("res://scripts/localization.gd")

signal level_selected(index: int)
signal home_pressed

var challenges: Array = []
var count := 1000
var unlocked_count := 1
var records: Dictionary = {}
var scroll: ScrollContainer
var canvas: Control
var buttons: Dictionary = {}
var content_height := 0.0
var backdrop: Texture2D = preload("res://assets/environments/journey_forest.png")
var heading: Label
var focus_button: Button

func configure(total: int, unlocked: int, saved: Dictionary, hard_levels: Array = []) -> void:
	L.style(self)
	count = total
	unlocked_count = clampi(unlocked, 1, count)
	records = saved
	challenges = hard_levels
	mouse_filter = Control.MOUSE_FILTER_STOP
	heading = Label.new()
	L.style(heading)
	heading.text = L.t("Your journey  •  %d / %d" % [unlocked_count, count])
	heading.add_theme_font_size_override("font_size", 25)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(heading)
	var home = preload("res://scripts/jewel_button.gd").new()
	L.style(home)
	home.set_meta("l10n_x",18)
	home.text = " "
	home.caption_override = " "
	home.symbol = "back"
	home.compact = true
	home.tint = Color("6258c8")
	home.position = Vector2(18, 22)
	home.size = Vector2(58, 58)
	home.add_theme_font_size_override("font_size", 36)
	home.pressed.connect(func(): home_pressed.emit())
	add_child(home)
	scroll = ScrollContainer.new()
	scroll.set_meta("l10n_x",0)
	L.style(scroll)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 12
	add_child(scroll)
	canvas = Control.new()
	canvas.set_meta("l10n_x",0)
	L.style(canvas)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(canvas)
	canvas.draw.connect(draw_path)
	scroll.get_v_scroll_bar().value_changed.connect(func(_value): update_visible();queue_redraw())
	focus_button = preload("res://scripts/jewel_button.gd").new()
	focus_button.tint = Color("6258c8")
	focus_button.title_size = 22
	L.style(focus_button)
	focus_button.text = L.t("Back to level %d" % unlocked_count)
	focus_button.pressed.connect(focus_current)
	add_child(focus_button)
	resized.connect(layout_map)
	L.restyle_tree(self)
	layout_map()
	focus_current.call_deferred()

func layout_map() -> void:
	if not is_instance_valid(scroll): return
	heading.position = Vector2(85, 34)
	heading.size = Vector2(maxf(100, size.x-170), 42)
	heading.position = Vector2(85,34)
	heading.set_meta("l10n_x",85)
	scroll.position = Vector2(0, 106)
	scroll.size = Vector2(size.x, maxf(180, size.y-320))
	content_height = count*132.0+120
	canvas.custom_minimum_size = Vector2(size.x-14, content_height)
	focus_button.position = Vector2(size.x*0.5-160, size.y-194)
	focus_button.size = Vector2(320, 58)
	focus_button.position = Vector2(size.x*0.5-160,size.y-194)
	focus_button.set_meta("l10n_x",size.x*0.5-160)
	for key in buttons: buttons[key].position = point(int(key))-Vector2(44,44)
	update_visible()
	L.restore_x(self)
	queue_redraw()

func point(index: int) -> Vector2:
	return Vector2((size.x-14)*0.5+sin(index*0.78)*minf(140, size.x*0.22), content_height-100-index*132)

func focus_current() -> void:
	scroll.scroll_vertical = int(clampf(point(unlocked_count-1).y-scroll.size.y*0.58, 0, content_height-scroll.size.y))
	update_visible()

func update_visible() -> void:
	if not is_instance_valid(canvas): return
	var first := maxi(0, int(floor((content_height-scroll.scroll_vertical-scroll.size.y-220)/132)))
	var last := mini(count-1, int(ceil((content_height-scroll.scroll_vertical+120)/132)))
	for key in buttons.keys():
		if int(key)<first or int(key)>last:
			buttons[key].queue_free()
			buttons.erase(key)
	for index in range(first,last+1):
		if buttons.has(index): continue
		var button = preload("res://scripts/jewel_button.gd").new()
		button.tint = Color("d4a23b") if index==unlocked_count-1 else Color("4f81c3")
		button.title_size = 29
		if index in challenges:
			button.tint = Color("8d52bf") if index!=unlocked_count-1 else Color("d4a23b")
			button.tooltip_text = L.t("Hard level")
		L.style(button)
		button.text = L.t(str(index+1))
		button.position = point(index)-Vector2(44,44)
		button.size = Vector2(88,88)
		button.disabled = index>=unlocked_count
		button.add_theme_font_size_override("font_size",29)
		button.pressed.connect(func():
			if index<unlocked_count: level_selected.emit(index))
		canvas.add_child(button)
		button.position = point(index)-Vector2(44,44)
		buttons[index] = button
	canvas.queue_redraw()

func draw_path() -> void:
	if buttons.is_empty(): return
	var keys := buttons.keys()
	keys.sort()
	for index in keys:
		var p := point(index)
		if index in challenges:
			canvas.draw_circle(p+Vector2(33,-56),11,Color("bf67e6"))
			canvas.draw_string(get_theme_default_font(),p+Vector2(30,-50),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff4cc"))
		if index<count-1:
			var target := point(index+1)
			for step in range(1,12):
				canvas.draw_circle(p.lerp(target,step/12.0),4,Color("d9b570") if index<unlocked_count-1 else Color("536077"))
		if index>=unlocked_count:
			canvas.draw_rect(Rect2(p+Vector2(-8,49),Vector2(16,13)),Color("9aa2b2"),true)
			canvas.draw_arc(p+Vector2(0,49),6,PI,TAU,12,Color("9aa2b2"),2)
		else:
			var earned := int(records.get(str(index),{}).get("stars",0))
			for star in range(3):
				var center := p+Vector2((star-1)*22,58)
				var vertices := PackedVector2Array()
				for tip in range(10):
					var angle := -PI/2+tip*PI/5
					vertices.append(center+Vector2(cos(angle),sin(angle))*(10 if tip%2==0 else 4.5))
				canvas.draw_colored_polygon(vertices,Color("ffda72") if star<earned else Color("5f687a"))


# Only visible strips are drawn. Overlapping feathered edges keep lanterns upright.
func _draw() -> void:
	if not backdrop or size.x<=0:return
	var tile_height:=size.x*backdrop.get_height()/float(backdrop.get_width())
	var overlap:=tile_height*.08
	var stride:=tile_height-overlap
	var offset:=float(scroll.scroll_vertical) if is_instance_valid(scroll) else 0.0
	var first:=int(floor((offset-106)/stride))-1
	var last:=int(ceil((offset-106+size.y)/stride))
	for index in range(first,last+1):
		var y:=106+index*stride-offset
		if index==first:
			draw_texture_rect(backdrop,Rect2(0,y,size.x,tile_height),false)
		else:
			for band in range(32):
				var t:=band/32.0
				draw_texture_rect_region(backdrop,Rect2(0,y+t*overlap,size.x,overlap/32.0+1),Rect2(0,t*backdrop.get_height()*.08,backdrop.get_width(),backdrop.get_height()*.08/32.0),Color(1,1,1,smoothstep(0.0,1.0,t)))
			draw_texture_rect_region(backdrop,Rect2(0,y+overlap,size.x,tile_height-overlap),Rect2(0,backdrop.get_height()*.08,backdrop.get_width(),backdrop.get_height()*.92))
	draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.025,.06,.24))
	draw_style_box(header_style(),Rect2(8,10,size.x-16,84))

func header_style() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new();style.bg_color=Color(.025,.04,.12,.86)
	style.set_corner_radius_all(24);style.border_color=Color("69739d");style.set_border_width_all(1)
	return style
