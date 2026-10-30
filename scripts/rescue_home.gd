extends Control
const L=preload("res://scripts/localization.gd")
const Breeds=preload("res://scripts/cat_breeds.gd")
var game
var completed:=0
var rescued:=0
var content:Control
var residents:Array=[]
var scenery:Node2D
var age:=0.0
var milestone_bar:ProgressBar
var rescue_counts:Dictionary={}
var breed_cards:Array=[]
func configure(g)->void:
 game=g;layout_direction=Control.LAYOUT_DIRECTION_LTR
 var levels:Dictionary={}
 for i in range(mini(g.levels.size(),maxi(0,g.unlocked-1))):levels[i]=true
 for key in g.wallet.records:
  if str(key).is_valid_int():
   var index=int(str(key))
   if index>=0 and index<g.levels.size():levels[index]=true
 completed=levels.size()
 for index in levels:
  for tube in g.levels[index].tubes:
   for kind in tube:rescue_counts[int(kind)]=int(rescue_counts.get(int(kind),0))+1;rescued+=1
 var bg=TextureRect.new();bg.texture=load("res://assets/environments/sanctuary_cottage_v1.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
 var shade=ColorRect.new();shade.color=Color(.02,.03,.06,.18);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
 content=Control.new();content.layout_direction=Control.LAYOUT_DIRECTION_LTR;add_child(content)
 var shell=plate(Rect2(50,40,620,1040),Color(.025,.055,.10,.92),Color("c4ae81"),30);shell.name="SanctuaryPanel"
 var back=preload("res://scripts/jewel_button.gd").new();L.style(back);back.name="SanctuaryBack";back.symbol="back";back.compact=true;back.tint=Color("7951b1");back.size=Vector2(60,60);back.pressed.connect(func():game.show_menu());content.add_child(back);back.position=Vector2(66,56);back.set_meta("l10n_x",66)
 label("Cat sanctuary",Rect2(150,56,420,60),34,Color("fff0ca"))
 plate(Rect2(70,132,580,90),Color("10283b"),Color("c6a66c"),23)
 label(number(rescued),Rect2(146,141,204,41),34,Color("ffe0a0"))
 label("Kittens rescued",Rect2(146,184,204,27),18,Color("ecedf2"))
 label(str(rescue_counts.size())+" / "+str(Breeds.ACTIVE_IDS.size()),Rect2(421,141,191,41),32,Color("ffe0a0"))
 label("Breeds found",Rect2(421,184,191,27),18,Color("ecedf2"))
 var summary=Control.new();summary.size=Vector2(720,1120);summary.mouse_filter=Control.MOUSE_FILTER_IGNORE;summary.layout_direction=Control.LAYOUT_DIRECTION_LTR;content.add_child(summary);summary.position=Vector2.ZERO;summary.set_meta("l10n_x",0)
 summary.draw.connect(func():
  summary.draw_line(Vector2(389,150),Vector2(389,205),Color("b99b65"),1.5,true)
  summary.draw_circle(Vector2(111,176),27,Color("aa772c"));summary.draw_circle(Vector2(111,175),24,Color("eab95c"));summary.draw_arc(Vector2(111,175),20,0,TAU,40,Color("ffe6a8"),1.5,true)
  for p in [Vector2(100,169),Vector2(108,163),Vector2(118,165),Vector2(124,172)]:summary.draw_circle(p,3.5,Color("fff0c2"))
  summary.draw_circle(Vector2(111,182),9,Color("fff0c2")))
 scenery=Node2D.new();content.add_child(scenery)
 for i in range(Breeds.ACTIVE_IDS.size()):
  var kind=Breeds.ACTIVE_IDS[i];var card=preload("res://scripts/sanctuary_breed_card.gd").new();card.name="Breed_"+str(kind);card.kind=kind;card.count=int(rescue_counts.get(kind,0));card.game=game;content.add_child(card);card.position=Vector2(70+(i%3)*200,238+(i/3)*210);card.set_meta("l10n_x",card.position.x);breed_cards.append(card)
  if card.count>0:residents.append(card.actor)
 plate(Rect2(70,874,580,110),Color("10283b"),Color("c6a66c"),23)
 var home=TextureRect.new();var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/branding/menu_navigation_cards_v1.png");atlas.region=Rect2(1490,48,580,480);home.texture=atlas;home.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;home.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;home.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_child(home);home.size=Vector2(100,87);home.position=Vector2(84,885);home.set_meta("l10n_x",84)
 label("Next sanctuary upgrade",Rect2(197,883,425,32),23,Color("ffe4aa"),false)
 label("A new comfort in %d levels"%[10-completed%10] if completed<game.levels.size() else "Every kitten deserves a home.",Rect2(197,917,425,26),17,Color("e9e3d7"),false)
 milestone_bar=ProgressBar.new();milestone_bar.name="SanctuaryProgress";milestone_bar.size=Vector2(425,17);milestone_bar.max_value=10;milestone_bar.value=completed%10 if completed<game.levels.size() else 10;milestone_bar.show_percentage=false
 milestone_bar.add_theme_stylebox_override("background",game.panel(Color("0b1927"),8,Color("c6a66c")));milestone_bar.add_theme_stylebox_override("fill",game.panel(Color("e8b74f"),8,Color("ffdfa0")));content.add_child(milestone_bar);milestone_bar.position=Vector2(197,952);milestone_bar.set_meta("l10n_x",197)
 var play=preload("res://scripts/jewel_button.gd").new();L.style(play);play.name="SanctuaryContinue";play.tint=Color("43996d");play.symbol="paw";play.caption_override="\u200b";play.text=L.t("Continue rescuing");play.size=Vector2(500,65);content.add_child(play);play.position=Vector2(110,1000);play.set_meta("l10n_x",110);play.pressed.connect(func():game.start_game(game.unlocked-1,true))
 var caption=Label.new();L.style(caption);caption.text=L.t("Continue rescuing");caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;caption.mouse_filter=Control.MOUSE_FILTER_IGNORE;caption.add_theme_font_size_override("font_size",27);play.add_child(caption);caption.size=Vector2(400,57);caption.position=Vector2(80,4);caption.set_meta("l10n_x",80)
 layout_home();get_viewport().size_changed.connect(layout_home)
func plate(rect:Rect2,fill:Color,border:Color,radius:int)->Panel:
 var p=Panel.new();p.layout_direction=Control.LAYOUT_DIRECTION_LTR;p.mouse_filter=Control.MOUSE_FILTER_IGNORE;p.size=rect.size;p.add_theme_stylebox_override("panel",game.panel(fill,radius,border));content.add_child(p);p.position=rect.position;p.set_meta("l10n_x",rect.position.x);return p
func label(text:String,rect:Rect2,font_size:int,color:Color,center:bool=true)->Label:
 var l=Label.new();L.style(l);l.text=L.t(text);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if center else (HORIZONTAL_ALIGNMENT_RIGHT if L.rtl() else HORIZONTAL_ALIGNMENT_LEFT);l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.add_theme_color_override("font_color",color)
 var font=l.get_theme_font("font")
 while font_size>13 and (font.get_string_size(l.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x-8 or font.get_height(font_size)>rect.size.y):font_size-=1
 l.add_theme_font_size_override("font_size",font_size);content.add_child(l);l.position=rect.position;l.size=rect.size;l.set_meta("l10n_x",rect.position.x);return l
func number(value:int)->String:
 var s=str(value);var parts:PackedStringArray=[]
 while s.length()>3:parts.insert(0,s.right(3));s=s.left(s.length()-3)
 parts.insert(0,s);return L.digits(("٬" if L.locale=="fa" else ",").join(parts))
func layout_home()->void:
 if not is_instance_valid(game):return
 size=get_viewport_rect().size;position=-game.position
 var safe:Rect2=game.content_rect();var factor=minf(1.0,minf((safe.size.x-36)/620.0,(safe.size.y-32)/1040.0));content.scale=Vector2.ONE*factor;content.position=safe.get_center()+game.position-Vector2(360,560)*factor
func _process(delta:float)->void:
 age+=delta
 if is_instance_valid(content):L.restore_x(content)
