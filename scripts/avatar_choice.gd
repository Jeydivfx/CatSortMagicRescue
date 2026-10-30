extends Button
var portrait:Texture2D
var selected:=false:
	set(value):selected=value;queue_redraw()
func _ready()->void:
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","focus"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
func _draw()->void:
	var center=size*.5;var radius=minf(size.x,size.y)*.5-3
	if selected:
		for i in range(8,0,-1):draw_circle(center,radius+i,Color(1,.72,.15,.025))
	draw_circle(center,radius,Color("10233f"))
	if portrait:draw_texture_rect(portrait,Rect2(Vector2(3,3),size-Vector2(6,6)),false)
	if selected:
		draw_arc(center,radius,0,TAU,96,Color("ffe1a1"),3,true)
		draw_arc(center,radius+3,0,TAU,96,Color("ffb940"),1.5,true)
	if has_focus():draw_arc(center,radius-3,0,TAU,96,Color("fff1cb"),1.2,true)
