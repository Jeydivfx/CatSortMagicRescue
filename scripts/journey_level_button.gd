extends Button
const L=preload("res://scripts/localization.gd")
var number:=1
var current:=false
var locked:=false
var earned:=0
var hard:=false
var star_texture:Texture2D
func _ready()->void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR;size=Vector2(104,116);mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;disabled=locked
	for state in ["normal","hover","pressed","focus","disabled","hover_pressed"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	var t=AtlasTexture.new();t.atlas=preload("res://assets/branding/result_royal_assets_v1.png");t.region=Rect2(847,96,552,523);star_texture=t
	var label=Label.new();L.style(label);label.text=L.digits(str(number));label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.add_theme_font_size_override("font_size",28 if number<1000 else 24);label.add_theme_color_override("font_color",Color("aab2c6") if locked else Color("fff4dd"));add_child(label);label.position=Vector2(8,20);label.size=Vector2(88,49);label.set_meta("l10n_x",8)
	if current:
		var paw=TextureRect.new();paw.texture=preload("res://assets/icons/pets.png");paw.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;paw.mouse_filter=Control.MOUSE_FILTER_IGNORE;paw.size=Vector2(22,22);var m=ShaderMaterial.new();m.shader=preload("res://scripts/home_icon_tint.gdshader");m.set_shader_parameter("ink",Color("ffe3a2"));paw.material=m;add_child(paw);paw.position=Vector2(41,82);paw.set_meta("l10n_x",41)
func _draw()->void:
	var p=Vector2(52,47);var edge=Color("e2c17f") if current else Color("596f94");var top=Color("4cc5ac") if current else (Color("435275") if locked else Color("4c8ad6"));var bottom=Color("08775b") if current else (Color("242e49") if locked else Color("1e467a"))
	if current:
		for i in range(5,0,-1):draw_circle(p,44+i*2,Color(1,.80,.35,.02))
	draw_circle(p+Vector2(0,4),44,Color("081121"));draw_circle(p,43,edge);draw_circle(p,40,Color("11243a"))
	for row in range(76):
		var y=float(row)-37.5;var width=sqrt(maxf(0,38*38-y*y));var color=top.lerp(bottom,float(row)/76)
		if is_pressed():color=color.darkened(.15)
		draw_line(p+Vector2(-width,y),p+Vector2(width,y),color,1.3)
	draw_arc(p,40,PI*1.08,PI*1.91,40,edge.lightened(.3),1.5,true)
	if current:
		draw_circle(Vector2(52,93),18,Color("e2c17f"));draw_circle(Vector2(52,93),15,Color("102938"))
	elif locked:
		draw_arc(Vector2(52,83),7,PI,TAU,20,Color("a5b0c5"),3,true);var s=StyleBoxFlat.new();s.bg_color=Color("9ba6bd");s.set_corner_radius_all(4);draw_style_box(s,Rect2(40,83,24,21));draw_circle(Vector2(52,91),2.5,Color("1b293d"));draw_line(Vector2(52,92),Vector2(52,97),Color("1b293d"),2,true)
	else:
		for i in range(3):draw_texture_rect(star_texture,Rect2(15+i*25,82,25,25),false,Color.WHITE if i<earned else Color(.22,.26,.35,.85))
	if hard:
		draw_circle(Vector2(87,15),9,Color("795093"));draw_polyline(PackedVector2Array([Vector2(88,9),Vector2(83,15),Vector2(89,15),Vector2(85,21)]),Color("e6cfff"),1.8,true)
	if has_focus():draw_arc(p,46,0,TAU,64,Color("ffe5a5"),2,true)
