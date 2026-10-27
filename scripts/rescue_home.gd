extends Control
const L=preload("res://scripts/localization.gd")
var game
var completed:=0
var rescued:=0
var content: Control
var residents: Array=[]
var scenery: Node2D
var age:=0.0
var milestone_bar: ProgressBar
func configure(g) -> void:
	game=g
	completed=mini(g.levels.size(),maxi(g.unlocked-1,g.wallet.records.size()))
	for i in range(completed):rescued+=int(g.levels[i].get("colors",2))*4
	var bg:=TextureRect.new();bg.texture=load("res://assets/environments/cottage.png")
	bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
	var shade:=ColorRect.new();shade.color=Color(.025,.045,.075,.30);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
	content=Control.new();content.layout_direction=Control.LAYOUT_DIRECTION_LTR;add_child(content)
	var back=preload("res://scripts/jewel_button.gd").new()
	L.style(back);back.set_meta("l10n_x",22.0)
	back.text=" ";back.caption_override=" ";back.symbol="back";back.compact=true;back.tint=Color("6258c8")
	back.position=Vector2(22,24);back.size=Vector2(58,58)
	back.pressed.connect(func():game.show_menu());content.add_child(back)
	label("Cat sanctuary",Rect2(98,24,490,58),32,Color("ffe6a0"))
	label("Safe, at last.",Rect2(65,90,550,38),21,Color("fff1d3"))
	var count_panel:=Panel.new();count_panel.position=Vector2(120,154);count_panel.size=Vector2(440,64)
	count_panel.add_theme_stylebox_override("panel",game.panel(Color(.04,.09,.15,.84),28,Color("a99573")));content.add_child(count_panel)
	label("%d kittens rescued"%rescued,Rect2(130,161,420,48),24,Color("ffe7a1"))
	scenery=Node2D.new();content.add_child(scenery);scenery.draw.connect(draw_room)
	var available: Array=[]
	for i in range(completed):
		for tube in game.levels[i].tubes:
			for kind in tube:
				if not available.has(int(kind)):available.append(int(kind))
	var spots: Array=[Vector2(340,620),Vector2(153,617),Vector2(523,619),Vector2(480,416),Vector2(190,425)]
	for i in range(mini(5,available.size())):
		var cat=preload("res://scripts/cat_actor.gd").new();content.add_child(cat);cat.setup(null,available[i],i*.91)
		cat.menu_ears_enabled=true;cat.set_meta("home_origin",spots[i]);cat.set_meta("home_scale",1.50 if i<3 else 1.10);residents.append(cat)
	if residents.is_empty():label("A cozy place for every rescue.",Rect2(80,475,520,70),23,Color("fff0d4"))
	var card:=Panel.new();card.position=Vector2(55,735);card.size=Vector2(570,112)
	card.add_theme_stylebox_override("panel",game.panel(Color(.04,.09,.15,.90),24,Color("a99573")));content.add_child(card)
	label("A new comfort in %d levels"%[10-completed%10] if completed<g.levels.size() else "Every kitten deserves a home.",Rect2(73,747,534,44),22,Color("ffedbe"))
	milestone_bar=ProgressBar.new();milestone_bar.position=Vector2(89,808);milestone_bar.size=Vector2(502,14)
	milestone_bar.max_value=10;milestone_bar.value=completed%10 if completed<g.levels.size() else 10;milestone_bar.show_percentage=false
	milestone_bar.add_theme_stylebox_override("background",game.panel(Color("263747"),7,Color("74889a")))
	milestone_bar.add_theme_stylebox_override("fill",game.panel(Color("eac76c"),7,Color("ffeab0")));content.add_child(milestone_bar)
	var play=button("Continue rescuing",Rect2(105,887,470,72),func():game.start_game(game.unlocked-1,true))
	play.add_theme_stylebox_override("normal",game.panel(Color("43835c"),28,Color("d6ec9d")));play.add_theme_font_size_override("font_size",26)
	count_panel.set_meta("l10n_x",120.0);card.set_meta("l10n_x",55.0);milestone_bar.set_meta("l10n_x",89.0)
	layout_home();get_viewport().size_changed.connect(layout_home)
func label(text: String,rect: Rect2,font_size: int,color: Color) -> Label:
	var node:=Label.new();L.style(node);node.text=L.t(text);node.position=rect.position;node.size=rect.size
	node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;node.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	node.add_theme_color_override("font_color",color)
	var font=node.get_theme_font("font")
	while font_size>16 and font.get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x-12:font_size-=1
	node.add_theme_font_size_override("font_size",font_size);content.add_child(node);return node
func button(text: String,rect: Rect2,action: Callable) -> Button:
	var node:=Button.new();L.style(node);node.text=L.t(text);node.position=rect.position;node.size=rect.size
	node.add_theme_stylebox_override("normal",game.panel(Color("354b68"),20,Color("a6b6cf")))
	node.add_theme_stylebox_override("hover",game.panel(Color("527a75"),20,Color("ffe4a0")))
	node.add_theme_stylebox_override("pressed",game.panel(Color("29463e"),20,Color("d6ec9d")))
	node.set_meta("l10n_x",rect.position.x);node.pressed.connect(action);content.add_child(node);return node
func layout_home() -> void:
	if not is_instance_valid(game):return
	size=get_viewport_rect().size;position=-game.position
	var safe: Rect2=game.content_rect()
	var s:=minf((size.x-24)/680.0,(safe.size.y-24)/980.0)
	content.scale=Vector2.ONE*s;content.position=Vector2((size.x-680*s)*.5,safe.position.y+game.position.y+(safe.size.y-980*s)*.5)
func _process(delta: float) -> void:
	if not is_instance_valid(game) or game.screen!="rescue_home":return
	L.restore_x(content)
	age+=delta
	for cat in residents:cat.animate_menu(age,cat.get_meta("home_origin"),cat.get_meta("home_scale"),game.reduced_motion)
	scenery.queue_redraw()
func draw_room() -> void:
	scenery.draw_style_box(game.panel(Color(.11,.15,.14,.60),38,Color("a39272")),Rect2(58,567,564,118))
	scenery.draw_style_box(game.panel(Color.from_hsv(.78+float(completed/10%6)*.018,.18,.46),36,Color("c0a5a0")),Rect2(74,649,532,28))
	if residents.size()>3:scenery.draw_style_box(game.panel(Color("654939"),10,Color("c29a6a")),Rect2(117,456,432,19))
	if completed>=10:scenery.draw_style_box(game.panel(Color("a889a2"),30,Color("e2c5bb")),Rect2(92,645,127,26))
	if completed>=20:
		var p:=Vector2(560,670)
		scenery.draw_circle(p,17,Color("e7b270"));scenery.draw_arc(p,12,-1,2.4,24,Color("ffe0b0"),2,true)
		scenery.draw_polyline(PackedVector2Array([p+Vector2(14,6),Vector2(591,686),Vector2(612,680)]),Color("e7b270"),2,true)
	if completed>=40:
		for x in [70,610]:
			scenery.draw_line(Vector2(x,270),Vector2(x,305),Color("cdb282"),2,true)
			scenery.draw_circle(Vector2(x,328),37,Color(1,.73,.25,.08+.025*sin(age*1.3)))
			scenery.draw_style_box(game.panel(Color("a47940"),9,Color("e4bd6b")),Rect2(x-12,306,24,43))
			scenery.draw_circle(Vector2(x,328),7,Color("ffecac"))
