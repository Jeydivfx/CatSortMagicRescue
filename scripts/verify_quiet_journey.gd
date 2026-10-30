extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu("levels");await process_frame;await process_frame
  var m=g.level_map;assert(not g.menu_ui.has_node("NavigationBar"));assert(m.buttons.size()<20);assert(m.world_label.visible and not m.world_icon.visible);assert(m.map_view.size.y==832)
  var initial=m.scroll.scroll_vertical;var button_pos=m.focus_button.global_position
  m.scroll.scroll_vertical=0;await process_frame;assert(m.buttons.has(999) and m.buttons[999].disabled);assert(m.focus_button.global_position.distance_to(button_pos)<.1)
  m.focus_button.pressed.emit();await process_frame;assert(abs(m.scroll.scroll_vertical-initial)<2)
  var current=m.unlocked_count-1;assert(m.buttons.has(current) and m.buttons[current].current and not m.buttons[current].disabled)
  for extent in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=extent;await process_frame;m.layout_map();var center=m.body.position+Vector2(360,560)*m.body.scale+m.position;assert(center.distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;m.layout_map();g.menu_ui.modulate=Color.WHITE;RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/quiet_journey_"+code+".png")
  m.scroll.scroll_vertical=int(m.content_height);await process_frame;assert(m.buttons.has(0));assert(not m.buttons[0].disabled)
  m.home_pressed.emit();assert(g.screen=="menu")
 g.free();await process_frame;print("PASS journey EN/FA, 1000 levels, locks, virtualization, scrolling both ends, fixed footer, current focus, safe layout");quit()
