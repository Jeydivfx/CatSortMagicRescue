extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu()
  if is_instance_valid(g.menu_intro):g.menu_intro.kill()
  g.menu_ui.modulate=Color.WHITE;g.menu_cats.modulate=Color.WHITE
  for extent in [Vector2i(360,640),Vector2i(540,900),Vector2i(540,1200),Vector2i(1080,2340),Vector2i(840,840)]:
   g.layout_safe_override=Vector2(40,20) if extent==Vector2i(1080,2340) else Vector2.ZERO
   g.layout_banner_override=130 if extent==Vector2i(1080,2340) else -1
   root.size=extent;await process_frame;await process_frame;preload("res://scripts/responsive_layout.gd").home(g)
   var safe:Rect2=g.content_rect();var scene=preload("res://scripts/royal_home_layout.gd").background_rect(g);var feet=scene.position.y+scene.size.y*.588
   for cat in g.menu_cats.get_children():assert(absf(cat.get_meta("menu_origin").y+40*cat.get_meta("menu_scale")-feet)<.1)
   var full=Rect2(-g.position,g.get_viewport_rect().size)
   assert(scene.grow(.1).encloses(full))
   var play=g.menu_ui.get_node("HomePlay");var nav=g.menu_ui.get_node("HomeLevels");assert(play.position.y+play.size.y<nav.position.y-5)
   assert(nav.position.y+nav.size.y<safe.end.y)
   assert(absf((nav.position.y+nav.size.y*.5-safe.position.y)/safe.size.y-.90)<.001)
   for name in ["HomePlay","HomeLevels","HomeGlobalRankings","HomeSanctuary"]:
    var b=g.menu_ui.get_node(name)
    var caption=b.title_label
    assert(Rect2(Vector2.ZERO,b.size).encloses(Rect2(caption.position,caption.size)))
    if name=="HomePlay":assert(Rect2(Vector2.ZERO,b.size).encloses(Rect2(b.level_label.position,b.level_label.size)))
   assert(g.menu_ui.get_node("HomeSanctuary").position.x+nav.size.x<safe.end.x)
   if extent in [Vector2i(540,900),Vector2i(540,1200),Vector2i(1080,2340),Vector2i(840,840)]:
    RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/royal_home_"+code+"_"+str(extent.x)+"x"+str(extent.y)+".png")
  g.menu_ui.get_node("HomeLevels").pressed.emit();assert(g.screen=="levels");g.show_menu();g.menu_ui.get_node("HomeGlobalRankings").pressed.emit();assert(g.screen=="rankings");g.show_menu();g.menu_ui.get_node("HomeSanctuary").pressed.emit();assert(g.screen=="rescue_home")
 g.free();await process_frame;print("PASS EN/FA royal menu: five aspect ratios, Android cutout and banner, cats anchored to baked cushion, separate controls, banner-safe footer, navigation actions");quit()
