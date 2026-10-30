extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,1200)
	var ids=preload("res://scripts/cat_breeds.gd").ACTIVE_IDS
	for kind in ids:
		var c=preload("res://scripts/cat_actor.gd").new();root.add_child(c);c.setup(null,kind,0)
		var original=c.sprite.texture;var previous:=0.0
		for i in range(181):
			var t:=i/60.0;c.animate(30+t,false,0,0,false);c.position=Vector2(100,200);c.scale=Vector2.ONE*2
			c.orange_sleep(30+t,12+t,true)
			assert(c.orange_pose.sleep_progress>=previous and c.orange_pose.sleep_progress-previous<.02)
			assert(c.sprite.texture==original and c.victory_mesh.visible)
			assert(c.position==Vector2(100,200) and c.scale==Vector2.ONE*2)
			previous=c.orange_pose.sleep_progress
		assert(previous>.99 and c.orange_pose.z_strength>.99)
		c.orange_sleep(33.1,0,false);assert(c.orange_pose.z_strength==0)
		c.orange_air(.5,true)
		assert(c.orange_pose.visible and c.orange_pose.current=="air")
		assert(not c.victory_mesh.visible and not c.sprite.visible)
		assert(c.orange_pose.image.texture!=null and c.orange_pose.image.scale.x>0 and c.orange_pose.image.scale.x<1)
		c.orange_air(0,false);assert(c.victory_mesh.visible and not c.orange_pose.visible)
		c.free()
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	for kind in ids:
		g.start_game(30);g.cancel_witch_entry();var other:=1 if kind==0 else 0
		g.tubes=[[kind,kind],[kind],[other,other,other,other],[]];g.refresh();g.transfer(0,1,2)
		await create_timer(.45).timeout
		assert(g.busy and g.flight_cats.size()==2)
		for actor in g.actors:
			if int(actor.get_meta("tube"))<0:assert(actor.orange_pose.visible and actor.orange_pose.current=="air")
		await create_timer(.75).timeout
		assert(not g.busy and g.tubes[0].is_empty() and g.tubes[1].size()==3 and g.moves==1)
	g.free();print("PASS all 9 active breeds: 1629 continuous sleep samples, Z/wake, stable body/root/scale, single air silhouette, 9 grouped gameplay transfers and landing restore");quit()
