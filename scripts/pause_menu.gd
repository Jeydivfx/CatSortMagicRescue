extends RefCounted
const L=preload("res://scripts/localization.gd")
static func build(g) -> void:
	var p=Panel.new();p.name="PausePanel";p.position=Vector2(85,120);p.size=Vector2(550,784);p.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var skin=g.panel(Color(.035,.075,.15,.94),36,Color("8eaed6"));skin.border_width_left=2;skin.border_width_right=2;skin.border_width_top=2;skin.border_width_bottom=2
	skin.shadow_color=Color(0,0,0,.4);skin.shadow_size=14;p.add_theme_stylebox_override("panel",skin);g.ui.add_child(p)
	g.centered_text("Pause",155,48,Color("fff4df"))
	g.centered_text("Take a little break",222,22,Color("a5bce5"))
	var back=g.button_at("",Rect2(110,145,64,64),g.resume_game,Color("7951b1"));back.symbol="back";back.compact=true
	var decoration=Control.new();decoration.size=Vector2(720,1120);decoration.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(decoration)
	decoration.draw.connect(func():
		for y in [290,730]:
			decoration.draw_line(Vector2(130,y),Vector2(342,y),Color("7090b6"),1.2,true)
			decoration.draw_line(Vector2(378,y),Vector2(590,y),Color("7090b6"),1.2,true)
			decoration.draw_colored_polygon(PackedVector2Array([Vector2(360,y-7),Vector2(367,y),Vector2(360,y+7),Vector2(353,y)]),Color("a9bbd8")))
	var resume=g.button_at("Resume",Rect2(145,330,430,92),g.resume_game,Color("408f7d"));resume.symbol="play";resume.title_size=36
	var restart=g.button_at("Restart level",Rect2(145,455,430,86),func():g.start_game(g.level_index,true),Color("8650bb"));restart.symbol="undo";restart.title_size=29
	var home=g.button_at("Home",Rect2(145,578,430,86),func():g.show_menu(),Color("476a9e"));home.symbol="home";home.title_size=32
	for i in range(2):
		var music: bool=i==0
		var enabled: bool=g.music_enabled if music else g.sound_enabled
		var action=func():
			if music:g.music_enabled=not g.music_enabled;g.audio.set_music_enabled(g.music_enabled)
			else:g.sound_enabled=not g.sound_enabled;g.audio.set_enabled(g.sound_enabled)
			g.save_progress();g.show_menu("pause")
		var b=preload("res://scripts/pause_audio_toggle.gd").new()
		b.name="PauseMusic" if music else "PauseEffects"
		b.music=music;b.enabled=enabled;b.size=Vector2(220,104);b.layout_direction=Control.LAYOUT_DIRECTION_LTR
		b.pressed.connect(action);g.ui.add_child(b);b.position=Vector2(125+i*250,775)
