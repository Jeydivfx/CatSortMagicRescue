extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code)
  var v=preload("res://scripts/victory_screen.gd").new();g.add_child(v);v.setup(g.cat_atlas,8,8,false,false);v.show_score({"stars":3,"score":272,"coins":30})
  await create_timer(1.6).timeout
  assert(v.crown.visible and v.crown.get_parent()==v.cat);assert(v.crown.position.distance_to(v.cat.victory_head_anchor(v.age,v.gentle_motion))<.01)
  assert(v.cue_history.has("star_2") and not v.next_button.disabled);assert(v.score_label.text==g.L.digits("272"));assert(v.move_label.text==g.L.digits("8"))
  for extent in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=extent;await process_frame;v.layout_result()
   assert((v.position+Vector2(360,545)*v.scale).distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;v.layout_result();RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/result_redesign_"+code+".png")
  v.free()
 g.free();await process_frame;print("PASS results EN/FA, real stats, star cues, button unlock, centered three sizes");quit()
