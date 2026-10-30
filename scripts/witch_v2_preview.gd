extends Control
var actor
var clock:=0.0
var clip_age:=0.0
var state:="evil_idle"
var next_gesture:=7.0
var quiet:=true
var title: Label
func _ready() -> void:
	var background:=ColorRect.new();background.color=Color("17283c");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
	actor=preload("res://scripts/witch_animator_v2.gd").new();add_child(actor);actor.configure();actor.nominal_height=420;actor.foot=Vector2(360,560)
	title=Label.new();title.position=Vector2(30,24);title.size=Vector2(660,50);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",27);add_child(title)
	var controls:=GridContainer.new();controls.columns=3;controls.position=Vector2(34,610);controls.size=Vector2(650,300);add_child(controls)
	for key in ["evil_idle","inspect_staff","evil_laugh","angry","evil_spell","shocked","mock_player","nervous","panic","defeated","fake_cry","broom_entry"]:
		var button:=Button.new();button.text=key.replace("_"," ").capitalize();button.custom_minimum_size=Vector2(210,62);controls.add_child(button)
		button.pressed.connect(select.bind(key))
	var note:=Label.new();note.text="Same art • fixed scale • fixed root\nIdle → occasional gesture → idle";note.position=Vector2(30,940);note.size=Vector2(660,70);note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(note)
func select(key: String) -> void:
	state=key;clip_age=0;quiet=key=="evil_idle";next_gesture=clock+7
	if key=="evil_idle":actor.reset()
func _process(delta: float) -> void:
	clock+=delta;clip_age+=delta
	if quiet and clock>=next_gesture:
		state="inspect_staff" if int(clock)%2==0 else "taunt";clip_age=0;quiet=false
	if not quiet and clip_age>=actor.duration(state):
		state="defeated_idle" if state in ["defeated","fake_cry"] else "evil_idle";clip_age=0;quiet=state=="evil_idle";next_gesture=clock+7
	actor.clock=clock;actor.sample(state,clip_age);title.text=state.replace("_"," ").capitalize()
