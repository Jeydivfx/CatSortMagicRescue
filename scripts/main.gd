extends Node2D

const L = preload("res://scripts/localization.gd")
var language := "en"
var layout_safe_override := Vector2(-1,-1)
var layout_banner_override := -1.0

const COLORS = [Color("f6ad67"), Color("aab7d5"), Color("fff0cf"), Color("94d7bc")]
const INK = Color("26334d")
var levels: Array = []
var group_move_goals: Dictionary = {}
var tubes: Array = []
var history: Array = []
var level_index := 0
var unlocked := 1
var moves := 0
var selected := -1
var busy := false
var won := false
var lost := false
var loss_ui: Control
var entering := false
var entry_tween: Tween
var story_progress = preload("res://scripts/story_progress.gd").new()
var story_scene: Control
var tutorial_until := -1.0
var final_chorus_played := false
var entry_variant := -1
var extra_used := false
var flying := -1
var fly_position := Vector2.ZERO
var clock := 0.0
var message := "Tap a tube, then its destination"
var hint_pair: Array = []
var ui: Control
var status: Label
var speech_age := 0.0
var witch_tap_until := -10.0
var witch_reply := ""
var magic_exchange: Node2D
var curse = preload("res://scripts/witch_curse.gd").new()
var level_label: Label
var move_label: Label
var next_button: Button
var cat_atlas: Texture2D
var advanced_cat_atlas: Texture2D
var home_backdrop: Texture2D = preload("res://assets/environments/laboratory.png")
var backdrop: Texture2D
var cat_layer: Node2D
var actors: Array = []
var actor_signature := ""
var flight_progress := 0.0
var flight_direction := 1.0
var landing_tube := -1
var landing_at := -10.0
var win_at := -10.0
var progress_label: Label
var screen := "menu"
var menu_ui: Control
var menu_cats: Node2D
var reduced_motion := false
var reaction_tube := -1
var reaction_until := -1.0
var flight_squash := 0.0
var flight_tween: Tween
var audio: Node
var ads: Node
var sound_enabled := true
var hint_used := false
var hint_button: Button
var tube_button: Button
var reward_ui: Control
var rewarded_level := -1
var pending_reward := -1
var best_moves: Dictionary = {}
var win_ui: Control
var persistence_enabled := true
var music_enabled := true
var music_volume := 0.60
var effects_volume := 0.80
var level_page := 0
var solution_lookup: Dictionary = {}
var menu_intro: Tween
var flight_cats: Array = []
var pointer_source := -1
var pointer_touch := -1
var touch_ignore_until := 0
var pointer_start := Vector2.ZERO
var drag_active := false
var drag_source := -1
var drag_count := 0
var drag_anchor := Vector2.ZERO
var drag_offset := Vector2.ZERO
var drag_pointer := Vector2.ZERO
var wallet = preload("res://scripts/score_wallet.gd").new()
var playtest=preload("res://scripts/playtest_metrics.gd").new()
var coin_label: Label
var score_label: Label
var level_reward: Dictionary = {}
var effects: Array[Dictionary] = []
var game_ui: Control
var hud: Control
var undo_button: Button
var undo_left := 3
var pending_reward_kind := "tube"
var level_map: Control
var wizard: Control
var rescued_label: Label
var rescue_sound_played := false
var escape_sound_played := false
const EnvironmentCatalog = preload("res://scripts/environment_catalog.gd")
var environment_override := -1
var environment_index := -1
var environment_textures: Dictionary = {}
var previous_backdrop: Texture2D
var environment_blend := 1.0

func _ready() -> void:
	if OS.get_name() == "Android":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_viewport().size_changed.connect(fit_mobile_screen)
	fit_mobile_screen()
	audio = preload("res://scripts/sound_bank.gd").new()
	add_child(audio)
	ads = preload("res://scripts/ads_manager.gd").new()
	add_child(ads)
	ads.reward_earned.connect(on_tube_reward)
	ads.request_finished.connect(on_reward_finished)
	ads.presentation_changed.connect(func(showing: bool): audio.set_suspended("ad",showing))
	ads.banner_geometry_changed.connect(fit_mobile_screen)
	cat_atlas = load("res://assets/cats_expressions.png")
	advanced_cat_atlas = load("res://assets/cats_advanced.png")
	cat_layer = Node2D.new()
	add_child(cat_layer)
	var feedback=preload("res://scripts/board_feedback.gd").new()
	feedback.game=self
	add_child(feedback)
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://levels/campaign.json"))
	levels = data
	group_move_goals = JSON.parse_string(FileAccess.get_file_as_string("res://levels/group_move_goals.json"))
	if FileAccess.file_exists("user://progress.json"):
		var saved = JSON.parse_string(FileAccess.get_file_as_string("user://progress.json"))
		if saved is Dictionary:
			wallet.restore(saved)
			if saved.get("story",{}) is Dictionary: story_progress.restore(saved.get("story",{}))
			language = str(saved.get("language","en"))
			unlocked = clampi(int(saved.get("unlocked", 1)), 1, levels.size())
			reduced_motion = bool(saved.get("reduced_motion", false))
			sound_enabled = bool(saved.get("sound_enabled", true))
			music_enabled = bool(saved.get("music_enabled", sound_enabled))
			music_volume = clampf(float(saved.get("music_volume",0.6)),0,1)
			effects_volume = clampf(float(saved.get("effects_volume",0.8)),0,1)
			best_moves = saved.get("best_moves", {})
			environment_override = clampi(int(saved.get("environment_override",-1)),-1,EnvironmentCatalog.WORLDS.size()-1)
	L.set_locale(language)
	language = L.locale
	audio.set_enabled(sound_enabled)
	audio.set_levels(music_volume,effects_volume)
	audio.set_music_enabled(music_enabled)
	level_page = (unlocked - 1) / 10
	build_ui()
	game_ui = ui
	fit_mobile_screen()
	load_level(unlocked - 1)
	show_menu()
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://preview.png")

func fit_mobile_screen() -> void:
	var extent := get_viewport_rect().size
	position = (extent - Vector2(720,1120)) * 0.5
	if is_instance_valid(level_map) and screen=="levels":
		level_map.size = extent
		level_map.position = -position
		level_map.set_meta("l10n_x",-position.x)
	if is_instance_valid(game_ui):
		for item in game_ui.get_children():
			if item is Control:
				if not item.has_meta("base_y"):
					item.set_meta("base_y",item.position.y)
				item.position.y = spread_y(float(item.get_meta("base_y")))
	preload("res://scripts/responsive_layout.gd").gameplay(self)
	if screen=="menu":preload("res://scripts/responsive_layout.gd").home(self)
	queue_redraw()

func spread_y(y: float) -> float:
	return y + (y/1120.0-0.5)*maxf(0,get_viewport_rect().size.y-1120)

func apply_environment() -> void:
	var index := EnvironmentCatalog.for_level(level_index,environment_override)
	if index == environment_index:
		return
	environment_index = index
	var world: Dictionary = EnvironmentCatalog.WORLDS[index]
	if not environment_textures.has(index):
		environment_textures[index] = load(world.file)
	previous_backdrop = backdrop
	backdrop = environment_textures[index]
	environment_blend = 0.0 if previous_backdrop and not reduced_motion else 1.0
	if is_instance_valid(ui):
		tint_environment_buttons(ui)
	queue_redraw()

func tint_environment_buttons(container: Control) -> void:
	var accent := Color(EnvironmentCatalog.WORLDS[maxi(0,environment_index)].accent)
	for item in container.get_children():
		if item is Button and item.has_meta("base_tint") and not item.has_meta("jewel"):
			var base: Color = item.get_meta("base_tint")
			for state in ["normal","hover","pressed"]:
				var style: StyleBoxFlat = item.get_theme_stylebox(state).duplicate()
				style.bg_color = base.lerp(accent,0.24).darkened(0.18 if state == "normal" else (0.28 if state == "pressed" else 0.0))
				style.border_color = accent.lightened(0.15)
				item.add_theme_stylebox_override(state,style)

func label_at(text_value: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.set_meta("l10n_source",text_value)
	label.set_meta("l10n_x",pos.x)
	L.style(label)
	label.text = L.t(text_value)
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("352c42"))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(label)
	return label

func button_at(text_value: String, rect: Rect2, action: Callable, tint: Color = Color("258ec9")) -> Button:
	var button = preload("res://scripts/jewel_button.gd").new()
	button.tint = tint
	button.set_meta("l10n_source",text_value)
	button.set_meta("l10n_x",rect.position.x)
	L.style(button)
	button.text = L.t(text_value)
	button.set_meta("base_tint",tint)
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_outline_color", tint.darkened(0.65))
	button.add_theme_constant_override("outline_size", 2)
	button.pressed.connect(action)
	button.pressed.connect(func(): audio.play("tap"))
	button.pivot_offset = rect.size / 2
	button.button_down.connect(func():
		create_tween().tween_property(button, "scale", Vector2(0.94, 0.94), 0.09))
	button.button_up.connect(func():
		create_tween().tween_property(button, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	ui.add_child(button)
	button.position = rect.position
	return button

func centered_text(value: String, y: float, font_size: int, color: Color) -> Label:
	var item := label_at(value, Vector2(40, y), font_size, color)
	item.size.x = 640
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return item

func save_progress() -> void:
	if not persistence_enabled:
		return
	var file := FileAccess.open("user://progress.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(progress_snapshot()))

func progress_snapshot() -> Dictionary:
	return {"story":story_progress.snapshot(),"language":language,"unlocked": unlocked, "reduced_motion": reduced_motion, "sound_enabled": sound_enabled, "music_enabled": music_enabled, "music_volume":music_volume,"effects_volume":effects_volume,"best_moves": best_moves, "coins":wallet.coins,"total_score":wallet.total_score,"score_records":wallet.records,"environment_override":environment_override}

func change_language(code: String) -> void:
	L.set_locale(code)
	language = L.locale
	save_progress()
	L.restyle_tree(game_ui)
	refresh()

func volume_slider(y: float, value: float, action: Callable, description: String) -> void:
	var slider := HSlider.new()
	slider.position = Vector2(165,y)
	slider.size = Vector2(390,24)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = value
	slider.tooltip_text = L.t(description)
	slider.value_changed.connect(action)
	ui.add_child(slider)

func show_menu(page: String = "menu") -> void:
	if busy:
		return
	cancel_story()
	if is_instance_valid(menu_intro):
		menu_intro.kill()
	cancel_witch_entry()
	clear_win()
	clear_loss()
	screen = page
	ui.visible = false
	cat_layer.visible = false
	if is_instance_valid(menu_ui):
		menu_ui.hide()
		menu_ui.queue_free()
	if is_instance_valid(menu_cats):
		menu_cats.hide()
		menu_cats.queue_free()
	menu_ui = Control.new()
	menu_ui.layout_direction = Control.LAYOUT_DIRECTION_LTR
	add_child(menu_ui)
	menu_cats = Node2D.new()
	add_child(menu_cats)
	var game_ui := ui
	ui = menu_ui
	if page == "menu":
		preload("res://scripts/menu_designer.gd").home(self)
	elif page == "levels":
		level_map = preload("res://scripts/level_map.gd").new()
		L.style(level_map)
		level_map.set_meta("l10n_x",-position.x)
		level_map.position = -position
		level_map.size = get_viewport_rect().size
		ui.add_child(level_map)
		var challenges: Array = []
		for i in range(levels.size()):
			if levels[i].get("difficulty","")=="hard": challenges.append(i)
		level_map.configure(levels.size(),unlocked,wallet.records,challenges)
		level_map.level_selected.connect(open_map_level)
		level_map.home_pressed.connect(func(): show_menu())
	elif page == "settings":
		preload("res://scripts/menu_designer.gd").settings(self)
	elif page == "rescue_home":
		var home=preload("res://scripts/rescue_home.gd").new()
		menu_ui.add_child(home);home.configure(self)
	elif page == "credits":
		centered_text("Audio credits",155,38,Color("ffda79"))
		centered_text("Music: Clear Air\nKevin MacLeod (incompetech.com)\nCreative Commons Attribution 4.0",260,23,Color("f8e5c5"))
		centered_text("Converted to Ogg Vorbis; loudness normalized.",375,17,Color("b0bdd0"))
		credit_link("Music source",435,"https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100626")
		credit_link("CC BY 4.0 license",490,"https://creativecommons.org/licenses/by/4.0/")
		centered_text("Effects: Kenney Interface Sounds (CC0)\nCat recordings: Joseph SARDIN,\nKerzoven and IgnasD (CC0)",585,21,Color("f8e5c5"))
		credit_link("Kenney sound pack",720,"https://kenney.nl/assets/interface-sounds")
		credit_link("Story film: Fairytale Waltz",760,"https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100232")
		centered_text("Kevin MacLeod (incompetech.com) — CC BY 4.0\nEdited excerpt, fades and sound mix.",802,14,Color("b0bdd0"))
		button_at("<  Settings",Rect2(190,850,340,64),func(): show_menu("settings"))
	elif page == "pause":
		centered_text("Take a little break", 225, 39, Color("f8e5c5"))
		button_at("Resume", Rect2(145, 350, 430, 84), resume_game, Color("5c9d73"))
		var pause_music=button_at("Music  "+("ON" if music_enabled else "OFF"),Rect2(145,480,208,70),func():
			music_enabled=not music_enabled
			audio.set_music_enabled(music_enabled)
			save_progress()
			show_menu("pause"),Color("4f8275"))
		pause_music.name="PauseMusic";pause_music.title_size=22
		var pause_effects=button_at("Effects  "+("ON" if sound_enabled else "OFF"),Rect2(367,480,208,70),func():
			sound_enabled=not sound_enabled
			audio.set_enabled(sound_enabled)
			save_progress()
			show_menu("pause"),Color("477d96"))
		pause_effects.name="PauseEffects";pause_effects.title_size=22
		button_at("Restart level", Rect2(145, 600, 430, 76), func(): start_game(level_index,true), Color("506686"))
		button_at("Home", Rect2(145, 705, 430, 76), func(): show_menu(), Color("506686"))
	ui = game_ui
	tint_environment_buttons(menu_ui)
	L.restyle_tree(menu_ui)
	queue_redraw()

func resume_game() -> void:
	screen = "game"
	menu_ui.hide()
	menu_cats.hide()
	ui.show()
	cat_layer.show()

func credit_link(value: String, y: float, url: String) -> void:
	var link := LinkButton.new()
	link.text = L.t(value)
	link.uri = url
	link.position = Vector2(180,y)
	link.size = Vector2(360,40)
	link.add_theme_font_size_override("font_size",20)
	ui.add_child(link)

func start_game(index: int, with_entry: bool = false) -> void:
	screen = "game"
	menu_ui.visible = false
	menu_cats.visible = false
	ui.visible = true
	cat_layer.visible = true
	load_level(index)
	playtest.begin(index,persistence_enabled)
	if with_entry: begin_round_story()

func cancel_story() -> void:
	if is_instance_valid(story_scene): story_scene.cancel()
	story_scene = null
	entering = false

func begin_round_story() -> void:
	if level_index == 0 and not story_progress.intro_seen:
		play_story(-1)
	else:
		begin_witch_entry()

func play_story(world: int = -1, replay: bool = false) -> void:
	cancel_story()
	cancel_witch_entry()
	entering = true
	wizard.allow_idle = false
	story_scene = preload("res://scripts/video_story.gd").new()
	add_child(story_scene)
	story_scene.setup(self,world)
	story_scene.finished.connect(func():
		story_scene = null
		entering = false
		if not replay:
			if world<0: story_progress.intro_seen = true
			if not str(environment_index) in story_progress.worlds: story_progress.worlds.append(str(environment_index))
			save_progress()
			begin_witch_entry()
		elif screen=="game":
			refresh())
	refresh()

func cancel_witch_entry() -> void:
	if is_instance_valid(entry_tween): entry_tween.kill()
	entering = false
	if is_instance_valid(wizard):
		wizard.finish_flight()
		audio.stop_cue("witch_laugh")
		audio.stop_entry()
		wizard.position = Vector2(8,wizard_home_y())
		wizard.rotation = 0
		wizard.scale = Vector2.ONE
		wizard.modulate.a = 1
		wizard.z_index = 0

func begin_witch_entry() -> void:
	cancel_witch_entry()
	entering = true
	wizard.allow_idle = false
	wizard.z_index = 20
	var home := Vector2(8,wizard_home_y())
	entry_tween = create_tween()
	# Draw from the other two entrances, avoiding immediate repetition.
	entry_variant = (entry_variant+randi_range(1,2))%3 if entry_variant>=0 else randi_range(0,2)
	wizard.flight_style = entry_variant
	wizard.begin_flight()
	if reduced_motion:
		var offsets := [Vector2(110,-60),Vector2(-100,-65),Vector2(30,-110)]
		var start: Vector2 = home+offsets[entry_variant]
		entry_tween.tween_method(func(t: float):
			wizard.entry_progress = t
			wizard.position = start.lerp(home,t),0.0,1.0,1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		var starts := [Vector2(get_viewport_rect().size.x-position.x+120,spread_y(230)),Vector2(-position.x-280,spread_y(320)),Vector2(330,-position.y-330)]
		var start: Vector2 = starts[entry_variant]
		var control_a: Vector2 = start+Vector2(-140,-50) if entry_variant==0 else (start+Vector2(270,-120) if entry_variant==1 else Vector2(570,spread_y(160)))
		var control_b := Vector2(85,home.y-150) if entry_variant==0 else (Vector2(390,home.y-180) if entry_variant==1 else Vector2(-85,home.y-160))
		entry_tween.tween_method(func(t: float):
			wizard.entry_progress = t
			wizard.position = start.bezier_interpolate(control_a,control_b,home,t)
			wizard.scale = Vector2.ONE*lerpf(1.75 if entry_variant==0 else 1.3,1.0,smoothstep(0,1,t))
			wizard.rotation = sin(t*PI)*(.09 if entry_variant==1 else -.09),0.0,1.0,1.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry_tween.chain().tween_callback(func():
		entering = false
		wizard.finish_flight()
		wizard.rotation = 0
		wizard.z_index = 0
		wizard.note_move()
		refresh())
	refresh()

func open_map_level(index: int) -> bool:
	if index<0 or index>=unlocked or index>=levels.size():
		return false
	audio.play("tap")
	start_game(index,true)
	return true

func glossy_texture(tint: Color) -> ImageTexture:
	var image := Image.create(192, 96, false, Image.FORMAT_RGBA8)
	for y in range(96):
		for x in range(192):
			var q := Vector2(absf(x - 95.5) - 71.5, absf(y - 47.5) - 23.5)
			var distance := Vector2(maxf(q.x, 0), maxf(q.y, 0)).length() + minf(maxf(q.x, q.y), 0) - 23
			if distance > 0:
				continue
			var t := y / 95.0
			var color := tint.lightened(0.3).lerp(tint.darkened(0.36), t)
			if y < 44:
				color = color.lightened(0.17 * sin(t / 0.46 * PI))
			if distance > -3:
				color = tint.darkened(0.5)
			elif distance > -6:
				color = tint.lightened(0.45)
			if y > 8 and y < 15 and x > 28 and x < 163:
				color = color.lightened(0.48)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func build_ui() -> void:
	ui = Control.new()
	ui.layout_direction = Control.LAYOUT_DIRECTION_LTR
	add_child(ui)
	hud = preload("res://scripts/game_hud.gd").new()
	hud.layout_direction = Control.LAYOUT_DIRECTION_LTR
	hud.position = Vector2(12,12)
	ui.add_child(hud)
	var root_ui := ui
	ui = hud
	var pause = button_at("II",Rect2(3,3,58,58),func():
		if not entering and not won and not lost: show_menu("pause"),Color("42ac59"))
	pause.symbol = "pause"
	pause.compact = true
	pause.caption_override = " "
	level_label = label_at("",Vector2(14,77),18,Color("fff0cf"))
	level_label.size = Vector2(180,26)
	coin_label = label_at("",Vector2(102,14),25,Color("fff0cf"))
	coin_label.size = Vector2(114,34)
	coin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	progress_label = label_at("",Vector2(263,77),17,Color("a9bdce"))
	progress_label.size = Vector2(220,26)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	move_label = label_at("",Vector2(547,77),17,Color("d1e1ec"))
	move_label.size = Vector2(137,26)
	move_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label = label_at("",Vector2.ZERO,1,Color.WHITE)
	score_label.hide()
	ui = root_ui
	wizard = preload("res://scripts/witch_rig.gd").new()
	wizard.position = Vector2(8,656)
	wizard.size = Vector2(204,216)
	ui.add_child(wizard)
	wizard.laugh_started.connect(func(): audio.play("witch_laugh"))
	wizard.entry_laugh_started.connect(func(): audio.play_entry(wizard.flight_style))
	wizard.loss_laugh_started.connect(func(): audio.play("witch_laugh_loss"))
	wizard.irritation_started.connect(func(): audio.stop_cue("witch_laugh"))
	wizard.defeat_started.connect(func(): audio.play("witch_upset"))
	wizard.staff_impact.connect(on_witch_staff_impact)
	var touch_witch:=Button.new()
	touch_witch.name="WitchTouch"
	touch_witch.size=Vector2(190,216)
	touch_witch.focus_mode=Control.FOCUS_NONE
	touch_witch.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","focus"]:touch_witch.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	touch_witch.pressed.connect(provoke_witch)
	wizard.add_child(touch_witch)
	magic_exchange = preload("res://scripts/witch_magic.gd").new()
	magic_exchange.game = self
	magic_exchange.z_index = 12
	ui.add_child(magic_exchange)
	var speech := Panel.new()
	speech.name = "WitchSpeech"
	speech.set_meta("l10n_x",206.0)
	L.style(speech)
	speech.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speech.position = Vector2(206,789)
	speech.size = Vector2(476,76)
	speech.add_theme_stylebox_override("panel",panel(Color("d9d5f5"),22,Color("a8a2dc")))
	ui.add_child(speech)
	status = label_at("", Vector2(222, 800), 18, Color("b0bdd0"))
	status.size = Vector2(444,54)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color",Color("292257"))
	status.add_theme_constant_override("outline_size",0)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rescued_label = label_at("",Vector2(40,846),16,Color("b9dfcd"))
	rescued_label.size.x = 640
	rescued_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	undo_button = button_at("Undo 3", Rect2(36, 894, 208, 90), request_undo, Color("3979cd"))
	hint_button = button_at("Hint  1", Rect2(256, 894, 208, 90), request_hint, Color("d79c22"))
	tube_button = button_at("+ Tube  >", Rect2(476, 894, 208, 90), request_extra_tube, Color("16ad9d"))
	undo_button.symbol = "undo"
	hint_button.symbol = "hint"
	tube_button.symbol = "plus"
	for action in [undo_button,hint_button,tube_button]:
		action.compact = true
		action.title_size = 24
	next_button = button_at("Next level  >", Rect2(220, 728, 280, 68), next_level, Color("5c9d73"))
	var banner := label_at("ADVERTISEMENT", Vector2(0, get_banner_rect().position.y+40), 13, Color("566477"))
	banner.size.x = 720
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.name = "BannerReservation"

func load_level(index: int) -> void:
	if busy:
		return
	cancel_story()
	cancel_witch_entry()
	if pending_reward>=0:
		ads.finish_reward(pending_reward,ads.Result.CANCELLED)
	cancel_drag()
	clear_win()
	clear_loss()
	level_index = index
	apply_environment()
	tubes = levels[index]["tubes"].duplicate(true)
	history.clear()
	moves = 0
	undo_left = 3
	wizard.reset()
	rescue_sound_played = false
	final_chorus_played = false
	tutorial_until = -1
	escape_sound_played = false
	selected = -1
	won = false
	lost = false
	extra_used = false
	hint_used = false
	level_reward.clear()
	witch_tap_until = -10
	witch_reply = ""
	speech_age = 0
	status.modulate.a = 0
	ui.get_node("WitchSpeech").modulate.a = 0
	magic_exchange.bursts.clear()
	curse.reset()
	actor_signature = ""
	for actor in actors:
		actor.free()
	actors.clear()
	hint_pair.clear()
	landing_tube = -1
	reaction_until = -1.0
	next_button.scale = Vector2.ONE
	message = "Sort every kitten to break the witch's spell"
	if levels[index].get("pace","")=="recovery":message="A gentle round. Plan your next rescue."
	if index==0 and not story_progress.tutorial_seen:
		message = "Bring four matching kittens together. Their chorus breaks the spell!"
	if levels[index].has("new_cat"):
		message = "New friend: %s!" % levels[index]["new_cat"]
	build_solution_lookup()
	var total: int = levels[index].get("colors",2)
	var complete_count: int = tubes.filter(func(tube): return is_complete(tube)).size()
	hud.reset_progress(float(complete_count)/maxi(1,total),3)
	refresh()

func refresh() -> void:
	undo_button.text = L.t("Undo %d" % undo_left if undo_left>0 else "Undo VIDEO")
	undo_button.disabled = busy or won or history.is_empty() or pending_reward>=0
	undo_button.disabled = undo_button.disabled or entering
	coin_label.text = L.t(str(wallet.coins))
	score_label.text = L.t("Score %d" % wallet.total_score)
	level_label.text = L.t(("Hard • Level %d" if levels[level_index].get("difficulty","")=="hard" else "Level %d") % [level_index+1])
	level_label.add_theme_font_size_override("font_size",16 if levels[level_index].get("difficulty","")=="hard" else 18)
	var target := move_target()
	move_label.text = L.t("Moves left  %d" % maxi(0,move_limit()-moves))
	var limits := preload("res://scripts/move_budget.gd").limits(target)
	limits.z=move_limit()
	move_label.tooltip_text = L.t("3 stars: %d  •  2 stars: %d  •  Limit: %d" % [limits.x,limits.y,limits.z])
	var total: int = levels[level_index].get("colors",2)
	var complete_count: int = tubes.filter(func(tube): return is_complete(tube)).size()
	hud.world_index = maxi(0,environment_index)
	hud.gentle = reduced_motion
	wizard.gentle = reduced_motion
	wizard.set_near_win(not won and not lost and complete_count==total-1)
	rescued_label.text = L.t("All %d kittens are free!" % (total*4) if won else "Spell weakened  %d / %d" % [complete_count,total])
	hud.update_progress(float(complete_count)/maxi(1,total),wallet.star_rating(moves,target,hint_used or extra_used),complete_count,total,target)
	status.text = L.t(message)
	if clock<tutorial_until and not won: status.text = L.t("Hear that? Their chorus cracked the spell!")
	progress_label.text = L.t(str(EnvironmentCatalog.WORLDS[maxi(0,environment_index)].name))
	hud.center_caption(progress_label,true)
	hud.center_caption(move_label,false)
	if won:
		status.text = L.t("The spell is broken! Run, kittens!")
	elif lost:
		status.text = L.t("Out of moves. Try again or rewind.")
	next_button.text = L.t("Next  >" if not won else "Let's go!  >")
	next_button.disabled = busy or level_index + 1 >= unlocked or level_index + 1 >= levels.size()
	next_button.visible = false
	hint_button.disabled = busy or won or lost
	hint_button.text = L.t("Hint  %d" % wallet.hint_price(level_index))
	tube_button.disabled = busy or won or lost or extra_used or pending_reward >= 0
	hint_button.disabled = hint_button.disabled or entering
	tube_button.disabled = tube_button.disabled or entering
	undo_button.caption_override = L.t("Undo")
	undo_button.subtitle = "×%d" % undo_left if undo_left>0 else L.t("VIDEO")
	hint_button.caption_override = L.t("Hint")
	hint_button.subtitle = "● %d" % wallet.hint_price(level_index)
	tube_button.caption_override = L.t("+ Tube  >").replace("+", "").replace(">", "").strip_edges()
	tube_button.subtitle = L.t("VIDEO")
	rescued_label.hide()
	for action_button in [undo_button,hint_button,tube_button]:
		action_button.symbol_scale=.82 if level_index<2 else 1.0
		action_button.queue_redraw()
	L.restore_x(game_ui if is_instance_valid(game_ui) else ui)
	queue_redraw()

func move_target() -> int:
	var reference: int = levels[level_index].get("solution_length",3)
	# Use measured grouped-move goals where solved. Do not arbitrarily shrink a
	# single-cat certificate; that made some three-star targets impossible.
	return maxi(3,int(group_move_goals.get(str(level_index),reference)))

func move_limit() -> int:
	return preload("res://scripts/move_budget.gd").limits(move_target()).z+(2 if levels[level_index].get("pace","")=="recovery" else 0)

func board_columns() -> int:
	var count:=tubes.size()
	return count if count<=4 else ceili(count/2.0)

func board_area() -> Rect2:
	var top: float=content_rect().position.y+146
	var bottom: float=wizard_home_y()-34
	return Rect2(26,top,668,maxf(200,bottom-top))

func tube_rect(index: int) -> Rect2:
	var cols:=board_columns()
	var rows:=ceili(float(tubes.size())/cols)
	var row:=index/cols
	var col:=index%cols
	var row_count:=mini(cols,tubes.size()-row*cols)
	var s:=board_scale()
	var spacing:=108*s+26
	var area:=board_area()
	var height:=rows*250*s+(rows-1)*44
	var x:=360-(row_count-1)*spacing*.5+col*spacing
	var y:=area.position.y+maxf(0,(area.size.y-height)*.5)+row*(250*s+44)
	return Rect2(x-54*s,y,108*s,250*s)

func board_scale() -> float:
	var cols:=board_columns()
	var rows:=ceili(float(tubes.size())/cols)
	var area:=board_area()
	var width_limit: float=(area.size.x-26*(cols-1))/(108*cols)
	var height_limit: float=(area.size.y-44*(rows-1))/(250*rows)
	return minf(1.10 if rows==1 else 1.40,minf(width_limit,height_limit))

func footer_y() -> float:return get_banner_rect().position.y-108
func wizard_home_y() -> float:return footer_y()-238

func safe_insets() -> Vector2:
	if layout_safe_override.x>=0:return layout_safe_override
	if OS.get_name()!="Android":return Vector2.ZERO
	var safe:=DisplayServer.get_display_safe_area()
	var physical:=DisplayServer.window_get_size()
	if physical.y<=0 or safe.size.y<=0:return Vector2.ZERO
	var factor:=get_viewport_rect().size.y/physical.y
	return Vector2(maxi(0,safe.position.y)*factor,maxi(0,physical.y-safe.end.y)*factor)

func content_rect() -> Rect2:
	var top: float=-position.y+safe_insets().x
	return Rect2(0,top,720,maxf(600,get_banner_rect().position.y-18-top))

func cat_position(index: int, slot: int) -> Vector2:
	var rect := tube_rect(index)
	return Vector2(rect.get_center().x, rect.end.y-(44+slot*57)*board_scale())

func _process(delta: float) -> void:
	clock += delta
	if screen=="game" and not entering and not won and not lost and audio.suspension_reasons.is_empty():playtest.elapsed+=delta
	environment_blend = minf(1,environment_blend+delta/0.5)
	if environment_blend>=1:
		previous_backdrop = null
	for effect in effects:
		effect.age += delta
	effects = effects.filter(func(effect): return effect.age<0.8)
	if screen != "game":
		if is_instance_valid(menu_cats):
			for actor in menu_cats.get_children():
				actor.animate_menu(clock, actor.get_meta("menu_origin"), float(actor.get_meta("menu_scale")), reduced_motion)
		queue_redraw()
		return
	curse.update(delta,self)
	update_speech(delta)
	var watch: Vector2=drag_pointer if drag_active else (cat_position(selected,tubes[selected].size()-1) if selected>=0 and not tubes[selected].is_empty() else Vector2(360,board_area().get_center().y))
	var direction: Vector2=watch-(wizard.position+Vector2(84,62))
	wizard.gaze_target=Vector2(clampf(direction.x/180,-2.6,2.6),clampf(direction.y/220,-2.2,1.5)) if not entering and not won and not lost else Vector2.ZERO
	if not witch_reply.is_empty() and clock>=witch_tap_until and message==witch_reply:
		message="Sort every kitten to break the witch's spell"
		witch_reply=""
		refresh()
	update_actors()
	wizard.allow_idle = not entering and not busy and not won and not lost and pending_reward<0 and not drag_active
	if tutorial_until>0 and clock>=tutorial_until:
		tutorial_until = -1
		refresh()
	if won:
		if not final_chorus_played and clock-win_at>=.12:
			final_chorus_played = true
			audio.play_chorus(0,true)
		if not rescue_sound_played and clock-win_at>=0.53:
			rescue_sound_played = true
			audio.play("spell_break")
			wizard.defeat()
		if not escape_sound_played and clock-win_at>=0.72:
			escape_sound_played = true
			audio.play("escape")
		next_button.scale = Vector2.ONE * (1.0 + sin(clock * 3.0) * 0.015)
	queue_redraw()

func update_speech(delta: float) -> void:
	var blocked := entering
	if not blocked: speech_age += delta
	var alpha := 0.0 if blocked else smoothstep(.25,.85,speech_age)
	game_ui.get_node("WitchSpeech").modulate.a = alpha
	status.modulate.a = alpha

func provoke_witch() -> void:
	if screen!="game" or entering or busy or won or lost or clock<witch_tap_until or pending_reward>=0 or wizard.reaction in ["sort","curse"]:return
	witch_tap_until=clock+5
	if wizard.near_win:
		wizard.react_good_move()
		witch_reply="Not the last tube! My spell!"
	else:
		wizard.story_laugh(1.4)
		wizard.throw_magic(.55)
		audio.play("witch_laugh")
		var replies: Array=["Hehe! Can you outsmart my spell?","Those kittens are staying with me!","Let's see how clever you are!"]
		witch_reply=replies[(moves+level_index)%replies.size()]
	message=witch_reply
	speech_age=.2
	refresh()

func on_witch_staff_impact() -> void:
	audio.play("staff_thud")
	curse.impact(self)
	if screen!="game" or entering or not is_instance_valid(magic_exchange): return
	var protected: bool = wizard.reaction=="sort" and not won and reaction_tube>=0 and reaction_tube<tubes.size() and is_complete(tubes[reaction_tube])
	var origin: Vector2 = wizard.position+Vector2(122,173)
	var target: Vector2 = tube_rect(reaction_tube).get_center() if protected else origin
	magic_exchange.strike(origin,target,protected,tube_rect(reaction_tube).size if protected else Vector2.ZERO)

func update_actors() -> void:
	var signature := str(tubes) + str(flight_cats)
	if signature != actor_signature:
		var needed := {}
		for i in range(tubes.size()):
			for slot in range(tubes[i].size()):
				needed[Vector2i(i, slot)] = int(tubes[i][slot])
		if flying >= 0:
			for index in range(flight_cats.size()):
				needed[Vector2i(-1, index)] = int(flight_cats[index])
		for actor in actors.duplicate():
			var key := Vector2i(actor.get_meta("tube"), actor.get_meta("slot"))
			if needed.has(key) and actor.kind == needed[key]:
				needed.erase(key)
			else:
				actors.erase(actor)
				actor.free()
		for key in needed:
			make_actor(needed[key], key.x, key.y)
		actor_signature = signature
	for actor in actors:
		var tube: int = actor.get_meta("tube")
		var slot: int = actor.get_meta("slot")
		actor.set_stack_count(flight_cats.size() if tube<0 else tubes[tube].size(),slot<(flight_cats.size() if tube<0 else tubes[tube].size())-1)
		if tube < 0:
			actor.z_index = 20+slot*2
			actor.position = fly_position+Vector2(0,-slot*57*board_scale())
			actor.animate(clock, false, flight_squash, 2, reduced_motion)
			actor.scale *= board_scale()
			actor.rotation = sin(flight_progress * TAU) * 0.045 * flight_direction
		else:
			if won:
				animate_escape(actor,tube,slot)
				continue
			actor.modulate.a = 1.0
			if drag_active and tube == drag_source and slot >= tubes[tube].size() - drag_count:
				actor.position = drag_anchor+Vector2(0,-(slot-(tubes[tube].size()-drag_count))*57*board_scale())
				actor.z_index = 20+(slot-(tubes[tube].size()-drag_count))*2
				actor.animate(clock, true, 0, 2, reduced_motion)
				actor.scale *= board_scale()
				continue
			actor.z_index = slot*2
			var active: bool = selected == tube and slot >= tubes[tube].size()-top_group_count(tubes,tube)
			var target := cat_position(tube, slot)
			if active:
				target.y -= 8 + sin(clock * 3.0) * 1.5
			actor.position = actor.position.lerp(target, 1.0 - exp(-18.0 * get_process_delta_time()))
			var squash := 0.0
			if tube == landing_tube and slot == tubes[tube].size() - 1:
				var elapsed := clock - landing_at
				if elapsed < 0.26:
					squash = sin(elapsed / 0.26 * PI) * 0.65
			if won:
				actor.position.y -= absf(sin((clock - win_at) * 4.0 + slot * 0.4 + tube)) * 8
			var mood := 2 if won or (tube == landing_tube and clock - landing_at < 0.85) else 0
			if tube == reaction_tube and clock < reaction_until:
				mood = 3
			actor.animate(clock, active, squash, mood, reduced_motion)
			actor.scale *= board_scale()
			if tube==landing_tube and is_complete(tubes[tube]) and clock-landing_at<.9:
				var cheer := clampf((clock-landing_at)/.55,0,1)
				actor.position.y -= sin(cheer*PI)*(2 if reduced_motion else 8)
				if slot==3: actor.rotation -= sin(cheer*PI)*(.015 if reduced_motion else .09)

func make_actor(kind: int, tube: int, slot: int) -> void:
	var actor = preload("res://scripts/cat_actor.gd").new()
	actor.setup(advanced_cat_atlas if kind >= 7 else cat_atlas, kind, (tube+1)*1.17+(slot+1)*0.73)
	actor.set_meta("tube", tube)
	actor.set_meta("slot", slot)
	actor.position = cat_position(tube, slot) if tube >= 0 else fly_position
	cat_layer.add_child(actor)
	actors.append(actor)

func animate_escape(actor: Node2D, tube: int, slot: int) -> void:
	actor.set_stack_count(1)
	var elapsed := clock-win_at
	var start := cat_position(tube,slot)
	var launch := 0.62+tube*0.018+(3-slot)*0.065
	var t := clampf((elapsed-launch)/1.15,0,1)
	actor.animate(clock,false,0,2,reduced_motion)
	actor.scale *= board_scale()
	actor.z_index = 4
	var side := -1.0 if tube%2==0 else 1.0
	var destination := Vector2(-position.x-180 if side<0 else get_viewport_rect().size.x-position.x+180,spread_y(680))
	var travel := t*t*(3-2*t)
	actor.position = start.lerp(destination,travel)+Vector2(0,-sin(t*PI)*(45 if reduced_motion else 145+slot*12))
	actor.rotation = 0 if reduced_motion else sin(t*TAU)*.065
	actor.modulate.a = 1.0

func draw_environment_texture(texture: Texture2D, target: Rect2, opacity: float) -> void:
	var texture_size := texture.get_size()
	var factor := maxf(target.size.x/texture_size.x,target.size.y/texture_size.y)
	var crop := target.size/factor
	draw_texture_rect_region(texture,target,Rect2((texture_size-crop)*0.5,crop),Color(1,1,1,opacity))

func draw_environment_particles(area: Rect2) -> void:
	var tint := Color(EnvironmentCatalog.WORLDS[maxi(0,environment_index)].particle)
	var time := 0.0 if reduced_motion else clock
	for i in range(12):
		var phase := i*2.399
		var side := -1.0 if i%2==0 else 1.0
		var point := Vector2(360+side*(285+sin(time*0.3+phase)*20),area.position.y+fposmod(i*137.0+time*(9 if environment_index==2 else -3),area.size.y))
		tint.a = 0.15+(sin(time+phase)+1)*0.12
		if environment_index==2:
			var petal := PackedVector2Array([point+Vector2(-4,0),point+Vector2(0,-3),point+Vector2(6,2),point+Vector2(0,4)])
			draw_colored_polygon(petal,tint)
		else:
			draw_circle(point,1.5+(sin(time+phase)+1)*0.8,tint)

func _draw() -> void:
	var full_rect := Rect2(-position, get_viewport_rect().size)
	if screen == "menu":
		draw_environment_texture(home_backdrop,full_rect,1)
	elif backdrop:
		if previous_backdrop:
			draw_environment_texture(previous_backdrop,full_rect,1)
		draw_environment_texture(backdrop,full_rect,environment_blend)
	var world: Dictionary = EnvironmentCatalog.WORLDS[maxi(0,environment_index)]
	var shade := Color(world.shade)
	shade.a = 0.34 if screen == "game" else (0.12 if screen == "menu" else 0.32)
	draw_rect(full_rect, shade)
	draw_environment_particles(full_rect)
	for effect in effects:
		var t: float = effect.age/0.8
		var tint := Color("ffda79")
		tint.a = 1.0-t
		for i in range(10):
			var direction := Vector2.from_angle(i*TAU/10)
			var point: Vector2 = effect.point+direction*(20+t*75)
			draw_circle(point,maxf(1,5*(1-t)),tint)
	if screen not in ["game","menu","levels"]:
		draw_style_box(panel(Color(0.04, 0.06, 0.13, 0.55), 35, Color(0.82, 0.66, 0.42, 0.5)), Rect2(70, 80, 580, 952))
		return
	if screen in ["menu","levels"]: return
	draw_rect(get_banner_rect(), Color("101824"))
	draw_line(get_banner_rect().position, get_banner_rect().position + Vector2(get_banner_rect().size.x,0), Color("2c394b"), 1)
	for i in range(tubes.size()):
		var rect := tube_rect(i)
		if won and clock-win_at>=0.53+i*0.018:
			draw_broken_jar(rect,i)
			continue
		var s := board_scale()
		var complete := is_complete(tubes[i])
		if wizard.near_win and not won and not complete and not tubes[i].is_empty():
			draw_arc(rect.position+Vector2(rect.size.x*.5,6),rect.size.x*.65,PI*.95,TAU*1.02,32,Color(.75,.4,1,.22+sin(clock*3)*.07),2,true)
		var tint := Color("b5f2ca") if complete else Color("c1cfe5")
		if i == selected or i in hint_pair:
			tint = Color("f6cd86")
			draw_style_box(panel(Color(1, 0.73, 0.3, 0.06 + sin(clock * 3) * 0.025), 39, Color(1, 0.78, 0.4, 0.15)), rect.grow(7))
		if drag_active and i != drag_source and rect.grow(10).has_point(drag_pointer) and legal(tubes, drag_source, i):
			tint = Color("a4e3bc")
			draw_style_box(panel(Color(0.4, 0.9, 0.6, 0.12), 39, tint), rect.grow(7))
		draw_style_box(panel(Color("393c79"),8,Color("777eae")),Rect2(rect.position+Vector2(-6*s,rect.size.y+4),Vector2(120*s,16*s)))
		draw_line(rect.position+Vector2(-2*s,rect.size.y+7),rect.position+Vector2(110*s,rect.size.y+7),Color("a5b6ee"),1.5,true)
		draw_style_box(panel(Color(0.48, 0.62, 0.82, 0.12), 35, tint), rect)
		draw_line(rect.position+Vector2(9,15)*s,rect.position+Vector2(9,211)*s,Color(0.85,0.94,1,0.38),2.5*s,true)
		var rim := PackedVector2Array()
		for segment in range(49):
			var angle := segment * TAU / 48.0
			rim.append(rect.position+Vector2(54+cos(angle)*54,2+sin(angle)*9)*s)
		draw_polyline(rim, Color("e3e7f4"), 2.5, true)
		if complete:
			var center := rect.get_center()
			var edge := Vector2(rect.position.x+7*s,center.y)
			var fissure := PackedVector2Array([edge+Vector2(0,-rect.size.y*.36),edge+Vector2(5,-25)*s,edge+Vector2(-2,0)*s,edge+Vector2(5,24)*s,edge+Vector2(0,rect.size.y*.34)])
			draw_polyline(fissure,Color(.83,.96,1,.42+sin(clock*2)*.1),1.8,true)
			draw_circle(rect.position+Vector2(92,0)*s,12*s,Color("94d7bc"))
			draw_line(rect.position+Vector2(86,0)*s,rect.position+Vector2(91,5)*s,INK,2,true)
			draw_line(rect.position+Vector2(91,5)*s,rect.position+Vector2(99,-5)*s,INK,2,true)
		if won:
			var center := rect.get_center()
			var crack := PackedVector2Array([center+Vector2(-8,-rect.size.y*.4),center+Vector2(9,-35),center+Vector2(-12,-8),center+Vector2(12,23),center+Vector2(-4,rect.size.y*.4)])
			draw_polyline(crack,Color(.9,1,1,clampf((clock-win_at)*3,0,1)),2.5,true)
	if won:
		for i in range(28):
			var angle := i * 2.399
			var radius := 80 + fmod(clock * 65 + i * 29, 230)
			draw_circle(Vector2(360, 520) + Vector2(cos(angle), sin(angle)) * radius, 4, COLORS[i % 4])

func draw_broken_jar(rect: Rect2,index: int) -> void:
	var t := maxf(0,clock-win_at-.53-index*.018)
	var alpha := 1-smoothstep(.15,.95,t)
	if alpha<=0: return
	var center := rect.get_center()
	if reduced_motion:
		draw_style_box(panel(Color(.7,.9,1,alpha*.15),30,Color(.7,.9,1,alpha*.5)),rect)
		return
	for shard in range(9):
		var angle := shard*2.399+index
		var origin := center+Vector2(cos(angle)*rect.size.x*.35,sin(angle)*rect.size.y*.35)
		var point := origin+Vector2(cos(angle)*t*115,-sin(angle)*t*105+t*t*180)
		var vertices := PackedVector2Array()
		for tip in range(3):
			var turn := angle+tip*TAU/3+t*3
			vertices.append(point+Vector2(cos(turn),sin(turn))*(9 if tip==0 else 15))
		draw_colored_polygon(vertices,Color(.65,.87,1,alpha*.45))
		draw_polyline(PackedVector2Array([vertices[0],vertices[1],vertices[2],vertices[0]]),Color(.85,.97,1,alpha*.8),1.5,true)

func panel(color: Color, radius: int, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.set_border_width_all(2 if border.a > 0 else 0)
	return style

func _unhandled_input(event: InputEvent) -> void:
	if screen == "menu" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for actor in menu_cats.get_children():
			if Rect2(actor.global_position-Vector2(78,84),Vector2(156,166)).has_point(get_canvas_transform().affine_inverse()*event.position):
				actor.greet_until = clock + 1.5
				audio.play("tap")
				return
	if entering or busy or won or lost or screen != "game" or is_instance_valid(reward_ui):
		return
	var point := Vector2.ZERO
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		point = get_global_transform_with_canvas().affine_inverse()*event.position
	else:
		return
	var source:=tube_at(point)
	if source>=0:
		pointer_source=source;pointer_start=point

func _input(event: InputEvent) -> void:
	if is_instance_valid(story_scene): return
	# Capture native touch on the board; GUI buttons retain touch emulation.
	if event is InputEventScreenTouch:
		var touch_point: Vector2 = get_global_transform_with_canvas().affine_inverse()*event.position
		if event.pressed and pointer_source < 0 and screen == "game" and not entering and not busy and not won and not lost and not is_instance_valid(reward_ui):
			var source := tube_at(touch_point)
			if source >= 0:
				pointer_source = source
				pointer_start = touch_point
				pointer_touch = event.index
		if event.index == pointer_touch:
			touch_ignore_until = Time.get_ticks_msec() + 400
			if not event.pressed:
				release_pointer(touch_point)
				pointer_touch = -1
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenDrag and event.index == pointer_touch:
		move_pointer(get_global_transform_with_canvas().affine_inverse()*event.position)
		get_viewport().set_input_as_handled()
		return
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and Time.get_ticks_msec() < touch_ignore_until:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and drag_active:
		cancel_drag()
		get_viewport().set_input_as_handled()
		return
	if pointer_source < 0:
		return
	if event is InputEventMouseMotion:
		var point: Vector2 = get_global_transform_with_canvas().affine_inverse()*event.position
		move_pointer(point)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		release_pointer(get_global_transform_with_canvas().affine_inverse()*event.position)
		get_viewport().set_input_as_handled()

func move_pointer(point: Vector2) -> void:
	if pointer_source < 0:
		return
	if not drag_active and point.distance_to(pointer_start) > 12 and not tubes[pointer_source].is_empty():
		begin_drag(pointer_source, pointer_start)
	if drag_active:
		drag_pointer = point
		drag_anchor = point + drag_offset

func release_pointer(point: Vector2) -> void:
	var source := pointer_source
	pointer_source = -1
	if drag_active:
		var destination := tube_at(point)
		if destination < 0:
			destination = tube_at(drag_anchor)
		finish_drag(destination)
	elif source >= 0 and tube_at(point) == source:
		choose(source)

func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_WINDOW_FOCUS_OUT,NOTIFICATION_APPLICATION_FOCUS_OUT]:
		cancel_drag()
		if is_instance_valid(audio):
			audio.set_suspended("focus",true)
	elif what in [NOTIFICATION_WM_WINDOW_FOCUS_IN,NOTIFICATION_APPLICATION_FOCUS_IN]:
		if is_instance_valid(audio):
			audio.set_suspended("focus",false)

func tube_at(point: Vector2) -> int:
	var closest := -1
	var distance := INF
	for index in range(tubes.size()):
		var rect:=tube_rect(index)
		if rect.grow(12).has_point(point):
			var d:=point.distance_squared_to(rect.get_center())
			if d<distance:closest=index;distance=d
	return closest

func top_group_count(state: Array, source: int) -> int:
	if source < 0 or source >= state.size() or state[source].is_empty():
		return 0
	var count := 0
	var kind: int = state[source].back()
	for index in range(state[source].size() - 1, -1, -1):
		if int(state[source][index]) != kind:
			break
		count += 1
	return count

func begin_drag(source: int, point: Vector2) -> void:
	if entering or busy or won or lost or source < 0 or tubes[source].is_empty():
		return
	if curse.blocked(source):
		curse.reject(self)
		return
	drag_source = source
	drag_count = top_group_count(tubes, source)
	drag_active = true
	drag_pointer = point
	drag_anchor = cat_position(source, tubes[source].size() - drag_count)
	drag_offset = drag_anchor - point
	selected = -1
	hint_pair.clear()
	message = "Drag %d matching kittens together" % drag_count
	audio.play("jump")
	refresh()

func finish_drag(destination: int) -> void:
	var source := drag_source
	var count := drag_count
	drag_active = false
	pointer_source = -1
	if destination==source:
		cancel_drag();refresh();return
	if destination >= 0 and legal(tubes, source, destination):
		transfer(source, destination, mini(count, 4-tubes[destination].size()), true)
	else:
		cancel_drag()
		message = "This tube is full." if destination>=0 and tubes[destination].size()>=4 else "Drop on an empty or matching tube"
		if destination>=0 and destination!=source: wizard.react_mistake()
		audio.play("nope")
		refresh()

func cancel_drag() -> void:
	pointer_source = -1
	pointer_touch = -1
	drag_active = false
	drag_source = -1
	drag_count = 0

func legal(state: Array, src: int, dst: int) -> bool:
	return src != dst and not state[src].is_empty() and state[dst].size() < 4 and (state[dst].is_empty() or state[dst].back() == state[src].back())

func choose(index: int) -> void:
	if entering or busy or won or lost: return
	if curse.blocked(index):
		curse.reject(self)
		return
	audio.play("tap")
	if selected < 0:
		if not tubes[index].is_empty():
			selected = index
	elif selected == index:
		selected = -1
	elif legal(tubes, selected, index):
		transfer(selected, index, top_group_count(tubes, selected))
		return
	else:
		reaction_tube = selected
		reaction_until = clock + 0.85
		audio.play("nope")
		selected = index if not tubes[index].is_empty() else -1
		wizard.react_mistake()
		message = "Match the top cat, or choose an empty tube"
	refresh()

func transfer(src: int, dst: int, amount: int = 1, from_drag: bool = false) -> void:
	if entering or busy or won or lost or not legal(tubes, src, dst):
		return
	if curse.blocked(src) or curse.blocked(dst):
		curse.reject(self)
		return
	var count := mini(maxi(1, amount), mini(top_group_count(tubes, src), 4 - tubes[dst].size()))
	var base_slot: int = tubes[src].size() - count
	var start := cat_position(src, base_slot)
	for actor in actors:
		if int(actor.get_meta("tube")) == src and int(actor.get_meta("slot")) >= base_slot:
			var relative_slot := int(actor.get_meta("slot")) - base_slot
			if relative_slot == 0:
				start = actor.position
			actor.set_meta("tube", -1)
			actor.set_meta("slot", relative_slot)
			actor.z_index = 2
	history.append(tubes.duplicate(true))
	wizard.note_move()
	busy = true
	hint_pair.clear()
	selected = -1
	flight_cats.clear()
	for index in range(count):
		flight_cats.append(int(tubes[src].pop_back()))
	flying = int(flight_cats[0])
	var finish := cat_position(dst, tubes[dst].size())
	fly_position = start
	flight_progress = 0.0
	flight_squash = 0.0
	flight_direction = signf(finish.x - start.x)
	refresh()
	if not from_drag:
		audio.play("jump")
	var tween := create_tween()
	flight_tween = tween
	# One continuous cubic arc with vertical launch and landing tangents.
	tween.tween_property(self, "flight_squash", 0.35 if from_drag else 0.65, 0.02 if from_drag else 0.07)
	var control_y := maxf(194.0+(count-1)*57*board_scale()+40*board_scale(),minf(start.y,finish.y)-125.0)
	var control_a := Vector2(start.x, control_y)
	var control_b := Vector2(finish.x, control_y)
	if from_drag:
		tween.tween_method(func(t: float):
			flight_progress = t
			flight_squash = (1.0-t)*0.35
			fly_position = start.lerp(finish,t),0.0,1.0,0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_method(func(t: float):
			flight_progress = t
			flight_squash = lerpf(0.65,0.0,minf(t*5,1.0))
			fly_position = start.bezier_interpolate(control_a,control_b,finish,t),0.0,1.0,0.64 if not reduced_motion else 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	for actor in actors:
		if int(actor.get_meta("tube")) == -1:
			var relative_slot := int(actor.get_meta("slot"))
			actor.set_meta("tube", dst)
			actor.set_meta("slot", tubes[dst].size() + relative_slot)
			actor.z_index = 0
			actor.position = finish+Vector2(0,-relative_slot*57*board_scale())
	tubes[dst].append_array(flight_cats)
	flight_cats.clear()
	flying = -1
	landing_tube = dst
	landing_at = clock
	moves += 1
	busy = false
	if is_complete(tubes[dst]):
		if not solved(tubes): audio.play_chorus(int(tubes[dst].back()))
		if level_index==0 and not story_progress.tutorial_seen:
			story_progress.tutorial_seen = true
			tutorial_until = clock+4
			save_progress()
		if not solved(tubes):
			reaction_tube = dst
			wizard.react_to_sort()
		effects.append({"point":cat_position(dst,2),"age":0.0})
	else:
		audio.play("land")
		if count>=2: wizard.react_good_move()
	message = "Lovely! Keep the kittens together."
	if is_complete(tubes[dst]): message = "The spell is weaker! Keep sorting."
	won = solved(tubes)
	if won:
		win_at = clock
		wizard.angry = true
		audio.start_celebration()
		message = "Purrfect! All kittens are home."
		unlocked = mini(levels.size(), maxi(unlocked, level_index + 2))
		var key := str(level_index)
		best_moves[key] = mini(int(best_moves.get(key, moves)), moves)
		var target := move_target()
		var new_rescue: bool=not wallet.records.has(key)
		level_reward = wallet.award(level_index,moves,target,hint_used or extra_used)
		level_reward["keepsake"]=new_rescue and (level_index+1)%10==0
		playtest.result(true,moves)
		save_progress()
	elif moves>=move_limit():
		lost = true
		playtest.result(false,moves)
		wizard.celebrate_player_loss()
		show_loss()
	if won or lost: curse.clear()
	else:
		curse.on_move(self,src,dst)
		if not is_complete(tubes[dst]):curse.try_cast(self)
	update_actors()
	refresh()
	if won:
		var finished_level := level_index
		await get_tree().create_timer(2.4).timeout
		if won and screen=="game" and level_index==finished_level:
			show_win()

func clear_loss() -> void:
	if is_instance_valid(loss_ui):
		audio.stop_cue("witch_laugh_loss")
		loss_ui.hide()
		loss_ui.queue_free()
	loss_ui = null
	if is_instance_valid(wizard): wizard.z_index = 0

func show_loss() -> void:
	clear_loss()
	loss_ui = Control.new()
	loss_ui.layout_direction = Control.LAYOUT_DIRECTION_LTR
	loss_ui.z_index = 10
	add_child(loss_ui)
	wizard.z_index = 12
	var shade := ColorRect.new()
	shade.set_meta("l10n_x",-position.x)
	shade.position = -position
	shade.size = get_viewport_rect().size
	shade.color = Color(.025,.035,.07,.75)
	loss_ui.add_child(shade)
	var card := Panel.new()
	card.set_meta("l10n_x",150)
	card.position = Vector2(150,210)
	card.size = Vector2(420,440)
	card.add_theme_stylebox_override("panel",panel(Color("233449"),28,Color("b093cf")))
	loss_ui.add_child(card)
	var previous := ui
	ui = loss_ui
	centered_text("Out of moves!",245,36,Color("ffdd9e"))
	var loss_story := centered_text("Quiet at last... Try again to rescue the kittens!",300,19,Color("c3d5df"))
	loss_story.position.x = 180
	loss_story.set_meta("l10n_x",180)
	loss_story.size = Vector2(360,95)
	loss_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_at("Try again",Rect2(200,410,320,64),func(): start_game(level_index,true),Color("629967"))
	button_at("Undo  %d" % undo_left if undo_left>0 else "Undo  VIDEO",Rect2(200,492,320,60),request_undo,Color("76648f"))
	button_at("Home",Rect2(260,579,200,44),func(): show_menu(),Color("42566f"))
	ui = previous
	L.restyle_tree(loss_ui)

func clear_win(stop_audio: bool = true) -> void:
	if stop_audio: audio.stop_celebration()
	if is_instance_valid(win_ui):
		ui.show()
		win_ui.hide()
		win_ui.queue_free()
	win_ui = null

func show_win() -> void:
	clear_win()
	ui.hide()
	win_ui = preload("res://scripts/victory_screen.gd").new()
	win_ui.layout_direction = Control.LAYOUT_DIRECTION_LTR
	add_child(win_ui)
	win_ui.audio_cue.connect(func(name: String):
		if name.begins_with("star_"):
			audio.play("hud_star_%d" % (int(name.trim_prefix("star_"))+1))
		elif name!="win":
			audio.play(name))
	win_ui.setup(cat_atlas, moves, int(best_moves[str(level_index)]), level_index == levels.size() - 1, reduced_motion)
	win_ui.show_score(level_reward)
	L.restyle_tree(win_ui)
	win_ui.next_pressed.connect(func():
		audio.play("tap")
		next_level())
	win_ui.home_pressed.connect(func():
		audio.play("tap")
		show_menu("rescue_home" if level_reward.get("keepsake",false) else "menu"))

func is_complete(tube: Array) -> bool:
	return tube.size() == 4 and tube.all(func(cat): return cat == tube[0])

func solved(state: Array) -> bool:
	return state.all(func(tube): return tube.is_empty() or is_complete(tube))

func undo() -> void:
	if entering or busy or won or history.is_empty() or undo_left<=0:
		return
	undo_left -= 1
	playtest.event("undos")
	curse.clear()
	tubes = history.pop_back()
	moves = maxi(0, moves - 1)
	selected = -1
	won = false
	if lost:
		lost = false
		clear_loss()
		wizard.clear_result()
	wizard.note_move()
	hint_pair.clear()
	message = "One small step back."
	refresh()

func request_undo() -> void:
	if entering or busy or won or history.is_empty() or pending_reward>=0:
		return
	if undo_left>0:
		undo()
	else:
		request_reward("undo")

func add_tube() -> void:
	if entering or busy or won or lost or extra_used:
		return
	tubes.append([])
	history.clear()
	extra_used = true
	selected = -1
	message = "Video reward: an extra tube!"
	refresh()

func request_hint() -> void:
	if entering or busy or won or lost:
		return
	curse.clear()
	var cost: int = wallet.hint_price(level_index)
	if wallet.coins < cost:
		message = "Need %d coins. Complete a new level to earn more!" % cost
		audio.play("nope")
		refresh()
		return
	if not hint_pair.is_empty():
		message = "Follow the highlighted tubes first."
		refresh()
		return
	await show_hint()
	if not hint_pair.is_empty():
		wallet.buy_hint(level_index)
		playtest.event("hints")
		audio.play("purchase")
		hint_used = true
		save_progress()
	refresh()

func request_extra_tube() -> void:
	if entering or busy or won or lost or extra_used or pending_reward >= 0:
		return
	request_reward("tube")

func request_reward(kind: String) -> void:
	if pending_reward>=0:
		return
	pending_reward_kind = kind
	playtest.event("video_requests")
	pending_reward = ads.begin_reward()
	rewarded_level = level_index
	if OS.has_feature("android"):
		ads.request_provider(pending_reward)
		if ads.pending_id < 0:
			pending_reward = -1
			message = "Video unavailable. Please try again later."
			refresh()
		return
	# Desktop-only preview. This does not represent an actual ad impression.
	reward_ui = Control.new()
	reward_ui.layout_direction = Control.LAYOUT_DIRECTION_LTR
	reward_ui.z_index = 30
	reward_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(reward_ui)
	var shade := ColorRect.new()
	shade.set_meta("l10n_x",-position.x)
	shade.color = Color(0.015, 0.025, 0.05, 0.94)
	shade.size = Vector2(720, 1120)
	reward_ui.add_child(shade)
	var previous := ui
	ui = reward_ui
	centered_text("Three extra undos" if kind=="undo" else "An extra little space", 290, 35, Color("f3e2bd"))
	centered_text("Video: rewind now and keep 2 more undos." if kind=="undo" else "Watch a video to unlock one extra tube.", 370, 22, Color("c3cedc"))
	centered_text("Desktop ad preview — no real advertisement", 420, 16, Color("8e9caf"))
	var complete := button_at("Preview  3", Rect2(150, 520, 420, 78), complete_preview_reward, Color("447c78"))
	complete.disabled = true
	button_at("Cancel", Rect2(150, 625, 420, 68), cancel_reward, Color("42536c"))
	ui = previous
	L.restyle_tree(reward_ui)
	refresh()
	var request_id := pending_reward
	for count in [2, 1, 0]:
		await get_tree().create_timer(1.0).timeout
		if request_id != pending_reward or not is_instance_valid(complete):
			return
		complete.text = L.t("Complete test video" if count == 0 else "Preview  %d" % count)
	complete.disabled = false

func cancel_reward() -> void:
	ads.finish_reward(pending_reward, ads.Result.CANCELLED)
	pending_reward = -1
	if is_instance_valid(reward_ui):
		reward_ui.queue_free()
	reward_ui = null
	refresh()

func complete_preview_reward() -> void:
	ads.finish_reward(pending_reward, ads.Result.COMPLETED)
	pending_reward = -1
	if is_instance_valid(reward_ui):
		reward_ui.queue_free()
	reward_ui = null
	refresh()

func on_tube_reward(id: int) -> void:
	if id != pending_reward or rewarded_level != level_index or screen != "game":
		return
	if pending_reward_kind=="undo":
		undo_left += 3
		undo()
	else:
		add_tube()

func on_reward_finished(id: int, _earned: bool) -> void:
	if id != pending_reward:
		return
	pending_reward = -1
	if is_instance_valid(reward_ui):
		reward_ui.queue_free()
	reward_ui = null
	if not _earned:
		playtest.event("video_unavailable" if ads.last_result==ads.Result.UNAVAILABLE else "video_cancelled")
		message="Video unavailable. Your game is unchanged." if ads.last_result==ads.Result.UNAVAILABLE else "Video closed before the reward."
	refresh()

func get_banner_rect() -> Rect2:
	var extent:=get_viewport_rect().size
	var height:=102.0
	if layout_banner_override>0:height=layout_banner_override
	if is_instance_valid(ads) and ads.banner_height_pixels>0:
		var physical:=DisplayServer.window_get_size()
		if physical.y>0:height=maxf(height,ads.banner_height_pixels*extent.y/physical.y)
	height+=safe_insets().y
	return Rect2(-position.x,extent.y-position.y-height,extent.x,height)

func next_level() -> void:
	if level_index + 1 < unlocked and level_index + 1 < levels.size():
		load_level(level_index + 1)
		playtest.begin(level_index,persistence_enabled)
		begin_round_story()

func state_key(state: Array) -> String:
	var parts: Array = []
	for tube in state:
		parts.append(str(tube))
	parts.sort()
	return str(parts)

func show_hint() -> void:
	if busy or won:
		return
	var certified_key := ordered_key(tubes)
	if solution_lookup.has(certified_key):
		hint_pair = solution_lookup[certified_key].duplicate()
		selected = int(hint_pair[0])
		message = "Tube %d  >  Tube %d" % [hint_pair[0] + 1, hint_pair[1] + 1]
		refresh()
		return
	var frontier: Array = [[tubes.duplicate(true), []]]
	var visited := {state_key(tubes): true}
	var cursor := 0
	busy = true
	message = "Finding a little help…"
	refresh()
	while cursor < frontier.size() and cursor < 18000:
		if cursor % 256 == 0:
			await get_tree().process_frame
		var item: Array = frontier[cursor]
		cursor += 1
		var state: Array = item[0]
		var first: Array = item[1]
		if not first.is_empty() and (solved(state) or solution_lookup.has(ordered_key(state))):
			hint_pair = first
			selected = int(first[0])
			message = "Tube %d  >  Tube %d" % [first[0] + 1, first[1] + 1]
			busy = false
			refresh()
			return
		var empty_seen := false
		for dst in range(state.size()):
			if state[dst].is_empty():
				if empty_seen:
					continue
				empty_seen = true
			for src in range(state.size()):
				if not legal(state, src, dst) or is_complete(state[src]):
					continue
				var copy: Array = state.duplicate(true)
				copy[dst].append(copy[src].pop_back())
				var key := state_key(copy)
				if not visited.has(key):
					visited[key] = true
					frontier.append([copy, [src, dst] if first.is_empty() else first])
	busy = false
	message = "Try Undo or Reset to find a fresh path."
	refresh()

func ordered_key(state: Array) -> String:
	var parts := PackedStringArray()
	for tube in state:
		var cats := PackedStringArray()
		for cat in tube:
			cats.append(str(int(cat)))
		parts.append(",".join(cats))
	return "|".join(parts)

func build_solution_lookup() -> void:
	solution_lookup.clear()
	var state: Array = levels[level_index]["tubes"].duplicate(true)
	for step in levels[level_index]["solution"]:
		var src := int(step[0])
		var dst := int(step[1])
		solution_lookup[ordered_key(state)] = [src, dst]
		state[dst].append(state[src].pop_back())

