extends Node2D
const POSES=preload("res://scripts/witch_pose_v2.gd")
const MODEL=preload("res://scripts/witch_model_classic.gd")
var model: Node2D
var state:="evil_idle"
var nominal_height:=209.0
var foot:=Vector2(100.8,208.8)
var clock:=0.0
var current_pose: Dictionary={}
var previous_pose: Dictionary={}
var velocity: Dictionary={}
var transition_pose: Dictionary={}
var transition_velocity: Dictionary={}
var transition_clock:=-10.0
var last_clock:=-1.0
var last_clip_time:=-1.0
var staff_anchor:=Vector2.ZERO
var staff_base_anchor:=Vector2.ZERO
var gaze:=Vector2.ZERO
var tension:=0.0
var felt_tension:=0.0
func configure(_key: String="witch") -> bool:
	model=MODEL.new();add_child(model);model.build()
	current_pose=POSES.neutral();model.apply_pose(current_pose)
	return true
func duration(name: String) -> float:return POSES.duration(name)
func reset() -> void:
	state="evil_idle";current_pose=POSES.neutral();previous_pose.clear();velocity.clear();last_clock=-1;last_clip_time=-1;transition_clock=-10
	model.was_dropped=false
	felt_tension=0
func sample(name: String,time: float,normalized: float=-1.0) -> void:
	var t:=clampf(normalized,0,1)*duration(name) if normalized>=0 else time
	var tension_delta: float=maxf(0,clock-last_clock) if last_clock>=0 else 1.0/60
	felt_tension=lerpf(felt_tension,tension,1-exp(-tension_delta*2.8))
	var target:=POSES.sample(name,t)
	if name in ["evil_idle","inspect_staff","taunt","nervous","panic"]:
		var worry:=smoothstep(.20,.90,felt_tension)
		target.sweat=maxf(target.sweat,worry*.95)
		target.sad=maxf(target.sad,worry*.35)
		target.gaze_x+=sin(clock*.75)*worry*1.4
		target.staff_angle+=sin(clock*5)*worry*.008
		target.smile=lerpf(target.smile,-.15,worry*.65)
	var changed:=state!=name or t<last_clip_time-.08
	if changed:
		transition_pose=current_pose.duplicate();transition_velocity=velocity.duplicate();transition_clock=clock
		state=name
	var dt:=maxf(.0001,clock-last_clock) if last_clock>=0 else 1.0/60
	var progress:=clampf((clock-transition_clock)/.32,0,1)
	var a:=2*pow(progress,3)-3*pow(progress,2)+1
	var b:=-2*pow(progress,3)+3*pow(progress,2)
	var tangent: float=(pow(progress,3)-2*pow(progress,2)+progress)*.32
	var pose: Dictionary={}
	for key in target:
		pose[key]=float(target[key]) if progress>=1 or transition_pose.is_empty() else float(transition_pose.get(key,target[key]))*a+float(transition_velocity.get(key,0))*tangent+float(target[key])*b
		if clock>last_clock:
			velocity[key]=(float(pose[key])-float(current_pose.get(key,pose[key])))/dt
	current_pose=pose;last_clock=clock;last_clip_time=t
	model.position=foot;model.scale=Vector2.ONE*(nominal_height/MODEL.MODEL_HEIGHT);model.gaze=gaze
	model.apply_pose(pose)
	staff_anchor=foot+model.staff_tip()*model.scale
	staff_base_anchor=foot+model.staff_bottom()*model.scale
