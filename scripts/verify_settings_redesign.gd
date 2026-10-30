extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
 for language in ["en","fa"]:
  g.change_language(language);g.show_menu("settings");g.set_process(false)
  for v in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=v;await process_frame;g.layout_navigation()
   var p=g.menu_ui.get_node("SettingsPanel");var center=g.menu_ui.position+(p.position+p.size*.5)*g.menu_ui.scale
   assert(center.distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;g.layout_navigation();g.menu_ui.modulate=Color.WHITE
  RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/settings_redesign_"+language+".png")
  var previous=g.music_enabled;g.menu_ui.get_node("SettingsMusic").pressed.emit();assert(g.music_enabled!=previous)
  g.menu_ui.get_node("MusicVolume").value=.37;assert(is_equal_approx(g.music_volume,.37))
  assert(not g.menu_ui.has_node("AnimationMode2"));g.menu_ui.get_node("AnimationMode1").pressed.emit();assert(g.reduced_motion and not g.animation_off)
  g.menu_ui.get_node("AnimationMode0").pressed.emit();assert(not g.animation_off and not g.reduced_motion)
 g.free();await process_frame;print("PASS Settings EN/FA, three aspect ratios, audio toggle/volume, Full/Reduced modes, no Off option");quit()
