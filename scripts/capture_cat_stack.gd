extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,1000)
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
	g.change_language("en")
	g.start_game(19)
	g.tubes=[[0,0,0,0],[1,1,1],[1,2,2],[3,3,3],[0,0],[1,1]]
	g.actor_signature=""
	g.update_actors();g.refresh()
	await create_timer(.75).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://cat_stack_game_preview.png")
	g.provoke_witch()
	await create_timer(.45).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://witch_presence_preview.png")
	g.free();quit()
