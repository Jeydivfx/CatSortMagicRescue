extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu("rescue_home");await process_frame;await process_frame
  var home=g.menu_ui.get_child(0);assert(home.breed_cards.size()==9);assert(not g.menu_ui.has_node("NavigationBar"));assert(home.content.has_node("SanctuaryBack"))
  var total=0;var found=0
  for card in home.breed_cards:
   total+=card.count
   if card.count>0:found+=1
  assert(total==home.rescued and found==home.residents.size())
  for extent in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=extent;await process_frame;home.layout_home()
   var center=home.content.position+Vector2(360,560)*home.content.scale+home.position
   assert(center.distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;home.layout_home();g.menu_ui.modulate=Color.WHITE
  RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/sanctuary_redesign_"+code+".png")
  home.content.get_node("SanctuaryBack").pressed.emit();assert(g.screen=="menu")
 g.unlocked=1;g.wallet.records={};g.show_menu("rescue_home");var empty=g.menu_ui.get_child(0);assert(empty.rescued==0 and empty.residents.is_empty() and empty.breed_cards.size()==9)
 g.free();await process_frame;print("PASS sanctuary EN/FA, one panel/back, nine cards, real totals/locks, zero-progress state, three safe layouts, Home navigation");quit()
