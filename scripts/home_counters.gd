extends Control
const L=preload("res://scripts/localization.gd")
var points:=0
var coins:=0
var currency_art:Texture2D
var score_art:Texture2D
func _ready()->void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR;mouse_filter=Control.MOUSE_FILTER_IGNORE;size=Vector2(346,48)
	var source=preload("res://assets/branding/result_royal_assets_v1.png")
	var coin_tile=AtlasTexture.new();coin_tile.atlas=source;coin_tile.region=Rect2(1572,105,525,527);currency_art=coin_tile
	var star_tile=AtlasTexture.new();star_tile.atlas=source;star_tile.region=Rect2(847,96,552,523);score_art=star_tile
	for i in range(2):
		var label=Label.new();L.style(label);label.text=L.digits(str(points if i==0 else coins));label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.size=Vector2(107,46);label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.add_theme_color_override("font_color",Color("ffe6a3"));var font=label.get_theme_font("font");var fs=23
		while fs>15 and font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>103:fs-=1
		label.add_theme_font_size_override("font_size",fs);add_child(label);label.position=Vector2(36+i*153,1)
	var plus=Button.new();plus.tooltip_text=L.t("Coins");plus.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;plus.size=Vector2(36,36)
	plus.draw.connect(func():
		var center=plus.size*.5;plus.draw_line(center-Vector2(8,0),center+Vector2(8,0),Color("fff4d5"),3,true);plus.draw_line(center-Vector2(0,8),center+Vector2(0,8),Color("fff4d5"),3,true))
	for state in ["normal","hover","pressed","focus"]:
		var s=StyleBoxFlat.new();s.bg_color=Color("bd893c") if state!="pressed" else Color("835520");s.border_color=Color("ffdf91");s.set_border_width_all(2);s.set_corner_radius_all(18);plus.add_theme_stylebox_override(state,s)
	add_child(plus);plus.position=Vector2(305,6)
	plus.pressed.connect(func():
		var existing=get_node_or_null("CoinInfo")
		if existing:existing.queue_free();return
		var panel=Panel.new();panel.name="CoinInfo";panel.size=Vector2(310,96);panel.z_index=30;var s=StyleBoxFlat.new();s.bg_color=Color("10233c");s.border_color=Color("c5ae7c");s.set_border_width_all(1);s.set_corner_radius_all(16);panel.add_theme_stylebox_override("panel",s);add_child(panel);panel.position=Vector2(36,58)
		var label=Label.new();L.style(label);label.text=L.t("Complete levels to earn coins.");label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",18);label.size=Vector2(286,72);panel.add_child(label);label.position=Vector2(12,12))
func _draw()->void:
	var skin=StyleBoxFlat.new();skin.bg_color=Color(.025,.045,.12,.95);skin.border_color=Color("b7a88c");skin.set_border_width_all(1);skin.set_corner_radius_all(22);skin.shadow_color=Color(0,0,0,.24);skin.shadow_size=4;draw_style_box(skin,Rect2(Vector2.ZERO,size))
	draw_line(Vector2(153,10),Vector2(153,38),Color("4b587b"),1,true)
	if score_art:draw_texture_rect(score_art,Rect2(8,9,30,30),false)
	if currency_art:draw_texture_rect(currency_art,Rect2(162,9,30,30),false)
