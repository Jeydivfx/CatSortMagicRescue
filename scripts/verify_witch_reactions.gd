extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var w=preload("res://scripts/witch_rig.gd").new();root.add_child(w);w.set_process(false);w.reset();w.allow_idle=false
	w.reaction_age=100;w.story_laugh(1.4)
	for i in range(42):w._process(1.0/60)
	assert(w.frames.model.pose_data.mouth>.4,"Click must animate a fresh laugh after a long idle")
	var cries:=[0];w.cry_started.connect(func():cries[0]+=1);w.defeat()
	for i in range(360):w._process(1.0/60)
	assert(cries[0]==1,"Cry cue must fire exactly once")
	assert(w.frames.model.pose_data.staff_drop==1,"Dropped staff stays on floor")
	w.reset();w.allow_idle=false;w.defeat()
	for i in range(150):w._process(1.0/60)
	assert(cries[0]==2,"Cry must reset for a new level")
	w.free();print("PASS fresh click laugh, single cry event, reset, dropped staff");quit()
