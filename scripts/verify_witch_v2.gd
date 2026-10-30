extends SceneTree
const POSES=preload("res://scripts/witch_pose_v2.gd")
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var animator=preload("res://scripts/witch_animator_v2.gd").new();root.add_child(animator);animator.configure()
	var transforms:={}
	for node in animator.model.find_children("*","Sprite2D",true,false):transforms[node.get_instance_id()]=node.scale
	var samples:=0
	for state in POSES.DURATIONS:
		animator.reset()
		for i in range(ceili(POSES.duration(state)*120)):
			animator.clock+=1.0/120;animator.sample(state,i/120.0)
			assert(animator.model.position==animator.foot)
			assert(animator.model.scale==Vector2.ONE*(209.0/328.0))
			assert(animator.staff_anchor.is_finite())
			for node in animator.model.find_children("*","Sprite2D",true,false):assert(node.scale==transforms[node.get_instance_id()],"Art part scale changed")
			samples+=1
	animator.free()
	var witch=preload("res://scripts/witch_rig.gd").new();root.add_child(witch);witch.set_process(false);witch.reset()
	var impacts:=[0];witch.staff_impact.connect(func():impacts[0]+=1)
	witch.cast_obstacle()
	for i in range(64):witch._process(1.0/60)
	assert(impacts[0]==0,"Staff impact happened before contact")
	witch._process(1.0/60);assert(impacts[0]==1)
	for i in range(150):witch._process(1.0/60)
	assert(witch.reaction=="")
	witch.defeat()
	for i in range(360):
		witch._process(1.0/60)
		if witch.defeat_age>1.9:assert(witch.frames.model.pose_data.staff_drop>.999,"Dropped staff returned to hand")
	assert(witch.frames.state=="defeated_idle")
	assert(witch.frames.model.staff.get_parent()==witch.frames.model)
	witch.reset();assert(witch.next_gesture-witch.age>=6)
	witch.free();await process_frame
	print("PASS ",samples," pose samples: fixed root, constant part scale, finite anchors, impact at 1.08s, quiet idle interval, staff stays dropped");quit()
