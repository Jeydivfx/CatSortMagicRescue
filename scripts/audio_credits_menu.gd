extends RefCounted
const L=preload("res://scripts/localization.gd")
const Design=preload("res://scripts/settings_menu.gd")
const MUSIC="https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100626"
const LICENSE="https://creativecommons.org/licenses/by/4.0/"
const EFFECTS="https://kenney.nl/assets/interface-sounds"
const FILM="https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100232"
static func build(g)->void:
	var p=Design.plate(g,Rect2(60,150,600,770),"0b1730","9297aa",30);p.name="CreditsPanel"
	var back=g.button_at("",Rect2(76,165,60,60),func():g.show_menu("settings"),Color("7951b1"));back.symbol="back";back.compact=true;back.name="CreditsBack"
	Design.label(g,"Audio credits",Rect2(155,170,430,56),35,"fff0cd",true)
	var decor=Control.new();decor.layout_direction=Control.LAYOUT_DIRECTION_LTR;decor.size=Vector2(720,1120);decor.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(decor);decor.position=Vector2.ZERO;decor.set_meta("l10n_x",0)
	decor.draw.connect(func():
		for y in [242,496,725]:
			for i in range(50):
				var fade=float(i)/50
				decor.draw_line(Vector2(88+i*5,y),Vector2(93+i*5,y),Color(.93,.81,.60,fade*.75),1,true)
				decor.draw_line(Vector2(632-i*5,y),Vector2(627-i*5,y),Color(.93,.81,.60,fade*.75),1,true)
			var star=PackedVector2Array([Vector2(360,y-9),Vector2(365,y-3),Vector2(369,y),Vector2(365,y+3),Vector2(360,y+9),Vector2(355,y+3),Vector2(351,y),Vector2(355,y-3)]);decor.draw_colored_polygon(star,Color("ffd480"))
		for i in range(3):
			var pos=Vector2(96,[275,531,757][i]);var skin=StyleBoxFlat.new();skin.bg_color=Color("a36a21");skin.border_color=Color("ffd788");skin.set_border_width_all(2);skin.set_corner_radius_all(15);skin.shadow_color=Color(0,0,0,.4);skin.shadow_size=3;decor.draw_style_box(skin,Rect2(pos,Vector2(64,64)))
			var c=Color("fff3d0");var center=pos+Vector2(32,32)
			if i==0:
				decor.draw_line(center+Vector2(-4,-12),center+Vector2(-4,13),c,4,true);decor.draw_line(center+Vector2(13,-17),center+Vector2(13,8),c,4,true);decor.draw_line(center+Vector2(-4,-12),center+Vector2(13,-17),c,6,true);decor.draw_circle(center+Vector2(-10,13),6,c);decor.draw_circle(center+Vector2(7,8),6,c)
			elif i==1:
				decor.draw_colored_polygon(PackedVector2Array([center+Vector2(-18,-7),center+Vector2(-10,-7),center+Vector2(0,-16),center+Vector2(0,16),center+Vector2(-10,7),center+Vector2(-18,7)]),c)
				for r in [10,18]:decor.draw_arc(center,r,-.8,.8,24,c,2.4,true)
			else:
				decor.draw_style_box(g.panel(c,3,c),Rect2(center+Vector2(-18,-6),Vector2(36,25)))
				decor.draw_colored_polygon(PackedVector2Array([center+Vector2(-2,-1),center+Vector2(9,6),center+Vector2(-2,13)]),Color("9b6420"))
				decor.draw_line(center+Vector2(-19,-16),center+Vector2(18,-20),c,7,true)
				for x in [-11,2,14]:decor.draw_line(center+Vector2(x-5,-20),center+Vector2(x+1,-14),Color("9b6420"),3,true))
	credit_text(g,"Music: Clear Air",Rect2(182,269,440,36),24,true)
	credit_text(g,"Kevin MacLeod (incompetech.com)\nCreative Commons Attribution 4.0",Rect2(182,309,440,62),20)
	var note=Design.label(g,"Converted to Ogg Vorbis; loudness normalized.",Rect2(182,373,440,30),16,"adc5e9");note.text_direction=Control.TEXT_DIRECTION_AUTO
	link(g,"Music source",Rect2(90,411,258,56),MUSIC)
	link(g,"CC BY 4.0 license",Rect2(372,411,258,56),LICENSE,true)
	credit_text(g,"Effects: Kenney Interface Sounds (CC0)",Rect2(182,527,445,42),20,true)
	credit_text(g,"Cat recordings: Joseph SARDIN,\nKerzoven and IgnasD (CC0)",Rect2(182,574,440,60),20)
	link(g,"Kenney sound pack",Rect2(90,652,540,56),EFFECTS)
	var film=LinkButton.new();L.style(film);film.text="Story film: Fairytale Waltz";film.uri=FILM;film.underline=LinkButton.UNDERLINE_MODE_ON_HOVER;film.add_theme_font_size_override("font_size",23);film.add_theme_color_override("font_color",Color("fff0cd"));film.text_direction=Control.TEXT_DIRECTION_AUTO;g.ui.add_child(film);film.position=Vector2(182,754);film.size=Vector2(440,38);film.set_meta("l10n_x",182)
	credit_text(g,"Kevin MacLeod (incompetech.com) — CC BY 4.0",Rect2(182,799,440,32),17)
	Design.label(g,"Edited excerpt, fades and sound mix.",Rect2(182,835,440,30),18,"adc5e9")
static func credit_text(g,value:String,rect:Rect2,font:int,heading:bool=false)->void:
	var l=Design.label(g,value,rect,font,"fff0cd" if heading else "adc5e9");l.text_direction=Control.TEXT_DIRECTION_AUTO;l.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
static func link(g,value:String,rect:Rect2,url:String,license:bool=false)->void:
	var b=LinkButton.new();L.style(b);b.text="";b.uri=url;b.underline=LinkButton.UNDERLINE_MODE_NEVER;b.add_theme_font_size_override("font_size",17);b.add_theme_color_override("font_color",Color("f6f5ff"));b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","focus"]:
		var skin=g.panel(Color("253e64") if state=="hover" else Color("1a3053"),16,Color("5e7eaf"));skin.content_margin_left=46;skin.content_margin_right=37;skin.content_margin_top=16;skin.content_margin_bottom=16;b.add_theme_stylebox_override(state,skin)
	g.ui.add_child(b);b.position=rect.position;b.size=rect.size;b.set_meta("l10n_x",rect.position.x)
	var backing=Panel.new();backing.layout_direction=Control.LAYOUT_DIRECTION_LTR;backing.size=rect.size;backing.mouse_filter=Control.MOUSE_FILTER_IGNORE;backing.add_theme_stylebox_override("panel",g.panel(Color("1a3053"),16,Color("5e7eaf")));b.add_child(backing);backing.position=Vector2.ZERO;backing.set_meta("l10n_x",0)
	b.mouse_entered.connect(func():backing.modulate=Color(1.15,1.15,1.15))
	b.mouse_exited.connect(func():backing.modulate=Color.WHITE)
	var caption=Label.new();L.style(caption);caption.text=L.t(value);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;caption.add_theme_font_size_override("font_size",17);caption.mouse_filter=Control.MOUSE_FILTER_IGNORE;caption.size=Vector2(rect.size.x-83,rect.size.y);b.add_child(caption);caption.position=Vector2(46,0);caption.set_meta("l10n_x",46)
	var icons=Control.new();icons.layout_direction=Control.LAYOUT_DIRECTION_LTR;icons.size=rect.size;icons.mouse_filter=Control.MOUSE_FILTER_IGNORE;b.add_child(icons);icons.position=Vector2.ZERO;icons.set_meta("l10n_x",0)
	icons.draw.connect(func():
		var c=Color("f6f3ff");var p=Vector2(28,28)
		if license:
			icons.draw_arc(p,13,0,TAU,40,c,2,true)
			for x in [-4,5]:icons.draw_arc(p+Vector2(x,0),4,.6,TAU-.6,20,c,2,true)
		else:
			for d in [-1,1]:
				var center=p+Vector2(d*5,-d*5);icons.draw_arc(center,8,-.75,PI*1.65,24,c,2.5,true)
			icons.draw_line(p+Vector2(-5,6),p+Vector2(5,-6),c,2.5,true)
		var e=Vector2(rect.size.x-26,28)
		icons.draw_polyline(PackedVector2Array([e+Vector2(1,-7),e+Vector2(-7,-7),e+Vector2(-7,8),e+Vector2(8,8),e+Vector2(8,1)]),c,2,true)
		icons.draw_line(e+Vector2(-1,1),e+Vector2(10,-10),c,2,true);icons.draw_polyline(PackedVector2Array([e+Vector2(3,-10),e+Vector2(10,-10),e+Vector2(10,-3)]),c,2,true))
