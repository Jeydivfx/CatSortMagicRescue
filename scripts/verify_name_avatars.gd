extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 root.size=Vector2i(540,900)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.set_process(false)
 var original_name=g.leaderboard.player_name;var original_avatar=g.leaderboard.avatar_id
 for code in ["en","fa"]:
  g.change_language(code);preload("res://scripts/name_entry.gd").show(g,true)
  var overlay=g.get_node("PlayerNameOverlay");var body=overlay.get_node("NameCardContent")
  for i in range(8):
   var b=body.get_node("Avatar_"+preload("res://scripts/player_avatars.gd").IDS[i]);b.pressed.emit();assert(b.selected)
  assert(not body.get_node("Avatar_orange").selected)
  body.get_node("StartAdventure").pressed.emit();assert(not body.get_node("NameFeedback").text.is_empty())
  for v in [Vector2i(360,640),Vector2i(540,1200),Vector2i(840,840)]:
   root.size=v;await process_frame
   var p=body.get_node("NameCard");assert((body.position+(p.position+p.size*.5)*body.scale).distance_to(g.content_rect().get_center())<.1)
  root.size=Vector2i(540,900);await process_frame;RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/name_avatar_"+code+".png")
  body.get_node("PlayerNameInput").text="Preview Test";body.get_node("StartAdventure").pressed.emit();assert(g.leaderboard.player_name==original_name and g.leaderboard.avatar_id==original_avatar)
  overlay.free()
 g.show_menu("settings");g.menu_ui.get_node("SettingsProfile").pressed.emit()
 assert(g.get_node("PlayerNameOverlay/NameCardContent/PlayerNameInput").text==original_name)
 g.free();await process_frame;print("PASS eight avatar selection, EN/FA, three screen ratios, preview leaves identity untouched, settings opens editable profile");quit()
