extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.start_game(0)
	for frame in range(25):g._process(.05)
	for actor in g.actors:
		var slot: int=actor.get_meta("slot")
		var tube: int=actor.get_meta("tube")
		assert(is_instance_valid(actor.ear_mesh) and actor.ear_material.get_shader_parameter("ears_only"))
		assert(actor.ear_mesh.visible==(slot<g.tubes[tube].size()-1))
		if actor.ear_mesh.visible:assert(actor.z_index+actor.ear_mesh.z_index>(slot+1)*2)
	for world in range(6):
		g.environment_override=world;g.apply_environment();g.refresh()
		assert(g.hud.world_index==world)
		assert(g.progress_label.position.x>255 and g.move_label.position.x>539)
	var rig=preload("res://scripts/witch_rig.gd").new();root.add_child(rig)
	rig.set_process(false);rig.allow_idle=true
	for kind in range(3):
		rig.reset();rig.allow_idle=true;rig.begin_gesture(kind)
		var min_head:=100.0;var max_head:=-100.0
		var min_arm:=100.0;var max_arm:=-100.0
		var previous: float=rig.right_arm.rotation
		for frame in range(130):
			rig._process(1.0/60)
			assert(absf(rig.right_arm.rotation-previous)<.12)
			previous=rig.right_arm.rotation
			min_head=minf(min_head,rig.head.rotation);max_head=maxf(max_head,rig.head.rotation)
			min_arm=minf(min_arm,rig.right_arm.rotation);max_arm=maxf(max_arm,rig.right_arm.rotation)
		assert(max_head-min_head>.05 or max_arm-min_arm>.2)
		rig.react_to_sort();rig._process(.1)
		assert(rig.reaction=="sort")
	rig.free();g.free();await process_frame
	print("PASS front ear masks and relative stack layers, six environment icons with reserved label space, three distinct smooth witch gestures and reaction priority")
	quit()
