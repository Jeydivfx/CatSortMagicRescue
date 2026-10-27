extends Node2D
var game
func _ready() -> void:z_index=9
func _process(_delta: float) -> void:
	if not is_instance_valid(game):return
	visible=game.screen=="game"
	if visible:queue_redraw()
func _draw() -> void:
	if not is_instance_valid(game) or game.screen!="game" or game.entering or game.won or game.lost:return
	var source: int=game.drag_source if game.drag_active else (game.selected if game.selected>=0 else game.pointer_source)
	if source<0 or source>=game.tubes.size() or game.tubes[source].is_empty():return
	if game.curse.blocked(source):return
	var count: int=game.top_group_count(game.tubes,source)
	var s: float=game.board_scale()
	var hover: int=game.tube_at(game.drag_pointer) if game.drag_active else -1
	for dest in range(game.tubes.size()):
		if dest==source or not game.legal(game.tubes,source,dest) or game.curse.blocked(dest):continue
		var rect: Rect2=game.tube_rect(dest)
		var frame:=StyleBoxFlat.new()
		frame.bg_color=Color(.20,.95,.65,.09 if dest==hover else .025)
		frame.border_color=Color(.4,1,.72,.9 if dest==hover else .36)
		frame.set_corner_radius_all(25);frame.set_border_width_all(3 if dest==hover else 2)
		draw_style_box(frame,rect.grow(4))
		if dest==hover:
			var capacity: int=mini(count,4-game.tubes[dest].size())
			for slot in range(capacity):
				var point: Vector2=game.cat_position(dest,game.tubes[dest].size()+slot)
				draw_arc(point,25*s,0,TAU,28,Color(.55,1,.76,.58),2,true)
	var rect: Rect2=game.tube_rect(source)
	var point:=Vector2(rect.get_center().x,rect.position.y-25)
	draw_circle(point,15,Color(.10,.17,.26,.95))
	draw_string(preload("res://assets/fonts/game_font.tres"),point+Vector2(-6,7),str(count),HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("ffe6a0"))
