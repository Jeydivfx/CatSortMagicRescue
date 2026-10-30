extends SceneTree
const C=preload("res://scripts/chapter_catalog.gd")
const E=preload("res://scripts/environment_catalog.gd")
func _initialize()->void:call_deferred("run")
func run()->void:
 for i in range(1000):
  assert(C.chapter_for(i)==i/50)
  assert(E.for_level(i)==C.WORLD_ORDER[i/50])
  assert(E.for_level(i,2)==2)
 assert(C.completed_in(0,51,{},1000)==50)
 assert(C.completed_in(1,51,{},1000)==0)
 assert(C.completed_in(1,54,{"50":{"stars":3}},1000)==3)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 root.size=Vector2i(540,900)
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu("levels");await process_frame;await process_frame
  var m=g.level_map
  for i in range(1000):assert(m.index_at_y(m.point(i).y)==i)
  for chapter in range(20):
   var first=chapter*50
   m.scroll.scroll_vertical=int(clampf(m.point(first).y-440,0,m.content_height-832));await process_frame;m.update_visible()
   assert(m.buttons.has(first) and m.chapter_cards.has(chapter))
   assert(m.buttons.size()<20 and m.chapter_cards.size()<4)
   var texture=load(E.WORLDS[C.world_for(first)].file)
   m.scroll.scroll_vertical=int(m.point(first+10).y-416);await process_frame
   var a=m.chapter_background_rect(texture)
   assert(a.grow(.1).encloses(Rect2(Vector2.ZERO,m.map_view.size)))
   m.scroll.scroll_vertical=int(m.point(first+35).y-416);await process_frame
   var b=m.chapter_background_rect(texture)
   assert(b.grow(.1).encloses(Rect2(Vector2.ZERO,m.map_view.size)))
   assert(a.position.y<b.position.y-1)
   m.scroll.scroll_vertical=int(clampf(m.point(first).y-440,0,m.content_height-832));await process_frame;m.update_visible()

   var card=m.chapter_cards[chapter];assert(card.position.y>m.point(first).y+47)
   if first>0:assert(card.position.y+card.size.y<m.point(first-1).y-47)
  m.scroll.scroll_vertical=int(m.point(50).y-440);await process_frame;m.update_visible();g.menu_ui.modulate=Color.WHITE
  RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/chapter_boundary_"+code+".png")
 g.free();await process_frame;print("PASS 20 chapters, 50-level schedule, override, saved progress, every node inverse, all chapter cards, no overlaps, EN/FA virtualization");quit()
