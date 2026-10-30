extends RefCounted
const L=preload("res://scripts/localization.gd")
static func plate(g,rect:Rect2,fill:String,border:String,radius:int=22)->Panel:
	var p=Panel.new();p.layout_direction=Control.LAYOUT_DIRECTION_LTR;p.mouse_filter=Control.MOUSE_FILTER_IGNORE;p.size=rect.size;p.add_theme_stylebox_override("panel",g.panel(Color(fill),radius,Color(border)));g.ui.add_child(p);p.position=rect.position;return p
static func label(g,value:String,rect:Rect2,font:int=21,color:String="fff5e5",center:bool=false)->Label:
	var l=Label.new();L.style(l);l.text=L.t(value);l.size=rect.size;l.add_theme_font_size_override("font_size",font);l.add_theme_color_override("font_color",Color(color));l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if center else (HORIZONTAL_ALIGNMENT_RIGHT if L.rtl() else HORIZONTAL_ALIGNMENT_LEFT);l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(l);l.position=rect.position;return l
static func build(g)->void:
	var panel=plate(g,Rect2(60,40,600,1010),"0b1b33","859dcd",30);panel.name="SettingsPanel"
	var back=g.button_at("",Rect2(74,54,60,60),func():g.show_menu(),Color("7951b1"));back.symbol="back";back.compact=true
	label(g,"Settings",Rect2(160,54,400,62),37,"fff5e5",true)
	for section in [[138,178,"Sound"],[332,112,"Graphics"],[460,156,"World"],[632,108,"Language"],[756,184,"About"]]:
		plate(g,Rect2(78,section[0],564,section[1]),"0c203a","2a4265",22)
		label(g,section[2],Rect2(102,section[0]+8,400,34),24,"ffe1b4")
	for i in range(2):
		var music:bool=i==0;var y:float=195+i*60
		var icon=preload("res://scripts/pause_audio_toggle.gd").new();icon.music=music;icon.enabled=g.music_enabled if music else g.sound_enabled;icon.switch_only=true;icon.size=Vector2(102,40)
		icon.name="SettingsMusic" if music else "SettingsEffects";icon.pressed.connect(func():
			if music:g.music_enabled=not g.music_enabled;g.audio.set_music_enabled(g.music_enabled)
			else:g.sound_enabled=not g.sound_enabled;g.audio.set_enabled(g.sound_enabled)
			g.save_progress();g.show_menu("settings"))
		g.ui.add_child(icon);icon.position=Vector2(246,y)
		label(g,"Music" if music else "Effects",Rect2(163,y,80,40),20)
		var drawing=Control.new();drawing.size=Vector2(720,1120);drawing.set_meta("l10n_x",0);drawing.layout_direction=Control.LAYOUT_DIRECTION_LTR;drawing.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(drawing)
		drawing.draw.connect(func():
			var c=Color("ffe1b4");var p=Vector2(130,y+19)
			if music:
				drawing.draw_line(p+Vector2(-3,-13),p+Vector2(-3,10),c,3,true);drawing.draw_line(p+Vector2(12,-17),p+Vector2(12,6),c,3,true);drawing.draw_line(p+Vector2(-3,-13),p+Vector2(12,-17),c,5,true);drawing.draw_circle(p+Vector2(-8,11),6,c);drawing.draw_circle(p+Vector2(7,7),6,c)
			else:
				drawing.draw_colored_polygon(PackedVector2Array([p+Vector2(-15,-6),p+Vector2(-8,-6),p+Vector2(0,-14),p+Vector2(0,14),p+Vector2(-8,6),p+Vector2(-15,6)]),c)
				for r in [9,16]:drawing.draw_arc(p,r,-.8,.8,24,c,2,true))
		var slider=HSlider.new();slider.name="MusicVolume" if music else "EffectsVolume";slider.min_value=0;slider.max_value=1;slider.step=.01;slider.value=g.music_volume if music else g.effects_volume;slider.size=Vector2(198,40)
		for state in ["slider","grabber_area","grabber_area_highlight"]:
			var skin=g.panel(Color("9857dc") if state!="slider" else Color("263e61"),6,Color.TRANSPARENT);skin.content_margin_top=5;skin.content_margin_bottom=5;slider.add_theme_stylebox_override(state,skin)
		var image=Image.create(28,28,false,Image.FORMAT_RGBA8);image.fill(Color.TRANSPARENT)
		for x in range(28):
			for z in range(28):
				if Vector2(x-13.5,z-13.5).length()<12.5:image.set_pixel(x,z,Color("e8dafa"))
		var texture=ImageTexture.create_from_image(image)
		for state in ["grabber","grabber_highlight","grabber_disabled"]:slider.add_theme_icon_override(state,texture)
		slider.value_changed.connect(func(v):
			if music:g.music_volume=v
			else:g.effects_volume=v
			g.audio.set_levels(g.music_volume,g.effects_volume);g.save_progress())
		g.ui.add_child(slider);slider.position=Vector2(414,y);label(g,"◖))",Rect2(371,y,38,40),18,"9daed1")
	label(g,"Animation",Rect2(102,383,130,46),19)
	plate(g,Rect2(238,380,386,52),"1b304f","435b83",16)
	for i in range(2):
		var chosen:bool=g.reduced_motion if i==1 else not g.reduced_motion
		var b=g.button_at(["Full","Reduced"][i],Rect2(240+i*192,382,190,48),func():g.animation_off=false;g.reduced_motion=i==1;g.save_progress();g.show_menu("settings"),Color("8752b7") if chosen else Color("263b5b"));b.title_size=19;b.name="AnimationMode"+str(i)
	label(g,"Background theme",Rect2(102,498,480,30),18)
	var wi:int=g.EnvironmentCatalog.for_level(g.level_index,g.environment_override);var world=g.EnvironmentCatalog.WORLDS[wi]
	var wb=g.button_at("",Rect2(100,532,524,72),func():g.environment_override=((g.environment_override+2)%(g.EnvironmentCatalog.WORLDS.size()+1))-1;g.apply_environment();g.save_progress();g.show_menu("settings"),Color("283f60"));wb.name="SettingsWorld";wb.caption_override=" "
	var preview=TextureRect.new();preview.texture=load(world.file);preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;preview.stretch_mode=TextureRect.STRETCH_SCALE;preview.size=Vector2(164,60);preview.mouse_filter=Control.MOUSE_FILTER_IGNORE;wb.add_child(preview);preview.position=Vector2(8,6)
	label(g,("Auto" if g.environment_override<0 else str(world.name)),Rect2(296,543,270,48),21);label(g,"›",Rect2(588,543,30,48),32)
	var globe=Control.new();globe.size=Vector2(720,1120);globe.set_meta("l10n_x",0);globe.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(globe)
	globe.draw.connect(func():
		var c=Color("ffe1b4");var p=Vector2(128,709)
		globe.draw_arc(p,16,0,TAU,48,c,2,true)
		globe.draw_line(p-Vector2(16,0),p+Vector2(16,0),c,1.5,true)
		for y in [-8,8]:globe.draw_line(p+Vector2(-13,y),p+Vector2(13,y),c,1.5,true)
		globe.draw_set_transform(p,0,Vector2(.45,1));globe.draw_arc(Vector2.ZERO,16,0,TAU,48,c,2,true);globe.draw_set_transform(Vector2.ZERO))
	var languages=OptionButton.new();languages.name="LanguageSelector";L.style(languages);languages.size=Vector2(464,49);languages.add_theme_font_size_override("font_size",21)
	for n in L.NAMES:languages.add_item(n)
	languages.select(L.CODES.find(g.language));languages.item_selected.connect(func(index):g.change_language(L.CODES[index]);g.show_menu("settings"))
	for state in ["normal","hover","pressed"]:languages.add_theme_stylebox_override(state,g.panel(Color("1c3252"),14,Color("435b83")))
	g.ui.add_child(languages);languages.position=Vector2(160,686);languages.size.y=42
	var story=g.button_at("Our story",Rect2(100,801,252,52),func():g.play_story(-1,true),Color("7952a2"));story.title_size=21
	var credits=g.button_at("Audio credits",Rect2(370,801,252,52),func():g.show_menu("credits"),Color("4a6f9a"));credits.title_size=20
	var profile=g.button_at("Change name and avatar",Rect2(100,877,524,50),func():preload("res://scripts/name_entry.gd").show(g,false,true),Color("4a6f9a"));profile.name="SettingsProfile";profile.title_size=20
	var done=g.button_at("Done",Rect2(88,958,544,68),func():g.show_menu(),Color("4a9877"));done.name="SettingsDone";done.title_size=32
