extends RefCounted

const L = preload("res://scripts/localization.gd")

static func card(g: Node, rect: Rect2, color: Color, border: Color) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	p.set_meta("l10n_x",rect.position.x)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = g.panel(color,26,border)
	style.bg_color=Color(.035,.045,.10,.86)
	style.shadow_color = Color(0,0,0,.25)
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
	var decor=preload("res://scripts/menu_decoration.gd").new();decor.name="HomeDecoration";decor.size=Vector2(720,1120);decor.gentle=g.reduced_motion;g.ui.add_child(decor)
	# Compatibility handles remain hidden; the compact counter renders both values.
	for name in ["HomeCoins","HomeScore","HomeJourneyTitle","HomeJourneyCount","HomeRescueLink"]:
		var placeholder=Control.new();placeholder.name=name;placeholder.hide();g.ui.add_child(placeholder)
	var counters=preload("res://scripts/home_counters.gd").new();counters.name="HomeCounters";counters.points=g.wallet.total_score;counters.coins=g.wallet.coins;g.ui.add_child(counters)
	var settings=home_button(g,"HomeSettings","settings","",func():g.show_menu("settings"));settings.tooltip_text=L.t("Settings")
	var logo=TextureRect.new();logo.name="HomeLogo";logo.texture=load("res://assets/branding/magic_rescue_logo.png");logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;logo.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(logo)
	for i in range(3):
		var actor=preload("res://scripts/cat_actor.gd").new();actor.setup(g.cat_atlas,i,i*1.2);actor.menu_ears_enabled=i!=1;g.menu_cats.add_child(actor)
	var play=home_button(g,"HomePlay","play","Play",func():g.start_game(g.unlocked-1,true));play.level_caption=L.t("Level %d"%g.unlocked);play.level_label.text=play.level_caption
	var journey=home_button(g,"HomeLevels","card","Journey",func():g.show_menu("levels"),0)
	var rankings=home_button(g,"HomeGlobalRankings","card","Rankings",func():g.show_menu("rankings"),1)
	var sanctuary=home_button(g,"HomeSanctuary","card","Rescue Home",func():g.show_menu("rescue_home"),2)
	preload("res://scripts/responsive_layout.gd").home(g)
	g.menu_ui.modulate.a=0;g.menu_cats.modulate.a=0;g.menu_intro=g.create_tween().set_parallel(true);g.menu_intro.tween_property(g.menu_ui,"modulate:a",1.0,.4);g.menu_intro.tween_property(g.menu_cats,"modulate:a",1.0,.55)

static func home_button(g,name:String,kind:String,caption:String,callback:Callable,index:int=0):
	var b=preload("res://scripts/royal_home_button.gd").new();b.name=name;b.kind=kind;b.caption=caption;b.card_index=index;b.pressed.connect(callback);g.ui.add_child(b);return b

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
	card(g, Rect2(70, 286, 580, 790 if OS.has_feature("editor") else 725), Color("17263d"), Color("9d987f"))
	g.centered_text("Make this little world yours", 233, 18, Color("b8ced8"))
	section(g, "SOUND", 305)
	var effects: Button = g.button_at("Effects  " + ("ON" if g.sound_enabled else "OFF"), Rect2(132, 346, 180, 56), func():
		g.sound_enabled = not g.sound_enabled
		g.audio.set_enabled(g.sound_enabled)
		g.save_progress()
		g.show_menu("settings"), Color("527f99"))
	effects.name = "SettingsEffects"
	effects.title_size = 20
	slider(g, Vector2(342, 359), g.effects_volume, func(value):
		g.effects_volume = value
		g.audio.set_levels(g.music_volume, g.effects_volume)
		g.save_progress(), "Effects volume")
	var music: Button = g.button_at("Music  " + ("ON" if g.music_enabled else "OFF"), Rect2(132, 425, 180, 56), func():
		g.music_enabled = not g.music_enabled
		g.audio.set_music_enabled(g.music_enabled)
		g.save_progress()
		g.show_menu("settings"), Color("568b79"))
	music.name = "SettingsMusic"
	music.title_size = 20
	slider(g, Vector2(342, 438), g.music_volume, func(value):
		g.music_volume = value
		g.audio.set_levels(g.music_volume, g.effects_volume)
		g.save_progress(), "Music volume")
	section(g, "ANIMATION", 515)
	var animation = g.button_at("Gentle motion" if g.reduced_motion else "Full animation", Rect2(132, 552, 456, 60), func():
		g.reduced_motion = not g.reduced_motion
		g.save_progress()
		g.show_menu("settings"), Color("887493"))
	animation.name = "SettingsAnimation"
	section(g, "YOUR WORLD", 646)
	var world: String = "Auto" if g.environment_override < 0 else str(g.EnvironmentCatalog.WORLDS[g.environment_override].name)
	var world_button = g.button_at(world + "  ›", Rect2(132, 684, 456, 60), func():
		g.environment_override = ((g.environment_override + 2) % (g.EnvironmentCatalog.WORLDS.size() + 1)) - 1
		g.apply_environment()
		g.save_progress()
		g.show_menu("settings"), Color("568b79"))
	world_button.name = "SettingsWorld"
	var language_label: Label = g.label_at("Language", Vector2(132, 763), 19, Color("dfcba7"))
	language_label.size = Vector2(136, 38)
	var languages := OptionButton.new()
	languages.set_meta("l10n_x", 280)
	languages.name = "LanguageSelector"
	languages.position = Vector2(280, 758)
	languages.size = Vector2(308, 48)
	languages.add_theme_font_size_override("font_size", 21)
	for name in L.NAMES:
		languages.add_item(name)
	languages.select(L.CODES.find(g.language))
	L.style(languages)
	languages.item_selected.connect(func(index):
		g.change_language(L.CODES[index])
		g.show_menu("settings"))
	g.ui.add_child(languages)
	var done = g.button_at("Done", Rect2(132, 830, 456, 68), func(): g.show_menu(), Color("63977c"))
	done.name = "SettingsDone"
	var story = g.button_at("Our story", Rect2(132, 921, 218, 52), func(): g.play_story(-1, true), Color("887493"))
	story.name = "SettingsStory"
	story.title_size = 21
	var credits: Button = g.button_at("Audio credits", Rect2(370, 921, 218, 52), func(): g.show_menu("credits"), Color("667d96"))
	credits.name = "SettingsCredits"
	credits.title_size = 19
	if OS.has_feature("editor"):
		var preview=g.button_at("Preview name entry",Rect2(132,990,456,52),func():preload("res://scripts/leaderboard_ui.gd").name_prompt(g,true),Color("667d96"))
		preview.title_size=21
