extends Button
const L=preload("res://scripts/localization.gd")
var music:=false
var enabled:=true
var switch_only:=false
func _ready() -> void:
	for state in ["normal","hover","pressed","focus"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	if switch_only:return
	var title=Label.new();L.style(title);title.text=L.t("Music" if music else "Effects");title.add_theme_font_size_override("font_size",21);title.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(title);title.position=Vector2(78,14);title.size=Vector2(130,30)
func _draw() -> void:
	if switch_only:
		var pill=StyleBoxFlat.new();pill.bg_color=Color("4eaa80") if enabled else Color("536079");pill.set_corner_radius_all(19);draw_style_box(pill,Rect2(Vector2.ZERO,size))
		draw_circle(Vector2(size.x-20 if enabled else 20,size.y*.5),15,Color("fffaf0"))
		draw_string(get_theme_font("font"),Vector2(18 if enabled else 44,size.y*.5+7),"ON" if enabled else "OFF",HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("fffaf0"))
		return
	var card=StyleBoxFlat.new();card.bg_color=Color("1b3354");card.border_color=Color("627fac");card.set_border_width_all(2);card.set_corner_radius_all(18);draw_style_box(card,Rect2(Vector2.ZERO,size))
	var ink=Color("ffe7ba");var p=Vector2(39,48)
	if music:
		draw_line(p+Vector2(-3,-15),p+Vector2(-3,13),ink,3,true);draw_line(p+Vector2(14,-20),p+Vector2(14,8),ink,3,true);draw_line(p+Vector2(-3,-15),p+Vector2(14,-20),ink,5,true)
		draw_set_transform(p+Vector2(-8,13),-.25,Vector2(1,.75));draw_circle(Vector2.ZERO,7,ink);draw_set_transform(p+Vector2(9,8),-.25,Vector2(1,.75));draw_circle(Vector2.ZERO,7,ink);draw_set_transform(Vector2.ZERO)
	else:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-17,-6),p+Vector2(-10,-6),p+Vector2(0,-15),p+Vector2(0,15),p+Vector2(-10,6),p+Vector2(-17,6)]),ink)
		for r in [10,17]:draw_arc(p+Vector2(1,0),r,-.8,.8,24,ink,2.5,true)
	var pill=StyleBoxFlat.new();pill.bg_color=Color("4eaa80") if enabled else Color("536079");pill.set_corner_radius_all(16);draw_style_box(pill,Rect2(79,53,112,34))
	draw_circle(Vector2(173 if enabled else 97,70),13,Color("fffaf0"))
	draw_string(get_theme_font("font"),Vector2(94 if enabled else 119,77),"ON" if enabled else "OFF",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fffaf0"))
