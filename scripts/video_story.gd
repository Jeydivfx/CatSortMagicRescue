extends Control
## User-authored film, one uninterrupted stream; music and shot audio obey separate settings.
signal finished
const L = preload("res://scripts/localization.gd")
var game
var player: VideoStreamPlayer
var score: AudioStreamPlayer
var skip: Button
var ended := false
var duration := 41.5
var resize_callback: Callable
var subtitle: Label
var subtitle_card: Panel
var subtitles: Array=[]

func setup(owner_game, _world: int = -1) -> void:
	game=owner_game
	z_index=50
	layout_direction=Control.LAYOUT_DIRECTION_LTR
	mouse_filter=Control.MOUSE_FILTER_STOP
	clip_contents=true
	var black:=ColorRect.new()
	black.color=Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(black)
	player=VideoStreamPlayer.new()
	player.expand=true
	player.mouse_filter=Control.MOUSE_FILTER_IGNORE
	player.stream=load("res://assets/video/magic_rescue_intro.ogv")
	add_child(player)
	score=AudioStreamPlayer.new()
	score.stream=load("res://assets/video/intro_music.ogg")
	add_child(score)
	skip=Button.new()
	skip.text=L.t("Skip")
	skip.add_theme_font_size_override("font_size",22)
	skip.add_theme_stylebox_override("normal",game.panel(Color(.035,.04,.10,.72),22,Color(.8,.8,.9,.4)))
	skip.pressed.connect(finish_story)
	add_child(skip)
	subtitles=JSON.parse_string(FileAccess.get_file_as_string("res://assets/video/subtitles.json"))
	subtitle_card=Panel.new();subtitle_card.mouse_filter=Control.MOUSE_FILTER_IGNORE
	subtitle_card.add_theme_stylebox_override("panel",game.panel(Color(.025,.035,.07,.78),18,Color(0,0,0,0)))
	add_child(subtitle_card)
	subtitle=Label.new();L.style(subtitle);subtitle.mouse_filter=Control.MOUSE_FILTER_IGNORE
	subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;subtitle.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;subtitle.add_theme_font_size_override("font_size",24)
	subtitle.add_theme_color_override("font_color",Color("fff3d8"));add_child(subtitle)
	game.audio.stop_entry()
	game.audio.set_suspended("intro_video",true)
	game.ads.set_banner_hidden(true)
	resize_callback=layout_video
	get_viewport().size_changed.connect(resize_callback)
	layout_video()
	player.finished.connect(finish_story)
	player.play()
	score.play()
	_process(0)

func layout_video() -> void:
	if not is_instance_valid(game):return
	size=get_viewport_rect().size
	position=-game.position
	# Cover the phone viewport without stretching. Excess edges are clipped.
	var scale_factor:=maxf(size.x/720.0,size.y/1280.0)
	player.size=Vector2(720,1280)*scale_factor
	player.position=(size-player.size)*.5
	var safe_top: float=game.content_rect().position.y+game.position.y
	skip.position=Vector2(size.x-132,maxf(20,safe_top+16))
	skip.size=Vector2(112,52)
	if is_instance_valid(subtitle):
		subtitle_card.position=Vector2(24,size.y-game.safe_insets().y-112);subtitle_card.size=Vector2(size.x-48,84)
		subtitle.position=subtitle_card.position+Vector2(12,6);subtitle.size=subtitle_card.size-Vector2(24,12)

func _process(_delta: float) -> void:
	if ended or not is_instance_valid(player):return
	var paused:=false
	for reason in game.audio.suspension_reasons:
		if reason!="intro_video":paused=true
	player.paused=paused
	score.stream_paused=paused
	player.volume_db=linear_to_db(maxf(.00001,game.audio.effects_gain)) if game.audio.enabled else -80.0
	score.volume_db=linear_to_db(maxf(.00001,game.audio.music_gain)) if game.audio.music_enabled else -80.0
	var line:=""
	for cue in subtitles:
		if player.stream_position>=cue.start and player.stream_position<cue.end:line=L.t(cue.text);break
	if subtitle.text!=line:
		subtitle.text=line
		var font:=subtitle.get_theme_font("font")
		var font_size:=24
		while font_size>18 and font.get_multiline_string_size(line,HORIZONTAL_ALIGNMENT_CENTER,subtitle.size.x,font_size).y>subtitle.size.y-4:font_size-=1
		subtitle.add_theme_font_size_override("font_size",font_size)
	subtitle.visible=not line.is_empty();subtitle_card.visible=subtitle.visible

func release_media() -> void:
	if is_instance_valid(player):player.stop()
	if is_instance_valid(score):score.stop()
	if is_instance_valid(game):
		game.audio.set_suspended("intro_video",false)
		game.ads.set_banner_hidden(false)
	if get_viewport().size_changed.is_connected(resize_callback):get_viewport().size_changed.disconnect(resize_callback)

func finish_story() -> void:
	if ended:return
	ended=true
	release_media()
	finished.emit()
	queue_free()

func cancel() -> void:
	if ended:return
	ended=true
	release_media()
	queue_free()

func _exit_tree() -> void:
	if not ended:release_media()
