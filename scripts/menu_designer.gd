extends RefCounted

const L = preload("res://scripts/localization.gd")

static func card(g: Node, rect: Rect2, color: Color, border: Color) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	p.set_meta("l10n_x",rect.position.x)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = g.panel(color,26,border)
	style.shadow_color = Color(0,0,0,.2)
	style.shadow_size = 8
	p.add_theme_stylebox_override("panel",style)
	g.ui.add_child(p)
	return p

static func text(g: Node, value: String, position: Vector2, size: Vector2, font: int, color: Color) -> Label:
	var label: Label = g.label_at(value,position,font,color)
	label.size = size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

static func home(g: Node) -> void:
	var decor = preload("res://scripts/menu_decoration.gd").new()
	decor.name = "HomeDecoration"
	decor.set_meta("l10n_x",0)
	decor.size = Vector2(720,1120)
	decor.completed = g.unlocked-1
	decor.total = g.levels.size()
	decor.gentle = g.reduced_motion
	g.ui.add_child(decor)
	var coins:=text(g,str(g.wallet.coins),Vector2(102,37),Vector2(154,42),30,Color("fff0bd"))
	coins.name="HomeCoins"
	var settings: Button = g.button_at("",Rect2(604,36,76,76),func(): g.show_menu("settings"),Color("47458a"))
	settings.symbol = "settings"
	settings.compact = true
	settings.tooltip_text = L.t("Settings")
	settings.name = "HomeSettings"
	var logo := TextureRect.new()
	logo.name = "HomeLogo"
	logo.set_meta("l10n_x",62)
	logo.texture = load("res://assets/branding/magic_rescue_logo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.position = Vector2(62,146)
	logo.size = Vector2(596,250)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.ui.add_child(logo)
	for i in range(3):
		var actor = preload("res://scripts/cat_actor.gd").new()
		actor.setup(g.cat_atlas,i,i*1.2)
		actor.menu_ears_enabled=i!=1
		actor.position = Vector2(202+i*158,519 if i!=1 else 497)
		actor.set_meta("menu_scale",2.0 if i!=1 else 2.5)
		actor.set_meta("menu_base_origin",actor.position)
		actor.set_meta("menu_origin",actor.position)
		g.menu_cats.add_child(actor)
		actor.animate_menu(g.clock,actor.position,float(actor.get_meta("menu_scale")),g.reduced_motion)
	var play = g.button_at("Play",Rect2(114,650,492,144),func(): g.start_game(g.unlocked-1,true),Color("41bf2e"))
	play.name = "HomePlay"
	play.menu_hero = true
	play.symbol = "paw"
	play.subtitle = L.t("Level %d" % g.unlocked)
	play.title_size = 56
	var levels = g.button_at("Levels",Rect2(124,817,472,96),func(): g.show_menu("levels"),Color("6258c8"))
	levels.name = "HomeLevels"
	levels.menu_hero = true
	levels.symbol = "levels"
	levels.title_size = 40
	var journey:=text(g,"Rescue home",Vector2(155,976),Vector2(410,28),20,Color("fff4da"))
	journey.name="HomeJourneyTitle"
	var count:=text(g,"%d / %d levels complete" % [g.unlocked-1,g.levels.size()],Vector2(150,1037),Vector2(420,28),20,Color("dae1ff"))
	count.name="HomeJourneyCount"
	var home_link:=Button.new()
	home_link.name="HomeRescueLink";home_link.flat=true;home_link.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	home_link.tooltip_text=L.t("Rescue home");home_link.pressed.connect(func():g.show_menu("rescue_home"))
	g.ui.add_child(home_link)
	preload("res://scripts/responsive_layout.gd").home(g)
	g.menu_ui.modulate.a = 0
	g.menu_cats.modulate.a = 0
	g.menu_intro = g.create_tween().set_parallel(true)
	g.menu_intro.tween_property(g.menu_ui,"modulate:a",1.0,.4).set_trans(Tween.TRANS_SINE)
	g.menu_intro.tween_property(g.menu_cats,"modulate:a",1.0,.55).set_trans(Tween.TRANS_SINE)

static func section(g: Node, value: String, y: float) -> void:
	var label: Label = g.label_at(value,Vector2(132,y),17,Color("dfcba7"))
	label.size = Vector2(456,28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if L.rtl() else HORIZONTAL_ALIGNMENT_LEFT

static func slider(g: Node, position: Vector2, value: float, callback: Callable, description: String) -> void:
	var s := HSlider.new()
	L.style(s)
	s.set_meta("l10n_x",position.x)
	s.position = position
	s.size = Vector2(245,28)
	s.min_value = 0
	s.max_value = 1
	s.step = .05
	s.value = value
	s.tooltip_text = L.t(description)
	s.value_changed.connect(callback)
	for state in ["slider","grabber_area","grabber_area_highlight"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("d4b875") if state!="slider" else Color("344b5e")
		style.set_corner_radius_all(5)
		style.content_margin_top = 5
		style.content_margin_bottom = 5
		s.add_theme_stylebox_override(state,style)
	g.ui.add_child(s)

static func settings(g: Node) -> void:
	g.centered_text("Settings",173,43,Color("ffe2a0"))
	g.centered_text("Make this little world yours",237,18,Color("afc9d3"))
	section(g,"SOUND",302)
	var effects: Button = g.button_at("Effects  "+("ON" if g.sound_enabled else "OFF"),Rect2(132,345,180,54),func():
		g.sound_enabled = not g.sound_enabled
		g.audio.set_enabled(g.sound_enabled)
		g.save_progress()
		g.show_menu("settings"),Color("477d96"))
	effects.add_theme_font_size_override("font_size",20)
	slider(g,Vector2(342,358),g.effects_volume,func(value):
		g.effects_volume = value
		g.audio.set_levels(g.music_volume,g.effects_volume)
		g.save_progress(),"Effects volume")
	var music: Button = g.button_at("Music  "+("ON" if g.music_enabled else "OFF"),Rect2(132,427,180,54),func():
		g.music_enabled = not g.music_enabled
		g.audio.set_music_enabled(g.music_enabled)
		g.save_progress()
		g.show_menu("settings"),Color("4f8275"))
	music.add_theme_font_size_override("font_size",20)
	slider(g,Vector2(342,440),g.music_volume,func(value):
		g.music_volume = value
		g.audio.set_levels(g.music_volume,g.effects_volume)
		g.save_progress(),"Music volume")
	section(g,"ANIMATION",534)
	g.button_at("Gentle motion" if g.reduced_motion else "Full animation",Rect2(132,577,456,60),func():
		g.reduced_motion = not g.reduced_motion
		g.save_progress()
		g.show_menu("settings"),Color("76648f"))
	section(g,"YOUR WORLD",683)
	var world: String = "Auto" if g.environment_override<0 else str(g.EnvironmentCatalog.WORLDS[g.environment_override].name)
	g.button_at(world+"  ›",Rect2(132,726,456,60),func():
		g.environment_override = ((g.environment_override+2)%(g.EnvironmentCatalog.WORLDS.size()+1))-1
		g.apply_environment()
		g.save_progress()
		g.show_menu("settings"),Color("4f8275"))
	var language_label: Label = g.label_at("Language",Vector2(132,811),19,Color("dfcba7"))
	language_label.size = Vector2(136,38)
	var languages := OptionButton.new()
	languages.set_meta("l10n_x",280)
	languages.name = "LanguageSelector"
	languages.position = Vector2(280,803)
	languages.size = Vector2(308,48)
	languages.add_theme_font_size_override("font_size",21)
	for name in L.NAMES: languages.add_item(name)
	languages.select(L.CODES.find(g.language))
	L.style(languages)
	languages.item_selected.connect(func(index):
		g.change_language(L.CODES[index])
		g.show_menu("settings"))
	g.ui.add_child(languages)
	g.button_at("Done",Rect2(132,864,456,66),func(): g.show_menu(),Color("5e956e"))
	g.button_at("Our story",Rect2(132,945,218,48),func(): g.play_story(-1,true),Color("655477"))
	var credits: Button = g.button_at("Audio credits",Rect2(370,945,218,48),func(): g.show_menu("credits"),Color("34465d"))
	credits.add_theme_font_size_override("font_size",17)
