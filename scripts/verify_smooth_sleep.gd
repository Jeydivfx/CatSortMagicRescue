extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var cat=preload("res://scripts/cat_actor.gd").new();root.add_child(cat);cat.setup(null,0,0)
	var texture=cat.sprite.texture;var prior:=0.0
	for i in range(181):
		var t:=i/60.0
		cat.animate(30+t,false,0,0,false);cat.position=Vector2(100,200);cat.scale=Vector2.ONE*2.0
		cat.orange_sleep(30+t,12+t,true)
		var p: float=cat.orange_pose.sleep_progress
		assert(p>=prior and p-prior<.02,"Sleep must progress continuously")
		assert(cat.sprite.texture==texture and cat.victory_mesh.visible,"Same body throughout sleep")
		assert(cat.position==Vector2(100,200) and cat.scale==Vector2.ONE*2.0,"No root/size jump")
		if p<.94:assert(cat.orange_pose.z_strength==0)
		prior=p
	assert(prior>.99 and cat.orange_pose.z_strength>.99)
	cat.orange_sleep(33.1,0,false)
	assert(cat.orange_pose.z_strength==0,"Zs vanish as soon as activity resumes")
	assert(cat.orange_pose.sleep_progress>0,"Wake eyelids ease open rather than cut")
	cat.free();print("PASS 181 continuous sleep samples, unchanged body/size/root, delayed Zs, immediate symbol removal and eased wake");quit()
