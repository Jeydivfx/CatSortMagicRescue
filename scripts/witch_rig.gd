extends Control

signal laugh_started
signal irritation_started
signal cry_started
signal defeat_started
signal magic_impact
signal staff_impact
signal loss_laugh_started
signal entry_laugh_started
const INK := Color("34253f")
var gentle := false
var gaze_target := Vector2.ZERO
var gaze := Vector2.ZERO
var gesture_kind := 0
var gesture_age := 10.0
var gesture_duration := 1.8
var gesture_envelope := 0.0
var next_gesture := 4.0
var age := 0.0
var cast_count := 0
var angry := false
var emotion := 0
var next_laugh := 6.0
var laugh_left := 0.0
var laugh_duration := 1.8
var angry_age := 0.0
var irritation_left := 0.0
var defeated := false
var cry_emitted := false
var defeat_age := 0.0
var impact_played := false
var allow_idle := true
var last_activity := 0.0
var near_win := false
var progress_tension:=0.0
var player_lost := false
var reaction := ""
var reaction_left := 0.0
var reaction_age := 0.0
var reaction_cooldown := 0.0
var sort_impact_played := false
var surprise := 0.0
var delight := 0.0
var nervous := 0.0
var spells: Array[Dictionary] = []
var next_magic := 0.0
var idle_taunts := 0
var casting_age := 10.0
var entry_flying := false
var flight_style := 0
var entry_progress := 0.0
var anger := 0.0
var laughter := 0.0
var blink := 0.0
var sleeping := false
var idle_sleeping:=false
var sleep_fx:Node2D
var snore:AudioStreamPlayer
var vocal_open := 0.0
var reclining := false
var story_walk := 0.0
var story_wake := -1.0
var cover_ears := 0.0
var body: Node2D
var head: Node2D
var hat: Node2D
var left_arm: Node2D
var right_arm: Node2D
var rig_root: Node2D
var feet: Node2D
var frames
var frame_state:=""
var frame_started:=0.0
var near_win_since:=0.0
var effects_layer: Node2D
var queued_sort:=false

func part(parent: Node, painter: Callable) -> Node2D:
	var node := Node2D.new()
	parent.add_child(node)
	node.draw.connect(func(): painter.call(node))
	return node

func _ready() -> void:
	sleep_fx=Node2D.new();sleep_fx.z_index=20;add_child(sleep_fx);sleep_fx.draw.connect(draw_sleep_marks)
	snore=AudioStreamPlayer.new();snore.bus="Cat Effects";snore.stream=preload("res://assets/audio/sfx_v2/witch_snore.wav");add_child(snore)
	snore.stream=snore.stream.duplicate();snore.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;snore.stream.loop_end=int(snore.stream.get_length()*snore.stream.mix_rate)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ground_shadow=part(self,func(n):
		# Cast shadow and foot contact share a fixed ground anchor. Equal z
		# with the character keeps it above the parent's painted backdrop.
		for i in range(20,0,-1):
			var f: float=i/20.0
			n.draw_set_transform(Vector2(110,210),-.10,Vector2(1,.25))
			n.draw_circle(Vector2.ZERO,62*f,Color(.018,.012,.033,.025*(1.25-f*.4)))
			n.draw_set_transform(Vector2.ZERO)
		for i in range(10,0,-1):
			n.draw_set_transform(Vector2(100.8,209),0,Vector2(1,.15))
			n.draw_circle(Vector2.ZERO,i*3.6,Color(.012,.008,.025,.035))
			n.draw_set_transform(Vector2.ZERO))
	ground_shadow.z_index=0
	rig_root = Node2D.new()
	rig_root.scale = Vector2.ONE*1.58
	add_child(rig_root)
	feet = part(rig_root,draw_feet)
	left_arm = part(rig_root,func(n): draw_arm(n,false))
	body = part(rig_root,draw_body)
	right_arm = part(rig_root,func(n): draw_arm(n,true))
	head = part(rig_root,draw_head)
	hat = part(head,draw_hat)
	effects_layer = part(rig_root,draw_effects)
	effects_layer.z_index=2
	frames=preload("res://scripts/witch_animator_v2.gd").new();add_child(frames)
	frames.nominal_height=230;frames.foot=Vector2(100.8,208.8)
	if not frames.configure("witch"):frames.free();frames=null
	pose()

func reset() -> void:
	queued_sort=false
	frame_state="";frame_started=age;near_win_since=age
	gesture_age=10
	gesture_envelope=0
	next_gesture=age+randf_range(6,9)
	if is_instance_valid(frames):frames.reset()
	sleeping = false
	vocal_open = 0
	reclining = false
	story_walk = 0
	story_wake = -1
	cover_ears = 0
	cast_count = 0
	idle_taunts = 0
	angry = false
	anger = 0
	laughter = 0
	emotion = 0
	laugh_left = 0
	laugh_duration = 1.8
	angry_age = 0
	irritation_left = 0
	defeated = false
	defeat_age = 0
	cry_emitted = false
	impact_played = false
	allow_idle = true
	near_win = false
	progress_tension=0
	player_lost = false
	reaction = ""
	reaction_left = 0
	reaction_age = 0
	reaction_cooldown = 0
	sort_impact_played = false
	surprise = 0
	delight = 0
	nervous = 0
	spells.clear()
	next_magic = age+2
	casting_age = 10
	entry_flying = false
	entry_progress = 0
	last_activity = age
	next_laugh = age+randf_range(5,9)
	if is_instance_valid(body): pose()

func cast(_target: Vector2) -> void:
	cast_count += 1

func story_laugh(duration: float) -> void:
	# A deliberate laugh overrides the previous casting/angry face.
	angry = false
	irritation_left = 0
	sleeping = false
	reaction = ""
	reaction_left = 0
	vocal_open = 0
	laugh_duration = maxf(.2,duration)
	laugh_left = laugh_duration
	reaction_age = 0

func begin_flight() -> void:
	laugh_duration = 1.8
	entry_flying = true
	entry_progress = 0
	laugh_left = 1.8 if flight_style==0 else 0.0
	allow_idle = false
	entry_laugh_started.emit()

func finish_flight() -> void:
	entry_flying = false
	entry_progress = 1
	feet.visible = true

func is_staff_dropped() -> bool:
	return defeated and defeat_age>1.08

func staff_position() -> Vector2:
	if is_instance_valid(frames):
		render_authored_frames()
		return frames.staff_anchor
	return Vector2(122,173)

func cast_obstacle() -> void:
	reaction = "curse"
	reaction_left = 2.8
	reaction_age = 0
	sort_impact_played = false
	laugh_left = 0

func react_to_sort() -> void:
	if reaction=="curse" and reaction_left>0:
		queued_sort=true
		return
	irritation_left = 1.0
	reaction = "sort"
	reaction_left = 2.8
	reaction_age = 0
	sort_impact_played = false
	laugh_left = 0
	angry_age = 0
	next_laugh = maxf(next_laugh,age+5)
	irritation_started.emit()

func note_move() -> void:
	idle_sleeping=false;sleeping=false
	if is_instance_valid(snore):snore.stop()
	last_activity = age
	next_laugh = maxf(next_laugh,age+8)
	if reaction=="idle":
		reaction_left = 0
		laugh_left = 0
		irritation_started.emit()

func set_near_win(value: bool) -> void:
	if value and not near_win:near_win_since=age
	near_win = value

func react_good_move() -> void:
	if defeated or player_lost or age<reaction_cooldown or reaction in ["sort","curse"] and reaction_left>0: return
	reaction = "surprise"
	reaction_left = 2.2
	reaction_age = 0
	reaction_cooldown = age+3
	laugh_left = 0

func react_mistake() -> void:
	if defeated or player_lost or reaction=="sort" and reaction_left>0 or age<reaction_cooldown: return
	reaction = "mistake"
	reaction_left = 2.6
	reaction_age = 0
	reaction_cooldown = age+3
	throw_magic(.6)

func celebrate_player_loss() -> void:
	player_lost = true
	angry = false
	defeated = false
	irritation_left = 0
	reaction = "loss"
	reaction_age = 0
	reaction_left = 999
	laugh_left = 4.4
	next_magic = age+.15
	loss_laugh_started.emit()

func clear_result() -> void:
	reset()

func defeat() -> void:
	if defeated: return
	defeated = true
	angry = true
	defeat_age = 0
	cry_emitted = false
	laugh_left = 0
	reaction = "defeat"
	reaction_left = 0
	defeat_started.emit()

func begin_gesture(kind: int) -> void:
	gesture_kind=kind%3
	gesture_age=0
	gesture_duration=[2.6,2.4,2.6][gesture_kind]
	next_gesture=age+gesture_duration+randf_range(6,9)

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		if is_instance_valid(snore):snore.stop()
		return
	age += delta
	var g=get_parent()
	while g!=null and not g.has_method("content_rect"):g=g.get_parent()
	var active_game= g.screen=="game" if g!=null else false
	idle_sleeping=active_game and allow_idle and not defeated and not player_lost and not entry_flying and age-last_activity>18.0 and reaction==""
	if idle_sleeping:sleeping=true;laugh_left=0
	elif not player_lost:sleeping=false
	var bank=g.get("audio") if g!=null else null
	var audible=idle_sleeping and bank!=null and bank.enabled and bank.suspension_reasons.is_empty()
	if audible:
		snore.volume_db=-26+linear_to_db(maxf(.0001,bank.effects_gain))
		if not snore.playing:snore.play()
	else:snore.stop()
	sleep_fx.queue_redraw()
	gaze = gaze.lerp(gaze_target,1-exp(-delta*7))
	gesture_age+=delta
	var can_gesture:=allow_idle and reaction=="" and not sleeping and not entry_flying and not defeated and not player_lost and not near_win and not angry
	if can_gesture and age>=next_gesture:begin_gesture((gesture_kind+1)%3)
	var gesture_target: float=pow(sin(clampf(gesture_age/gesture_duration,0,1)*PI),2) if can_gesture and gesture_age<gesture_duration else 0.0
	gesture_envelope=lerpf(gesture_envelope,gesture_target,1-exp(-delta*12))
	casting_age += delta
	for spell in spells:
		var previous_age:float=spell.age
		spell.age += delta
		if previous_age<spell.duration and spell.age>=spell.duration:magic_impact.emit()
	spells = spells.filter(func(spell): return spell.age<spell.duration+.5)
	if (player_lost and not sleeping or near_win) and age>=next_magic:
		throw_magic(1.0 if player_lost else .45)
		next_magic = age+(1.4 if player_lost else 3.2)
	reaction_age += delta
	reaction_left = maxf(0,reaction_left-delta)
	if reaction in ["sort","taunt","curse","mischief"] and reaction_age>=1.08 and not sort_impact_played:
		sort_impact_played = true
		staff_impact.emit()
		throw_magic(.85)
	if reaction_left<=0 and not defeated and not player_lost:
		reaction = ""
		if queued_sort:
			queued_sort=false
			react_to_sort()
	if defeated:
		defeat_age += delta
		if not cry_emitted and defeat_age>=2.1:
			cry_emitted=true
			cry_started.emit()
		if not impact_played and defeat_age>=1.08:
			impact_played = true
			staff_impact.emit()
			throw_magic(1.2)
	irritation_left = maxf(0,irritation_left-delta)
	var irritated := angry or irritation_left>0
	if allow_idle and not sleeping and not irritated and not player_lost and not near_win and reaction=="" and age-last_activity>=8 and age>=next_laugh:
		laugh_left = 2.8
		laugh_duration = 2.8
		reaction = "idle"
		reaction_left = 2.8
		reaction_age = 0
		next_laugh = age+randf_range(16,25)
		idle_taunts += 1
		if idle_taunts%2==0:
			reaction = "taunt"
			sort_impact_played = false
		laugh_started.emit()
	angry_age = angry_age+delta if irritated else 0.0
	laugh_left = maxf(0,laugh_left-delta)
	emotion = 2 if irritated else (1 if laugh_left>0 or player_lost else 0)
	anger = lerpf(anger,1.0 if irritated else 0.0,1-exp(-delta*7))
	var envelope := sin(clampf((laugh_duration-laugh_left)/laugh_duration,0,1)*PI) if laugh_left>0 and not irritated else 0.0
	if player_lost and laugh_left>0: envelope = sin(clampf((4.4-laugh_left)/4.4,0,1)*PI)*.85
	if entry_flying and flight_style==0: envelope = .7+.15*sin(age*8)
	laughter = lerpf(laughter,envelope,1-exp(-delta*14))
	surprise = lerpf(surprise,1.0 if reaction=="surprise" else 0.0,1-exp(-delta*9))
	delight = lerpf(delight,1.0 if reaction in ["mistake","loss"] else 0.0,1-exp(-delta*8))
	nervous = lerpf(nervous,1.0 if near_win and reaction_left<=0 and not entry_flying and not defeated and not player_lost else 0.0,1-exp(-delta*5))
	blink = pow(maxf(0,1-absf(fposmod(age,4.6)-.12)/.12),2)
	if sleeping: blink = 1
	if story_wake>=0: blink = maxf(blink,1-story_wake)
	if player_lost and reaction_age>4.8:
		sleeping = true
		blink = 1
		delight = 0
	cover_ears = lerpf(cover_ears,1.0 if reaction=="sort" or defeated and defeat_age<.3 else 0.0,1-exp(-delta*10))
	pose()

func pose() -> void:
	var motion := .25 if gentle else 1.0
	var breath := sin(age*1.9)*motion
	var chuckle := sin((laugh_duration-laugh_left)*12)*laughter*motion
	var hop := (1-cos(defeat_age*TAU*2.0))*4*motion if defeated else 0.0
	var dance := sin(age*4)*3*motion if player_lost and not sleeping else 0.0
	body.position = Vector2(84,116-breath*.8-chuckle*.6)
	body.scale = Vector2(1+breath*.008,1+breath*.016)
	head.position = Vector2(84,80-breath*1.1-chuckle*1.5)
	head.rotation = (sin(age*.9)*.025-laughter*.12+chuckle*.025+anger*sin(angry_age*5)*.035)*motion
	hat.rotation = sin(age*1.5)*.014*motion-head.rotation*.2
	left_arm.position = Vector2(64,108-breath*.8)
	right_arm.position = Vector2(105,108-breath*.8)
	left_arm.rotation = (-.12-laughter*.16+anger*.45+sin(age*1.7)*.035)*motion
	right_arm.rotation = (.08+laughter*.15-anger*.55+sin(angry_age*6)*anger*.12)*motion
	right_arm.rotation += sin(age*26)*nervous*.045*motion+sin(reaction_age*9)*delight*.24*motion
	if casting_age<.45: right_arm.rotation -= sin(casting_age/.45*PI)*.25*motion
	if reaction in ["sort","taunt","curse","mischief"]:
		var t := clampf(reaction_age/.32,0,1)
		right_arm.rotation = lerpf(-.75,0,t*t)*motion if t<1 else 0.0
	var g:=gesture_envelope*motion
	if not defeated and not entry_flying and not sleeping:
		match gesture_kind:
			0:
				body.position.x+=sin(gesture_age*2.8)*4*g
				head.rotation+=sin(gesture_age*3)*.16*g
				hat.rotation-=sin(gesture_age*3)*.06*g
				left_arm.rotation-=.32*g
			1:
				right_arm.rotation-=.7*g
				left_arm.rotation-=.45*g
				head.rotation-=.16*g
				body.position.y-=3*g
			2:
				left_arm.rotation-=.65*g
				right_arm.rotation+=.4*g
				head.rotation+=.18*g
				body.scale.x+=.025*g
				body.position.y-=4*g
	# The free hand shields an ear while the staff hand keeps its strike animation.
	left_arm.rotation = lerpf(left_arm.rotation,-2.05,cover_ears)
	if defeated:
		if defeat_age<.22:
			var t := smoothstep(0,.22,defeat_age)
			right_arm.rotation = lerpf(-.25,-.75,t)*motion
		elif defeat_age<.42:
			var t := (defeat_age-.22)/.2
			right_arm.rotation = lerpf(-.75,0,t*t)*motion
		else:
			right_arm.rotation = sin((defeat_age-.42)*20)*exp(-(defeat_age-.42)*10)*.06*motion
	for node in [body,head,left_arm,right_arm]:
		node.position += Vector2(-surprise*10*motion+dance,-hop)
	body.rotation = dance*.012
	head.rotation += surprise*.12*motion
	if sleeping: head.rotation += .15
	feet.position = Vector2(dance,-hop)
	if reclining:
		body.position.x -= 12
		left_arm.position.x -= 10
		right_arm.position.x -= 10
		head.rotation = PI/2-.20+sin(age*1.5)*.012
	body.visible = not reclining
	left_arm.visible = not reclining
	right_arm.visible = not reclining
	feet.visible = not entry_flying and not reclining
	if entry_flying:
		var airborne := 1-smoothstep(.78,1,entry_progress)
		body.scale.y *= 1-airborne*.15
		body.position.y -= airborne*8
		head.position.y -= airborne*10
		head.rotation -= airborne*.07
		hat.rotation += sin(age*5)*airborne*.035
		left_arm.rotation = lerpf(left_arm.rotation,-.65,airborne)
		right_arm.rotation = lerpf(right_arm.rotation,.45,airborne)
		if flight_style==1:
			left_arm.rotation -= sin(entry_progress*PI)*.35
			head.rotation += sin(entry_progress*TAU)*.08
		elif flight_style==2:
			right_arm.rotation += sin(entry_progress*PI)*.3
			hat.rotation += sin(entry_progress*TAU)*.08
	for node in [body,head,hat,left_arm,right_arm,feet,effects_layer]: node.queue_redraw()
	render_authored_frames()

func render_authored_frames() -> void:
	if not is_instance_valid(frames):return
	for node in [body,head,left_arm,right_arm,feet]:node.hide()
	var desired:="evil_idle"
	var clip_time:=-1.0
	if defeated:
		if defeat_age<1.9:desired="defeated";clip_time=defeat_age
		elif defeat_age<4.7:desired="fake_cry";clip_time=defeat_age-1.9
		else:desired="defeated_idle";clip_time=defeat_age-4.7
	elif idle_sleeping:desired="sleep"
	elif entry_flying:desired="broom_entry"
	elif player_lost:
		desired="victory_laugh" if reaction_age<4.4 else "evil_idle"
		clip_time=minf(reaction_age,3.2) if reaction_age<4.4 else reaction_age-4.4
	elif reaction in ["sort","taunt"]:desired="angry";clip_time=reaction_age
	elif reaction=="mischief":desired="mischief_spell";clip_time=reaction_age
	elif reaction=="curse":desired="evil_spell";clip_time=reaction_age
	elif reaction=="surprise":desired="shocked";clip_time=reaction_age
	elif reaction=="mistake":desired="mock_player";clip_time=reaction_age
	elif laugh_left>0:desired="evil_laugh";clip_time=(laugh_duration-laugh_left)*2.8/maxf(.2,laugh_duration)
	elif near_win:
		desired="panic" if age-near_win_since<2.4 else "nervous"
		clip_time=age-near_win_since if desired=="panic" else age-near_win_since-2.4
	elif gesture_age<gesture_duration and allow_idle:
		desired="inspect_staff" if gesture_kind%2==0 else "taunt";clip_time=gesture_age
	if frame_state!=desired:frame_state=desired;frame_started=age
	frames.tension=progress_tension
	frames.clock=age;frames.gaze=gaze
	frames.sample(desired,clip_time if clip_time>=0 else age-frame_started)

func staff_ground_position() -> Vector2:
	if is_instance_valid(frames):return frames.staff_base_anchor
	return Vector2(122,173)

func poly(n: Node2D, points: Array, color: Color) -> void:
	var p := PackedVector2Array(points)
	n.draw_colored_polygon(p,color)
	p.append(p[0])
	n.draw_polyline(p,INK,2,true)

func oval(n: Node2D, center: Vector2, radii: Vector2, color: Color) -> void:
	var p := PackedVector2Array()
	for i in range(40):
		var a := i*TAU/40
		p.append(center+Vector2(cos(a)*radii.x,sin(a)*radii.y))
	n.draw_colored_polygon(p,color)

func draw_feet(n: Node2D) -> void:
	oval(n,Vector2(84,174-feet.position.y),Vector2(48,5),Color(0,0,0,.22))
	for side in [-1,1]:
		var stride := sin(age*10+side*PI/2)*story_walk
		oval(n,Vector2(84+side*19+stride*4,169-absf(stride)*3),Vector2(18,7),INK)
		oval(n,Vector2(84+side*19+stride*4,167-absf(stride)*3),Vector2(16,5),Color("59406e"))

func draw_body(n: Node2D) -> void:
	poly(n,[Vector2(-20,-22),Vector2(20,-22),Vector2(40,51),Vector2(0,56),Vector2(-40,51)],Color("693c87"))
	poly(n,[Vector2(-14,-18),Vector2(5,-18),Vector2(22,49),Vector2(-14,52)],Color("8454a3"))
	poly(n,[Vector2(-23,-20),Vector2(0,-8),Vector2(23,-20),Vector2(14,-2),Vector2(-14,-2)],Color("82ba78"))
	n.draw_line(Vector2(-25,13),Vector2(25,13),INK,9,true)
	poly(n,[Vector2(0,4),Vector2(9,13),Vector2(0,22),Vector2(-9,13)],Color("f7cd6e"))
	oval(n,Vector2(0,13),Vector2(4,5),Color("51bc9e"))
	for x in [-22,18]: n.draw_line(Vector2(x,29),Vector2(x*1.5,47),Color("a47fbb"),1.5,true)

func draw_arm(n: Node2D, right: bool) -> void:
	var side := 1 if right else -1
	poly(n,[Vector2(-8,-4),Vector2(8,-4),Vector2(side*17+8,25),Vector2(side*17-8,28)],Color("734792"))
	var hand := Vector2(side*17,25)
	oval(n,hand,Vector2(8,7),Color("f4c1a3"))
	if right and not entry_flying and not is_staff_dropped() and not reclining:
		var tip := hand+Vector2(12,-64)
		var base := Vector2(hand.x-2,66)
		n.draw_line(base,tip,INK,6,true)
		n.draw_line(base,tip,Color("ba895a"),3,true)
		oval(n,tip,Vector2(6,8),Color("8de4bd"))
		n.draw_circle(tip,10,Color(.6,1,.8,.13+sin(age*2)*.04))

func draw_head(n: Node2D) -> void:
	var cheer := maxf(laughter,delight*.8)
	for side in [-1,1]:
		oval(n,Vector2(side*25,0),Vector2(13,29),Color("bfc0d6"))
		oval(n,Vector2(side*30,12),Vector2(10,13),Color("e0d9ed"))
	oval(n,Vector2(0,-3),Vector2(28,30),INK)
	oval(n,Vector2(0,-4),Vector2(26,28),Color("efb995").lerp(Color("f09089"),anger*.6 if defeated else 0))
	oval(n,Vector2(-4,-10),Vector2(22,21),Color("f9d0ac").lerp(Color("f7988d"),anger*.45 if defeated else 0))
	for side in [-1,1]:
		var eye := Vector2(side*11,-7)
		var opening := maxf(.08,(1-blink)*(1-laughter*.78))*(1+surprise*.35)
		var glance := Vector2(1+sin(age*2)*nervous*2,-nervous)+gaze
		glance=glance.clamp(Vector2(-3,-2.6),Vector2(3,2.6))
		if cheer<.3:
			oval(n,eye,Vector2(7,6*opening),Color("fff9df"))
			oval(n,eye+glance,Vector2(3,4*opening),Color("5a8b5d"))
			oval(n,eye+glance,Vector2(1.5,3*opening),INK)
			n.draw_line(eye+Vector2(-side*6,-10+anger*5-laughter*2-surprise*4-nervous*3),eye+Vector2(side*7,-8-anger*3-surprise*3),INK,3,true)
		else:
			var smile_eye := PackedVector2Array()
			var smile_brow := PackedVector2Array()
			for i in range(17):
				var t := i/16.0
				smile_eye.append(eye+Vector2(lerpf(-7,7,t),2-sin(t*PI)*4))
				smile_brow.append(eye+Vector2(lerpf(-8,8,t),-10-sin(t*PI)*2))
			n.draw_polyline(smile_eye,INK,2.8,true)
			n.draw_polyline(smile_brow,INK,2,true)
		oval(n,Vector2(side*17,6),Vector2(6,3),Color(.9,.42,.44,.3+anger*.3))
	poly(n,[Vector2(0,-4),Vector2(12,5),Vector2(1,8),Vector2(-2,5)],Color("e8a683"))
	if defeated and defeat_age<.75:
		oval(n,Vector2(1,16),Vector2(6,4+sin(defeat_age*15)*1.5),Color("703146"))
	elif vocal_open>.05:
		oval(n,Vector2(1,16),Vector2(7,2+vocal_open*7),Color("703146"))
	elif surprise>.2:
		oval(n,Vector2(1,16),Vector2(4,6*surprise),Color("703146"))
	elif cheer>.12:
		poly(n,[Vector2(-11,11),Vector2(-5,14),Vector2(5,14),Vector2(12,10),Vector2(9,22+cheer*3),Vector2(1,26+cheer*2),Vector2(-8,22)],Color("703146"))
		poly(n,[Vector2(-7,14),Vector2(8,13),Vector2(6,17),Vector2(-5,18)],Color("fff4df"))
		oval(n,Vector2(1,23),Vector2(5,2.6),Color("ef8e9a"))
		n.draw_line(Vector2(-14,9),Vector2(-11,12),Color("a56b65"),1.5,true)
		n.draw_line(Vector2(12,10),Vector2(15,7),Color("a56b65"),1.5,true)
	else:
		var mouth := PackedVector2Array()
		for i in range(17):
			var t := i/16.0
			mouth.append(Vector2(lerpf(-9,10,t),14+sin(t*PI)*(4-anger*7)))
		n.draw_polyline(mouth,Color("8e4056"),2.5,true)
	if nervous>.1:
		var drop := Vector2(32,-13+fposmod(age*13,14))
		poly(n,[drop+Vector2(0,-5),drop+Vector2(3,1),drop+Vector2(0,4),drop+Vector2(-3,1)],Color(.45,.8,1,nervous))

func throw_magic(power: float) -> void:
	if not is_instance_valid(right_arm): return
	if spells.size()>=4: spells.pop_front()
	casting_age = 0
	var origin := right_arm.position+Vector2(29,-39).rotated(right_arm.rotation)
	if is_instance_valid(frames):origin=staff_position()/1.2
	spells.append({"start":origin,"finish":Vector2(130+randf_range(-18,12),154),"age":0.0,"duration":.8,"power":power,"seed":randf()*TAU})

func draw_effects(n: Node2D) -> void:
	if entry_flying and not is_instance_valid(frames):
		var airborne := 1-smoothstep(.78,1,entry_progress)
		var color := Color(1,1,1,airborne)
		var a := Vector2(22,151)
		var b := Vector2(163,144)
		n.draw_line(a,b,Color(.21,.12,.17,airborne),8,true)
		n.draw_line(a,b,Color(.69,.43,.23,airborne),4,true)
		poly(n,[Vector2(0,137),Vector2(40,144),Vector2(40,158),Vector2(-4,168),Vector2(5,153)],Color(.81,.59,.27,airborne))
		for i in range(7):
			n.draw_line(Vector2(35,146+i*1.5),Vector2(i%2*7-2,141+i*3),Color(.96,.77,.4,airborne),1.5,true)
		n.draw_line(Vector2(34,142),Vector2(35,160),Color(.52,.3,.15,airborne),4,true)
		for side in [-1,1]:
			oval(n,Vector2(84+side*15,145),Vector2(15,6),Color(.26,.15,.35,airborne))
		for i in range(9):
			var tail := fposmod(age*60+i*13,110)
			n.draw_circle(Vector2(-tail,151+sin(age*5+i)*6),maxf(1,3-tail*.02),Color(.7,.4,1,(1-tail/110)*airborne*.6))
	for spell in spells:
		var t := clampf(spell.age/spell.duration,0,1)
		var color := Color("c797ff").lerp(Color("73e9dc"),t)
		var start: Vector2 = spell.start
		var finish: Vector2 = spell.finish
		if t<1:
			for trail in range(8):
				var back := maxf(0,t-trail*.035)
				var p := start.lerp(finish,back)+Vector2(0,-sin(back*PI)*(25 if gentle else 78))
				n.draw_circle(p,maxf(1,(5-trail*.45)*spell.power),Color(color,.55-trail*.06))
			var point := start.lerp(finish,t)+Vector2(0,-sin(t*PI)*(25 if gentle else 78))
			n.draw_circle(point,11*spell.power,Color(color,.12))
			n.draw_circle(point,6*spell.power,Color(color,.38))
			n.draw_circle(point,2.5*spell.power,Color("f9edff"))
		else:
			var fade := clampf((spell.age-spell.duration)/.5,0,1)
			oval(n,finish,Vector2(8+fade*22,3+fade*8),Color(color,(1-fade)*.35))
			for i in range(10):
				var direction := Vector2.from_angle(i*TAU/10+spell.seed)
				var point := finish+direction*(5+fade*21)
				n.draw_line(point-direction*3,point+direction*3,Color(color,1-fade),2,true)
				n.draw_circle(point,1.8,Color(1,.9,1,1-fade))
	var burst := reaction_age-1.08 if reaction in ["sort","curse","taunt","mischief"] else (defeat_age-1.08 if defeated else 10.0)
	if burst>=0 and burst<.6:
		var alpha := 1-burst/.6
		oval(n,Vector2(122,173),Vector2(10+burst*55,3+burst*9),Color(.7,.35,1,alpha*.45))
		for i in range(6):
			var p := Vector2(122+(i-2.5)*(4+burst*12),170-burst*35-sin(i)*8)
			n.draw_circle(p,2,Color(.85,.6,1,alpha))
	if surprise>.1:
		var font := get_theme_default_font()
		n.draw_string(font,Vector2(129,20),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,29,Color(1,.85,.4,surprise))
	if delight>.1 or player_lost or nervous>.1:
		var strength := maxf(delight,nervous*.5)
		for i in range(8):
			var a := age*2+i*TAU/8
			var p := Vector2(84+cos(a)*58,139+sin(a)*27)
			n.draw_circle(p,2+sin(a)*.5,Color(.75,.45,1,strength*.65))
	if defeated:
		for side in [-1,1]:
			for i in range(3):
				var rise := fposmod(defeat_age*30+i*9,28)
				oval(n,head.position+Vector2(side*(32+sin(rise*.2)*3),-rise),Vector2(4+rise*.12,3+rise*.1),Color(.85,.83,.92,(1-rise/28)*.65))
		if is_staff_dropped() and not is_instance_valid(frames):
			var t := clampf((defeat_age-.65)/.6,0,1)
			var center := Vector2(112,142+t*24-sin(t*PI)*12)
			var direction := Vector2.from_angle(lerpf(-1.4,.1,smoothstep(0,1,t)))
			n.draw_line(center-direction*27,center+direction*27,INK,5,true)
			n.draw_line(center-direction*27,center+direction*27,Color("ba895a"),2.5,true)
			n.draw_circle(center-direction*27,5,Color("8de4bd"))

func draw_hat(n: Node2D) -> void:
	poly(n,[Vector2(-26,-26),Vector2(-16,-63),Vector2(0,-77),Vector2(23,-65),Vector2(11,-59),Vector2(24,-26)],Color("633984"))
	poly(n,[Vector2(-17,-59),Vector2(0,-72),Vector2(12,-65),Vector2(-2,-60),Vector2(-8,-28),Vector2(-21,-28)],Color("8f5ab0"))
	poly(n,[Vector2(-24,-36),Vector2(22,-36),Vector2(24,-26),Vector2(-26,-26)],Color("7fb06a"))
	oval(n,Vector2(0,-25),Vector2(43,9),INK)
	oval(n,Vector2(0,-27),Vector2(42,8),Color("73448f"))
	poly(n,[Vector2(4,-39),Vector2(11,-32),Vector2(4,-25),Vector2(-3,-32)],Color("f4ce75"))

func cast_mischief() -> void:
	angry=false;irritation_left=0;laugh_left=0;reaction="mischief";reaction_left=3.0;reaction_age=0;sort_impact_played=false

func draw_sleep_marks()->void:
	if not idle_sleeping:return
	var font=preload("res://assets/fonts/game_font.tres")
	for i in range(3):
		var t=fposmod(age*.28+i*.33,1.0)
		sleep_fx.draw_string(font,Vector2(130+t*30,38-t*48),"Z" if i==2 else "z",HORIZONTAL_ALIGNMENT_LEFT,-1,14+i*3,Color(.76,.86,1,sin(t*PI)*.85))
