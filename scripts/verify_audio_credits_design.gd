extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu("credits")
  var uris:Array=[]
  for c in g.menu_ui.get_children():
   if c is LinkButton:uris.append(c.uri)
  assert(uris.size()==4);assert(preload("res://scripts/audio_credits_menu.gd").MUSIC in uris);assert(preload("res://scripts/audio_credits_menu.gd").FILM in uris)
  for v in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=v;await process_frame;g.layout_navigation()
   var p=g.menu_ui.get_node("CreditsPanel");assert((g.menu_ui.position+(p.position+p.size*.5)*g.menu_ui.scale).distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;g.layout_navigation();g.menu_ui.modulate=Color.WHITE
  RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/audio_credits_"+code+".png")
  g.menu_ui.get_node("CreditsBack").pressed.emit();assert(g.screen=="settings")
 g.free();await process_frame;print("PASS credits EN/FA, four original attribution links, centered three sizes, back to Settings");quit()
