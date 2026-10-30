extends RefCounted
const L=preload("res://scripts/localization.gd")
const Avatars=preload("res://scripts/player_avatars.gd")
static func show(g,preview:bool=false,editing:bool=false)->void:
	if g.has_node("PlayerNameOverlay"):return
	preview=preview or "--preview-player-name" in OS.get_cmdline_user_args()
	var layer=Control.new();layer.name="PlayerNameOverlay";layer.layout_direction=Control.LAYOUT_DIRECTION_LTR;layer.z_index=100;g.add_child(layer)
	var bg=TextureRect.new();bg.texture=load("res://assets/environments/menu_moonlit_valley.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;layer.add_child(bg)
	var shade=ColorRect.new();shade.color=Color(.01,.02,.09,.34);layer.add_child(shade)
	var body=Control.new();body.name="NameCardContent";body.layout_direction=Control.LAYOUT_DIRECTION_LTR;layer.add_child(body)
	var card=Panel.new();card.name="NameCard";card.size=Vector2(600,800);card.add_theme_stylebox_override("panel",g.panel(Color(.025,.065,.14,.97),30,Color("86a8dc")));body.add_child(card);card.position=Vector2(60,145)
	var back=preload("res://scripts/jewel_button.gd").new();back.name="PreviewNameBack";back.symbol="back";back.compact=true;back.tint=Color("7951b1");back.size=Vector2(60,58);body.add_child(back);back.position=Vector2(78,163);back.pressed.connect(func():layer.queue_free())
	text(body,"Welcome, little wizard!",Rect2(98,223,524,56),34,true)
	text(body,"Choose your player name and your cat",Rect2(100,278,520,40),20,true,Color("aac4e8"))
	var decoration=Control.new();decoration.layout_direction=Control.LAYOUT_DIRECTION_LTR;decoration.size=Vector2(720,1120);decoration.mouse_filter=Control.MOUSE_FILTER_IGNORE;body.add_child(decoration);decoration.position=Vector2.ZERO
	decoration.draw.connect(func():
		for y in [336,490]:
			decoration.draw_line(Vector2(105,y),Vector2(341,y),Color("6589bd"),1.3,true);decoration.draw_line(Vector2(379,y),Vector2(615,y),Color("6589bd"),1.3,true)
			decoration.draw_colored_polygon(PackedVector2Array([Vector2(360,y-8),Vector2(368,y),Vector2(360,y+8),Vector2(352,y)]),Color("b5d8ff"))
		var gold=Color("ffe0a2");decoration.draw_circle(Vector2(125,377),7,gold);decoration.draw_style_box(g.panel(gold,6,gold),Rect2(113,386,24,12))
		for p in [Vector2(114,523),Vector2(123,517),Vector2(133,519),Vector2(140,526)]:decoration.draw_circle(p,4,gold)
		decoration.draw_circle(Vector2(127,532),8,gold))
	text(body,"Player name",Rect2(160,359,420,40),23)
	var edit=LineEdit.new();edit.name="PlayerNameInput";L.style(edit);edit.max_length=20;edit.placeholder_text=L.t("Your name");edit.size=Vector2(504,55);edit.add_theme_font_size_override("font_size",23);edit.alignment=HORIZONTAL_ALIGNMENT_RIGHT if L.rtl() else HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal","focus"]:
		var input_skin=g.panel(Color("10294a"),14,Color("81a8dd") if state=="normal" else Color("ffd784"));input_skin.content_margin_left=18;input_skin.content_margin_right=18;edit.add_theme_stylebox_override(state,input_skin)
	body.add_child(edit);edit.position=Vector2(108,416)
	if editing:edit.text=g.leaderboard.player_name
	text(body,"Choose your cat",Rect2(160,508,420,40),23)
	var selection={"id":Avatars.valid(g.leaderboard.avatar_id)};var choices:Array=[]
	for i in range(8):
		var b=preload("res://scripts/avatar_choice.gd").new();b.name="Avatar_"+Avatars.IDS[i];b.portrait=Avatars.texture(Avatars.IDS[i]);b.selected=selection.id==Avatars.IDS[i];b.size=Vector2(116,116);b.tooltip_text=Avatars.IDS[i];body.add_child(b);b.position=Vector2(108+(i%4)*129,558+(i/4)*130);choices.append(b)
		b.pressed.connect(func():
			selection.id=Avatars.IDS[i]
			for j in range(8):choices[j].selected=Avatars.IDS[j]==selection.id)
	var feedback=text(body,"",Rect2(108,813,504,26),17,true,Color("ffcfac"));feedback.name="NameFeedback"
	var start=preload("res://scripts/jewel_button.gd").new();start.name="StartAdventure";start.tint=Color("3d9b70");start.symbol="paw";start.title_size=26;start.text=L.t("Start Adventure");body.add_child(start);start.position=Vector2(145,849);start.size=Vector2(430,70)
	if editing:start.text=L.t("Save changes")
	start.pressed.connect(func():
		var value=edit.text.strip_edges()
		if value.length()<2:feedback.text=L.t("Please enter at least 2 characters.");return
		if preview:feedback.text=L.t("Preview — your account stays unchanged");return
		g.leaderboard.choose_name(value,selection.id);layer.queue_free())
	edit.text_submitted.connect(func(_v):start.pressed.emit())
	var layout=func():
		var safe:Rect2=g.content_rect();var factor=minf(1.05,minf((safe.size.x-32)/600.0,(safe.size.y-32)/800.0));body.scale=Vector2.ONE*factor;body.position=safe.get_center()-Vector2(360,545)*factor
		layer.size=g.get_viewport_rect().size;bg.size=layer.size;shade.size=layer.size;bg.position=-g.position;shade.position=-g.position
	layout.call();layer.get_viewport().size_changed.connect(layout)
	layer.tree_exiting.connect(func():
		if layer.get_viewport().size_changed.is_connected(layout):layer.get_viewport().size_changed.disconnect(layout))
static func text(parent:Control,value:String,rect:Rect2,font:int,center:bool=false,color:Color=Color("fff6ed"))->Label:
	var l=Label.new();L.style(l);l.text=L.t(value);l.size=rect.size;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if center else (HORIZONTAL_ALIGNMENT_RIGHT if L.rtl() else HORIZONTAL_ALIGNMENT_LEFT);l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.add_theme_font_size_override("font_size",font);l.add_theme_color_override("font_color",color);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(l);l.position=rect.position;return l
