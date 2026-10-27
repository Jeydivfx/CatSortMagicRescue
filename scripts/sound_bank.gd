extends Node

signal cue_played(name: String)

var enabled := true
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var cursor := 0
var sounds: Dictionary = {}
var music_enabled := true
const CAT_PITCHES = [1.02,0.98,1.04,1.06,0.96,1.08,1.03,0.95,1.05,1.00,1.07,.97]
var cat_last: Dictionary = {}
var meow_names: Array[String] = []
var voice_bags: Dictionary = {}
var recent_meows: Array[String] = []
var duck_tween: Tween
var last_jump := -1
var music_gain := 0.60
var mix_trims: Dictionary={}
var last_cues: Dictionary={}
var effects_gain := 0.80
var suspension_reasons: Dictionary = {}
var celebration: AudioStreamPlayer
var celebrating := false
const ENTRY_CUES = ["witch_laugh_entry", "witch_entry_broom", "witch_entry_spell"]

func _ready() -> void:
	if AudioServer.get_bus_index("Cat Effects")<0:
		AudioServer.add_bus();var bus:=AudioServer.bus_count-1
		AudioServer.set_bus_name(bus,"Cat Effects")
		var limiter:=AudioEffectLimiter.new();limiter.ceiling_db=-1.0;limiter.threshold_db=-1.0
		AudioServer.add_bus_effect(bus,limiter)
	if FileAccess.file_exists("res://assets/audio/runtime_mix.json"):
		mix_trims=JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/runtime_mix.json"))
	for name in ["tap", "meow", "land", "nope", "win"]:
		sounds[name] = load("res://assets/audio/%s.wav" % name)
	sounds["win"] = load("res://assets/audio/soft_victory.wav")
	sounds["purchase"] = load("res://assets/audio/hint_purchase.wav")
	for name in ["tap","land","nope","purchase","win"]:
		sounds[name] = load("res://assets/audio/sfx_v2/%s.wav" % name)
	for index in range(1,4):
		sounds["hud_star_%d" % index] = sounds["purchase"]
	sounds["spell_break"] = load("res://assets/audio/sfx_v2/spell_break.wav")
	sounds["escape"] = load("res://assets/audio/sfx_v2/escape.wav")
	sounds["witch_laugh"] = load("res://assets/audio/sfx_v2/witch_laugh.wav")
	sounds["witch_laugh_entry"] = load("res://assets/audio/sfx_v2/witch_laugh_entry.wav")
	for cue in ["witch_entry_broom", "witch_entry_spell"]:
		sounds[cue] = load("res://assets/audio/sfx_v2/%s.wav" % cue)
	sounds["witch_laugh_loss"] = load("res://assets/audio/sfx_v2/witch_laugh_loss.wav")
	sounds["witch_upset"] = load("res://assets/audio/sfx_v2/witch_upset.wav")
	sounds["staff_thud"] = load("res://assets/audio/sfx_v2/staff_thud.wav")
	for i in range(3):
		sounds["star_%d" % i] = load("res://assets/audio/star_%d.wav" % i)
		sounds["jump_%d" % i] = load("res://assets/audio/sfx_v2/jump_%d.wav" % i)
	for i in range(4):
		sounds["kitten_%d" % i] = load("res://assets/audio/kitten_%d.wav" % i)
	for name in ["food", "soft", "purr", "chirp", "classic"]:
		sounds[name] = load("res://assets/audio/real_%s.wav" % name)
	var recordings: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/meows.json"))
	for recording in recordings:
		var key: String = recording["id"]
		sounds[key] = load("res://assets/audio/sfx_v2/cat_%s.wav" % key)
		meow_names.append(key)
	for i in range(6):
		var voice := AudioStreamPlayer.new()
		voice.bus="Cat Effects"
		voice.volume_db = -12
		add_child(voice)
		voices.append(voice)
	music = AudioStreamPlayer.new()
	var stream: AudioStreamOggVorbis = load("res://assets/audio/clear_air.ogg")
	stream.loop = true
	music.stream = stream
	music.volume_db = music_base_db()
	add_child(music)
	celebration = AudioStreamPlayer.new()
	celebration.bus="Cat Effects"
	celebration.stream = load("res://assets/audio/victory_dance.wav")
	add_child(celebration)
	celebration.finished.connect(stop_celebration)
	set_enabled(enabled)
	# The owning scene restores saved audio preferences before starting music.

func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		stop_celebration()
		for voice in voices:
			voice.stop()

func set_music_enabled(value: bool) -> void:
	music_enabled = value
	if not is_instance_valid(music):
		return
	if value and DisplayServer.get_name() != "headless":
		if not music.playing:
			music.play()
		music.stream_paused = celebrating or not suspension_reasons.is_empty()
	else:
		music.stop()

func music_base_db() -> float:
	return -10.0 + linear_to_db(maxf(0.0001,music_gain))

func set_levels(music_level: float, effects_level: float) -> void:
	music_gain = clampf(music_level,0,1)
	effects_gain = clampf(effects_level,0,1)
	if is_instance_valid(duck_tween):
		duck_tween.kill()
	if is_instance_valid(music):
		music.volume_db = music_base_db()
	for voice in voices:
		voice.volume_db = float(voice.get_meta("base_db",-12.0))+linear_to_db(maxf(0.0001,effects_gain))
	if is_instance_valid(celebration):
		celebration.volume_db = -6.0+linear_to_db(maxf(0.0001,effects_gain))

func set_suspended(reason: String, value: bool) -> void:
	if value:
		suspension_reasons[reason] = true
		for voice in voices:
			voice.stop()
	else:
		suspension_reasons.erase(reason)
	if is_instance_valid(music):
		music.stream_paused = celebrating or not suspension_reasons.is_empty()
	if is_instance_valid(celebration):
		celebration.stream_paused = not suspension_reasons.is_empty()

func start_celebration() -> void:
	if not enabled or celebrating:
		return
	celebrating = true
	stop_cue("witch_laugh")
	stop_cue("witch_laugh_entry")
	stop_entry()
	stop_cue("witch_laugh_loss")
	if is_instance_valid(duck_tween): duck_tween.kill()
	music.stream_paused = true
	celebration.volume_db = -6.0+linear_to_db(maxf(0.0001,effects_gain))
	celebration.play()
	celebration.stream_paused = not suspension_reasons.is_empty()
	cue_played.emit("victory_dance")

func stop_cue(name: String) -> void:
	for voice in voices:
		if voice.get_meta("cue_name","")==name: voice.stop()

func stop_entry() -> void:
	for cue in ENTRY_CUES: stop_cue(cue)

func play_entry(style: int) -> void:
	stop_entry()
	play(ENTRY_CUES[clampi(style,0,ENTRY_CUES.size()-1)])

func stop_celebration() -> void:
	celebrating = false
	if is_instance_valid(celebration): celebration.stop()
	if is_instance_valid(music):
		music.volume_db = music_base_db()
		music.stream_paused = not suspension_reasons.is_empty()

func duck_music(depth: float, hold: float) -> void:
	if not music.playing:
		return
	if is_instance_valid(duck_tween):
		duck_tween.kill()
	duck_tween = create_tween()
	duck_tween.tween_property(music,"volume_db",music_base_db()-depth,0.12)
	duck_tween.tween_interval(hold)
	duck_tween.tween_property(music,"volume_db",music_base_db(),0.8).set_trans(Tween.TRANS_SINE)

func play(name: String) -> void:
	if name == "jump":
		last_jump = (last_jump+randi_range(1,2))%3
		name = "jump_%d" % last_jump
	if name == "meow":
		play_cat(0)
		return
	if not enabled or not suspension_reasons.is_empty() or not sounds.has(name):
		return
	var now:=Time.get_ticks_msec()
	if now-int(last_cues.get(name,-10000))<(45 if name in ["tap","land"] else 100):return
	last_cues[name]=now
	cue_played.emit(name)
	var voice: AudioStreamPlayer = voices[cursor % voices.size()]
	cursor += 1
	voice.stream = sounds[name]
	voice.set_meta("cue_name",name)
	voice.pitch_scale = 1.0+0.08*(int(name.trim_prefix("hud_star_"))-1) if name.begins_with("hud_star_") else 1.0
	var base_db := -11.0 if name == "win" else (-17.0 if name.begins_with("star_") else -14.0)
	if name.begins_with("hud_star_"):
		base_db = -8.0
	elif name=="spell_break":
		base_db = -5.0
	elif name=="escape":
		base_db = -7.0
	elif name=="witch_upset":
		base_db = -6.0
	elif name=="staff_thud":
		base_db = -8.0
	elif name=="witch_laugh_entry":
		base_db = -16.0
	elif name in ["witch_entry_broom", "witch_entry_spell"]:
		base_db = -20.0
	if mix_trims.has(name):base_db=float(mix_trims[name])
	voice.set_meta("base_db",base_db)
	voice.volume_db = base_db + linear_to_db(maxf(0.0001,effects_gain))
	voice.play()
	if name == "win":
		duck_music(7,1.55)
	elif name.begins_with("hud_star_"):
		duck_music(4,0.2)
	elif name in ["witch_laugh","witch_laugh_loss","witch_laugh_entry"]:
		duck_music(3,3.8 if name=="witch_laugh_loss" else 1.3)
	elif name in ["witch_entry_broom", "witch_entry_spell"]:
		duck_music(2,.7)

func choose_cat_voice(cat_kind: int) -> Dictionary:
	var kind := clampi(cat_kind, 0, CAT_PITCHES.size()-1)
	var bag: Array = voice_bags.get(kind, [])
	if bag.is_empty():
		bag = meow_names.duplicate()
		bag.shuffle()
	var chosen := ""
	for candidate in bag:
		if not recent_meows.has(candidate) and candidate != cat_last.get(kind, ""):
			chosen = candidate
			break
	# A nearly exhausted bag may contain only globally recent recordings. Play
	# another eligible take now; retain the remaining bag for the next call.
	if chosen.is_empty():
		for candidate in meow_names:
			if not recent_meows.has(candidate) and candidate != cat_last.get(kind, ""):
				chosen = candidate
				break
	bag.erase(chosen)
	voice_bags[kind] = bag
	cat_last[kind] = chosen
	recent_meows.append(chosen)
	if recent_meows.size() > 6:
		recent_meows.pop_front()
	return {"source": chosen, "pitch": CAT_PITCHES[kind]}

func play_cat(cat_kind: int) -> void:
	if not enabled or not suspension_reasons.is_empty():
		return
	var choice := choose_cat_voice(cat_kind)
	cue_played.emit("cat")
	var voice: AudioStreamPlayer = voices[cursor % voices.size()]
	cursor += 1
	voice.stream = sounds[choice["source"]]
	voice.set_meta("cue_name","cat")
	voice.pitch_scale = float(choice["pitch"]) * randf_range(0.99, 1.01)
	voice.set_meta("base_db",-9.0)
	voice.volume_db = -9.0 + linear_to_db(maxf(0.0001,effects_gain))
	voice.play()
	duck_music(5,0.7)

func play_soft_cat(cat_kind: int) -> void:
	if not enabled or not suspension_reasons.is_empty(): return
	play_cat(cat_kind)
	var voice: AudioStreamPlayer = voices[(cursor-1)%voices.size()]
	voice.set_meta("base_db",-16.0)
	voice.volume_db = -16.0+linear_to_db(maxf(.0001,effects_gain))

func play_chorus(cat_kind: int, finale: bool = false) -> void:
	if not enabled or not suspension_reasons.is_empty(): return
	# Three actual cat recordings, softened before summing, form one rescue call.
	stop_cue("cat")
	stop_cue("cat_chorus")
	cue_played.emit("cat_chorus_final" if finale else "cat_chorus")
	for i in range(3):
		var choice := choose_cat_voice(cat_kind)
		var voice: AudioStreamPlayer = voices[cursor%voices.size()]
		cursor += 1
		voice.stream = sounds[choice.source]
		voice.set_meta("cue_name","cat_chorus")
		voice.pitch_scale = float(choice.pitch)*[.96,1.0,1.04][i]
		voice.set_meta("base_db",-16.0)
		voice.volume_db = -16.0+linear_to_db(maxf(.0001,effects_gain))
		voice.play()
	duck_music(5,.7)

func _exit_tree() -> void:
	stop_celebration()
	if is_instance_valid(music):
		music.stop()
		music.stream = null
	for voice in voices:
		voice.stop()
		voice.stream = null
