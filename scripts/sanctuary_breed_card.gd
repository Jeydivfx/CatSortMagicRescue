extends Control
const L=preload("res://scripts/localization.gd")
var kind:=0
var count:=0
var game
var actor:Node2D
var cushion:Texture2D
var age:=0.0
func _ready()->void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR;size=Vector2(180,198);mouse_filter=Control.MOUSE_FILTER_IGNORE
	var texture=AtlasTexture.new();texture.atlas=preload("res://assets/branding/result_royal_assets_v1.png");texture.region=Rect2(40,242,738,323);cushion=texture
	actor=preload("res://scripts/cat_actor.gd").new();add_child(actor);actor.setup(null,kind,kind*.91)
	actor.menu_ears_enabled=true;actor.set_meta("home_origin",Vector2(90,87));actor.set_meta("home_scale",1.3);actor.animate_menu(0,Vector2(90,87),1.3,game.reduced_motion)
	if count==0:actor.modulate=Color(.015,.035,.06,1)
	var caption=Label.new();L.style(caption);caption.text=L.digits("×"+str(count)) if count>0 else L.t("Not rescued yet");caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;caption.mouse_filter=Control.MOUSE_FILTER_IGNORE;caption.add_theme_font_size_override("font_size",20 if count>0 else 14);caption.add_theme_color_override("font_color",Color("ffe7aa") if count>0 else Color("b8c6d6"));add_child(caption);caption.position=Vector2(19,164);caption.size=Vector2(142,27);caption.set_meta("l10n_x",19)
	if count==0:
		var lock=Control.new();lock.size=size;lock.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(lock);lock.position=Vector2.ZERO;lock.set_meta("l10n_x",0)
		lock.draw.connect(func():
			lock.draw_arc(Vector2(90,111),9,PI,TAU,28,Color("ffe6a0"),4,true)
			var box=StyleBoxFlat.new();box.bg_color=Color("e5ad44");box.border_color=Color("fff0bd");box.set_border_width_all(1);box.set_corner_radius_all(5);lock.draw_style_box(box,Rect2(75,111,30,26));lock.draw_circle(Vector2(90,121),3,Color("60431e"));lock.draw_line(Vector2(90,122),Vector2(90,128),Color("60431e"),3,true))
func _process(delta:float)->void:
	if count<=0:return
	age+=delta;actor.animate_menu(age,actor.get_meta("home_origin"),1.3,game.reduced_motion);actor.animate_sleep(game.clock,game.clock-game.cat_last_activity,true,game.reduced_motion)
func _draw()->void:
	var skin=StyleBoxFlat.new();skin.bg_color=Color(.035,.075,.13,.97);skin.border_color=Color("c5a66a") if count>0 else Color("64717a");skin.set_border_width_all(2);skin.set_corner_radius_all(23);skin.shadow_color=Color(0,0,0,.24);skin.shadow_size=5;draw_style_box(skin,Rect2(Vector2.ZERO,size))
	if cushion:draw_texture_rect(cushion,Rect2(14,129,152,33),false,Color.WHITE if count>0 else Color(.35,.45,.55))
	var badge=StyleBoxFlat.new();badge.bg_color=Color("0c2335");badge.border_color=Color("d6b779") if count>0 else Color("354c63");badge.set_border_width_all(1);badge.set_corner_radius_all(13);draw_style_box(badge,Rect2(18,163,144,29))
