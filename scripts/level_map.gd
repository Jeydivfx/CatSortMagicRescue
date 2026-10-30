extends Control
const L=preload("res://scripts/localization.gd")
signal level_selected(index:int)
signal home_pressed
var challenges:Array=[]
var count:=1000
var unlocked_count:=1
var records:Dictionary={}
var scroll:ScrollContainer
var canvas:Control
var buttons:Dictionary={}
var content_height:=0.0
var backdrop:Texture2D=preload("res://assets/environments/journey_quiet_terrain_v1.png")
var game
var heading:Label
var focus_button:Button
var body:Control
var map_view:Control
var terrain:Control
var world_label:Label
var world_icon:Node2D
var visible_world:=-1
const STEP=148.0
const CHAPTER_GAP=132.0
const Chapters=preload("res://scripts/chapter_catalog.gd")
var chapter_cards:Dictionary={}
var chapter_textures:Dictionary={}
func configure(total:int,unlocked:int,saved:Dictionary,hard_levels:Array=[])->void:
 L.style(self);count=maxi(1,total);unlocked_count=clampi(unlocked,1,count);records=saved;challenges=hard_levels;mouse_filter=Control.MOUSE_FILTER_STOP
 body=Control.new();body.layout_direction=Control.LAYOUT_DIRECTION_LTR;add_child(body)
 var shell=Panel.new();shell.name="JourneyPanel";shell.size=Vector2(600,1040);shell.mouse_filter=Control.MOUSE_FILTER_IGNORE;shell.add_theme_stylebox_override("panel",game.panel(Color(.025,.05,.10,.97),30,Color("bfa574")));body.add_child(shell);shell.position=Vector2(60,40);shell.set_meta("l10n_x",60)
 var back=preload("res://scripts/jewel_button.gd").new();L.style(back);back.name="JourneyBack";back.symbol="back";back.compact=true;back.tint=Color("7951b1");back.size=Vector2(60,60);body.add_child(back);back.position=Vector2(78,58);back.set_meta("l10n_x",78);back.pressed.connect(func():home_pressed.emit())
 heading=label("Your journey",Rect2(157,57,425,58),34)
 world_label=label("",Rect2(145,113,470,46),17);world_label.add_theme_color_override("font_color",Color("bcd7df"))
 world_icon=Node2D.new();body.add_child(world_icon);world_icon.draw.connect(draw_world_icon);world_label.show();world_icon.hide()
 map_view=Control.new();map_view.name="JourneyMapViewport";map_view.layout_direction=Control.LAYOUT_DIRECTION_LTR;map_view.clip_contents=true;map_view.size=Vector2(568,832);body.add_child(map_view);map_view.position=Vector2(76,168);map_view.set_meta("l10n_x",76)
 terrain=Control.new();terrain.layout_direction=Control.LAYOUT_DIRECTION_LTR;terrain.size=map_view.size;terrain.mouse_filter=Control.MOUSE_FILTER_IGNORE;map_view.add_child(terrain);terrain.position=Vector2.ZERO;terrain.set_meta("l10n_x",0);terrain.draw.connect(draw_terrain)
 scroll=ScrollContainer.new();L.style(scroll);scroll.name="JourneyScroll";scroll.size=map_view.size;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.scroll_deadzone=12;map_view.add_child(scroll);scroll.position=Vector2.ZERO;scroll.set_meta("l10n_x",0)
 var bar=scroll.get_v_scroll_bar();bar.custom_minimum_size.x=4;bar.modulate.a=.22
 canvas=Control.new();L.style(canvas);canvas.mouse_filter=Control.MOUSE_FILTER_IGNORE;scroll.add_child(canvas);canvas.draw.connect(draw_path)
 content_height=count*STEP+270+ceili(float(count)/Chapters.SIZE)*CHAPTER_GAP;canvas.custom_minimum_size=Vector2(550,content_height)
 bar.value_changed.connect(func(_value):update_visible();terrain.queue_redraw())
 focus_button=preload("res://scripts/jewel_button.gd").new();L.style(focus_button);focus_button.name="CurrentLevelButton";focus_button.tint=Color("7951b1");focus_button.symbol="paw";focus_button.caption_override="\u200b";focus_button.size=Vector2(420,56);body.add_child(focus_button);focus_button.position=Vector2(150,1008);focus_button.set_meta("l10n_x",150);focus_button.pressed.connect(focus_current)
 var caption=Label.new();L.style(caption);caption.text=L.t("Current level")+" • "+L.digits(str(unlocked_count));caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;caption.add_theme_font_size_override("font_size",22);caption.mouse_filter=Control.MOUSE_FILTER_IGNORE;focus_button.add_child(caption);caption.position=Vector2(82,2);caption.size=Vector2(324,49);caption.set_meta("l10n_x",82)
 resized.connect(layout_map);layout_map();focus_current.call_deferred()
func label(value:String,rect:Rect2,font_size:int)->Label:
 var l=Label.new();L.style(l);l.text=L.t(value);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.add_theme_font_size_override("font_size",font_size);l.add_theme_color_override("font_color",Color("fff0d8"));body.add_child(l);l.position=rect.position;l.size=rect.size;l.set_meta("l10n_x",rect.position.x);return l
func layout_map()->void:
 if not is_instance_valid(body):return
 var safe:Rect2=game.content_rect() if is_instance_valid(game) else Rect2(Vector2.ZERO,size)
 var factor=minf(1.05,minf((safe.size.x-36)/600.0,(safe.size.y-32)/1040.0))
 body.scale=Vector2.ONE*factor;body.position=safe.get_center()+(game.position if is_instance_valid(game) else Vector2.ZERO)-Vector2(360,560)*factor
 update_visible();queue_redraw()
func point(index:int)->Vector2:
 return Vector2(275+sin(index*.78)*112,content_height-240-index*STEP-floori(float(index)/Chapters.SIZE)*CHAPTER_GAP)
func focus_current()->void:
 if not is_instance_valid(scroll):return
 scroll.scroll_vertical=int(clampf(point(unlocked_count-1).y-scroll.size.y*.54,0,content_height-scroll.size.y));update_visible();terrain.queue_redraw()
func update_visible()->void:
 if not is_instance_valid(canvas):return
 var first=maxi(0,index_at_y(scroll.scroll_vertical+scroll.size.y+180)-1)
 var last=mini(count-1,index_at_y(scroll.scroll_vertical-180)+1)
 for key in buttons.keys():
  if int(key)<first or int(key)>last:buttons[key].queue_free();buttons.erase(key)
 for index in range(first,last+1):
  if buttons.has(index):continue
  var b=preload("res://scripts/journey_level_button.gd").new();b.number=index+1;b.current=index==unlocked_count-1;b.locked=index>=unlocked_count;b.earned=int(records.get(str(index),{}).get("stars",0));b.hard=index in challenges;b.pressed.connect(func():
   if index<unlocked_count:level_selected.emit(index))
  canvas.add_child(b);b.position=point(index)-Vector2(52,47);b.set_meta("l10n_x",b.position.x);buttons[index]=b
 canvas.queue_redraw()
 update_chapter_cards()
 var center_index=index_at_y(scroll.scroll_vertical+scroll.size.y*.5)
 var chapter=Chapters.chapter_for(center_index)
 var index=Chapters.world_for(center_index)
 visible_world=index
 var done=Chapters.completed_in(chapter,unlocked_count,records,count)
 world_label.text=L.t("Chapter %d" % (chapter+1))+" • "+L.t(str(game.EnvironmentCatalog.WORLDS[index].name))+"\n"+L.t("%d / %d levels complete" % [done,mini(Chapters.SIZE,count-chapter*Chapters.SIZE)])
func index_at_y(y:float)->int:
 var distance=maxf(0,content_height-240-y)
 var block=Chapters.SIZE*STEP+CHAPTER_GAP
 var chapter=floori(distance/block)
 return clampi(chapter*Chapters.SIZE+roundi(minf(Chapters.SIZE-1,fposmod(distance,block)/STEP)),0,count-1)
func update_chapter_cards()->void:
 var visible:Dictionary={}
 for chapter in range(ceili(float(count)/Chapters.SIZE)):
  var first=chapter*Chapters.SIZE
  var y=point(first).y+STEP*.5+CHAPTER_GAP*.5-44
  if y+88<scroll.scroll_vertical-100 or y>scroll.scroll_vertical+scroll.size.y+100:continue
  visible[chapter]=true
  if chapter_cards.has(chapter):continue
  var panel=Panel.new();panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.layout_direction=Control.LAYOUT_DIRECTION_LTR
  panel.add_theme_stylebox_override("panel",game.panel(Color("102238"),18,Color("bfa574")));canvas.add_child(panel);panel.position=Vector2(35,y);panel.size=Vector2(480,88);panel.set_meta("l10n_x",35)
  var wi=Chapters.world_for(first)
  if not chapter_textures.has(wi):chapter_textures[wi]=load(game.EnvironmentCatalog.WORLDS[wi].file)
  var image=TextureRect.new();image.texture=chapter_textures[wi];image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;image.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.add_child(image);image.position=Vector2(9,9);image.size=Vector2(82,70);image.set_meta("l10n_x",9)
  var text=Label.new();L.style(text);text.text=L.t("Chapter %d" % (chapter+1))+" • "+L.t(str(game.EnvironmentCatalog.WORLDS[wi].name))+"\n"+L.t("Levels %d–%d" % [first+1,mini(count,first+Chapters.SIZE)]);text.add_theme_font_size_override("font_size",18);text.add_theme_color_override("font_color",Color("fff0d8"));text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;text.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.add_child(text);text.position=Vector2(97,4);text.size=Vector2(374,80);text.set_meta("l10n_x",97)
  chapter_cards[chapter]=panel
 for key in chapter_cards.keys():
  if not visible.has(key):chapter_cards[key].queue_free();chapter_cards.erase(key)
func draw_path()->void:
 for index in buttons.keys():
  if index>=count-1 or (int(index)+1)%Chapters.SIZE==0:continue
  var p=point(index);var q=point(index+1)
  for step in range(1,18):
   var t=float(step)/18;var dot=p.lerp(q,t)
   if dot.distance_to(p)<54 or dot.distance_to(q)<55:continue
   canvas.draw_circle(dot,2.2,Color("cdb47a") if index<unlocked_count else Color("637775"))
func draw_terrain()->void:
 if not is_instance_valid(scroll):return
 if visible_world>=0:
  if not chapter_textures.has(visible_world):chapter_textures[visible_world]=load(game.EnvironmentCatalog.WORLDS[visible_world].file)
  var texture:Texture2D=chapter_textures[visible_world]
  terrain.draw_texture_rect(texture,chapter_background_rect(texture),false)
 else:
  terrain.draw_texture_rect(backdrop,Rect2(Vector2.ZERO,map_view.size),false)
 terrain.draw_rect(Rect2(Vector2.ZERO,map_view.size),Color(.01,.035,.055,.24))
func chapter_background_rect(texture:Texture2D)->Rect2:
 # Reserve overscan, then pan through it over one chapter, without tiling
 # scenery or exposing empty edges. The level nodes travel much faster.
 var factor=maxf(map_view.size.x/texture.get_width(),map_view.size.y/texture.get_height())*1.12
 var extent=texture.get_size()*factor
 var center_y=scroll.scroll_vertical+map_view.size.y*.5
 var chapter=Chapters.chapter_for(index_at_y(center_y))
 var first=chapter*Chapters.SIZE
 var last=mini(count-1,first+Chapters.SIZE-1)
 var low=point(last).y
 var high=point(first).y
 var progress=clampf((center_y-low)/maxf(1,high-low),0,1)
 return Rect2(Vector2((map_view.size.x-extent.x)*.5,-(extent.y-map_view.size.y)*progress),extent)
func draw_world_icon()->void:
 var c=Color("80d9e9")
 if visible_world==2:
  var p=PackedVector2Array([Vector2(0,-12),Vector2(8,-2),Vector2(6,9),Vector2(0,13),Vector2(-7,7),Vector2(-8,-3)]);world_icon.draw_colored_polygon(p,c);world_icon.draw_line(Vector2(0,-12),Vector2(0,13),Color("dcffff"),1.5,true)
 elif visible_world==0:
  world_icon.draw_circle(Vector2.ZERO,10,Color("e2ecfa"));world_icon.draw_circle(Vector2(4,-3),8,Color("102235"))
 elif visible_world==1:
  for i in range(5):world_icon.draw_circle(Vector2.from_angle(i*TAU/5)*6,4,Color("eab0cd"))
  world_icon.draw_circle(Vector2.ZERO,3,Color("ffe0a1"))
 elif visible_world==4:
  world_icon.draw_colored_polygon(PackedVector2Array([Vector2(0,-12),Vector2(10,7),Vector2(-10,7)]),Color("90c7b1"));world_icon.draw_line(Vector2(0,5),Vector2(0,13),Color("b6a580"),3,true)
 else:
  world_icon.draw_colored_polygon(PackedVector2Array([Vector2(-10,-1),Vector2(0,-10),Vector2(10,-1)]),Color("be9de6"));world_icon.draw_rect(Rect2(-7,0,14,11),Color("deb982"));world_icon.draw_rect(Rect2(-2,5,4,6),Color("4b3b53"))
func _draw()->void:
 if size.x<=0:return
 draw_texture_rect(backdrop,Rect2(Vector2.ZERO,size),false,Color(.35,.40,.48));draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.03,.06,.55))
