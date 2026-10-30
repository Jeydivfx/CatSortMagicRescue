extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.change_language("en")
 g.show_menu("pause");g.set_process(false)
 for viewport_size in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
  root.size=viewport_size;await process_frame;g.layout_navigation()
  var panel=g.menu_ui.get_node("PausePanel")
  var actual=g.menu_ui.position+(panel.position+panel.size*.5)*g.menu_ui.scale
  assert(actual.distance_to(g.content_rect().get_center())<.1)
  var audio_bottom=g.menu_ui.get_node("PauseMusic").position.y+g.menu_ui.get_node("PauseMusic").size.y
  assert(is_equal_approx(panel.position.y+panel.size.y-audio_bottom,25.0))
 root.size=Vector2i(540,900);await process_frame;g.layout_navigation();g.menu_ui.modulate=Color.WHITE
 RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/pause_refined.png")
 g.show_menu();assert(g.menu_ui.has_node("HomeScore"))
 g.free();await process_frame;print("PASS pause centered at three aspect ratios; home total score present");quit()
