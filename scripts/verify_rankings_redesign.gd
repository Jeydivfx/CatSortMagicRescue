extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 var names=["Javad123","Man utd","LunaCat","Mimi","Shadow","Whiskers","Snow","Pixel"]
 var rows:Array=[]
 for i in range(50):rows.append({"player_name":names[i%8] if i<8 else "Player "+str(i+1),"total_score":29686-i*1090,"avatar_id":preload("res://scripts/player_avatars.gd").IDS[i%8]})
 for code in ["en","fa"]:
  g.change_language(code);g.show_menu("rankings");g.leaderboard.rankings_ready.emit(rows)
  await process_frame;await process_frame
  var scroll=g.menu_ui.get_node("RankingScroll");var list=scroll.get_child(0)
  assert(list.get_child_count()==50);assert(list.get_child(0).get_node("PlayerName").text=="Javad123");assert(list.get_child(0).get_node("Score").text==preload("res://scripts/localization.gd").digits("29686"))
  assert(scroll.get_v_scroll_bar().max_value>scroll.size.y)
  for size in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=size;await process_frame;g.layout_navigation()
   var p=g.menu_ui.get_node("RankingsPanel");assert((g.menu_ui.position+(p.position+p.size*.5)*g.menu_ui.scale).distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;g.layout_navigation();g.menu_ui.modulate=Color.WHITE
  RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/rankings_redesign_"+code+".png")
  g.leaderboard.rankings_ready.emit([]);assert(list.get_child_count()==0)
 g.free();await process_frame;print("PASS EN/FA rankings, unchanged names, localized scores, 50 scrollable rows, empty response, centered three sizes");quit()
