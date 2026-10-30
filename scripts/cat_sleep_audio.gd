extends Node
# One very quiet real-cat purr/breath layer shared by all visible sleeping kittens.
var player: AudioStreamPlayer
var gain:=0.0
var clock:=0.0
var next_purr:=0.0
var visible_sleepers:=0
func _ready() -> void:
	player=AudioStreamPlayer.new();player.bus="Cat Effects"
	player.stream=preload("res://assets/audio/sfx_v2/sleep_purr.wav")
	player.stream=player.stream.duplicate()
	player.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
	player.stream.loop_begin=0
	player.stream.loop_end=int(player.stream.get_length()*player.stream.mix_rate)
	player.volume_db=-80;add_child(player)
func stop_immediately() -> void:
	gain=0
	if is_instance_valid(player):player.stop()
func _process(delta: float) -> void:
	var bank=get_parent()
	clock+=delta
	if not bank.enabled or not bank.suspension_reasons.is_empty() or bank.celebrating:
		visible_sleepers=0;stop_immediately();return
	visible_sleepers=0
	for sleeper in get_tree().get_nodes_in_group("sleeping_cat_audio"):
		if is_instance_valid(sleeper) and sleeper.is_visible_in_tree():visible_sleepers+=1
	var target:=1.0 if visible_sleepers>0 and bank.effects_gain>.001 else 0.0
	gain=move_toward(gain,target,delta/(.9 if target>gain else .18))
	if gain<=.001:
		player.stop();return
	player.volume_db=-22.0+linear_to_db(maxf(.0001,gain*bank.effects_gain))
	if target>0 and not player.playing:
		player.pitch_scale=1.0
		player.play()
		bank.cue_played.emit("sleep_purr")
