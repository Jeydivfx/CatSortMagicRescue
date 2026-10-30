extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code)
  for page in ["levels","rescue_home"]:
   g.show_menu(page);await process_frame;await process_frame
   var nav=g.menu_ui.get_node("NavigationBar");assert(nav.get_node("Back").size==Vector2(60,60));assert(nav.get_node("Back").position==Vector2(16,16));assert(nav.get_node("Title").position==Vector2(78,14))
   for extent in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
    root.size=extent;await process_frame;g.layout_navigation()
    var back=nav.get_node("Back");assert(back.get_global_rect().position.x>=0)
   root.size=Vector2i(540,900);await process_frame;g.layout_navigation();g.menu_ui.modulate=Color.WHITE
   RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/unified_"+page+"_"+code+".png")
   nav.get_node("Back").pressed.emit();assert(g.screen=="menu")
 g.free();await process_frame;print("PASS shared Levels/sanctuary header, EN/FA, three sizes, visible back and Home action");quit()
