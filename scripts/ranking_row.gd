extends Control
const L=preload("res://scripts/localization.gd")
var rank:=1
var data:Dictionary
func _ready()->void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR;custom_minimum_size=Vector2(530,54);mouse_filter=Control.MOUSE_FILTER_IGNORE
	var avatar=preload("res://scripts/avatar_choice.gd").new();avatar.name="Avatar";avatar.portrait=preload("res://scripts/player_avatars.gd").texture(str(data.get("avatar_id","orange")));avatar.size=Vector2(50,50);avatar.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(avatar);avatar.position=Vector2(75,2)
	if rank<=3:
		var medal=TextureRect.new();medal.texture=preload("res://scripts/ranking_badges.gd").texture(rank);medal.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;medal.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;medal.size=Vector2(60,62);medal.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(medal);medal.position=Vector2(4,-4)
	else:
		var number=Label.new();L.style(number);number.text=L.digits(str(rank));number.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;number.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;number.size=Vector2(44,48);number.add_theme_font_size_override("font_size",21);add_child(number);number.position=Vector2(12,3)
	var player=Label.new();player.name="PlayerName";L.style(player);player.text=str(data.get("player_name","Player"));player.text_direction=Control.TEXT_DIRECTION_AUTO;player.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT;player.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;player.size=Vector2(229,54);player.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;player.add_theme_font_size_override("font_size",21);player.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(player);player.position=Vector2(139,0)
	var score=Label.new();score.name="Score";L.style(score);score.text=L.digits(str(int(data.get("total_score",0))));score.text_direction=Control.TEXT_DIRECTION_LTR;score.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;score.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;score.size=Vector2(135,54);score.add_theme_font_size_override("font_size",22);score.add_theme_color_override("font_color",Color("fff2cd") if rank==1 else Color("fff6f3"));score.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(score);score.position=Vector2(375,0)
func _draw()->void:
	var palette=[Color("514630"),Color("354c6e"),Color("60403b")];var borders=[Color("e9bd52"),Color("a7bfdc"),Color("e8996c")]
	var skin=StyleBoxFlat.new();skin.bg_color=palette[rank-1] if rank<=3 else Color("142f50");skin.border_color=borders[rank-1] if rank<=3 else Color("2b496a");skin.set_border_width_all(1);skin.set_corner_radius_all(19);draw_style_box(skin,Rect2(Vector2.ZERO,Vector2(size.x,54)))
	if rank>3:
		draw_circle(Vector2(34,27),21,Color("24486e"));draw_arc(Vector2(34,27),21,0,TAU,48,Color("3a608a"),1,true)
