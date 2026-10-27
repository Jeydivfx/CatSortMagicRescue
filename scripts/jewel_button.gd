extends Button
## Native scalable candy button: no rasterized labels, all locales remain live.
var tint := Color("4164c8")
var symbol := ""
var subtitle := ""
var caption_override := ""
var title_size := 28
var compact := false
var menu_hero := false
var symbol_scale:=1.0

func icon_center() -> Vector2:
	var shown := caption_override if not caption_override.is_empty() else text
	if shown.strip_edges().is_empty(): return size*.5
	if menu_hero:
		var font := get_theme_font("font")
		var width := maxf(font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x,font.get_string_size(subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,21).x)
		return Vector2((size.x-width-88)*.5+30,(size.y-5)*.5)
	return Vector2(37 if compact else 53,(size.y-5)*.5)

func _ready() -> void:
	set_meta("jewel",true)
	for state in ["normal","hover","pressed","disabled","focus"]:
		add_theme_stylebox_override(state,StyleBoxEmpty.new())
	for state in ["font_color","font_hover_color","font_pressed_color","font_disabled_color","font_focus_color"]:
		add_theme_color_override(state,Color.TRANSPARENT)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
func box(rect: Rect2, color: Color, radius: int, edge: Color, width: int = 2) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color=color
	s.border_color=edge
	s.set_border_width_all(width)
	s.set_corner_radius_all(radius)
	draw_style_box(s,rect)
func _draw() -> void:
	if size.x<10: return
	var c := tint
	if disabled: c=c.lerp(Color("27324b"),.65)
	elif is_pressed(): c=c.darkened(.12)
	elif is_hovered(): c=c.lightened(.08)
	var r := Rect2(Vector2(2,2),size-Vector2(4,7))
	var radius := int(r.size.y*.39) if menu_hero else int(minf(28,r.size.y*.32))
	if menu_hero and symbol in ["play","paw"]: draw_foliage()
	box(Rect2(0,4,size.x,size.y-4),Color("090e28"),radius+4,Color("313e72"),2)
	box(r,c.darkened(.43),radius,Color("ccdf57") if menu_hero and symbol in ["play","paw"] else c.lightened(.5),3 if menu_hero else 2)
	var inner := r.grow(-8 if menu_hero else -5)
	var rad := minf(radius-4,inner.size.y*.5)
	for row in range(int(inner.size.y)):
		var y := float(row)
		var t := y/inner.size.y
		var inset := 0.0
		if y<rad: inset=rad-sqrt(maxf(0,rad*rad-(rad-y)*(rad-y)))
		elif y>inner.size.y-rad: inset=rad-sqrt(maxf(0,rad*rad-pow(y-(inner.size.y-rad),2)))
		var col := c.lightened(.42 if menu_hero else .35).lerp(c.darkened(.37 if menu_hero else .22),t)
		if t<.44: col=col.lightened(.09*(1-t/.44))
		draw_line(inner.position+Vector2(inset,y),inner.position+Vector2(inner.size.x-inset,y),col,1.3)
	box(inner,Color.TRANSPARENT,int(rad),Color(1,1,1,.16),1)
	if has_focus(): box(r.grow(1),Color.TRANSPARENT,radius,Color("ffe597"),2)
	if menu_hero:
		var shine := PackedVector2Array()
		for i in range(33):
			var t := i/32.0
			shine.append(Vector2(30+t*(size.x-60),17-sin(t*PI)*6))
		draw_polyline(shine,Color(1,1,.88,.56),3,true)
		box(Rect2(13,size.y-15,size.x-26,5),Color(.9,1,.65,.25),3,Color.TRANSPARENT,0)
	var center := icon_center()
	if not symbol.is_empty():
		draw_set_transform(center,0,Vector2.ONE*symbol_scale)
		draw_symbol(symbol,Vector2.ZERO,18 if compact else (31 if menu_hero and symbol in ["play","paw"] else 22))
		draw_set_transform(Vector2.ZERO)
	var left := 63.0 if compact else 93.0
	if symbol.is_empty(): left=14
	if menu_hero: left=center.x+48
	var area := size.x-left-14
	if menu_hero: area=size.x-center.x-left+24
	var font := get_theme_font("font")
	var shown := caption_override if not caption_override.is_empty() else text
	var fs := title_size
	while fs>14 and font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>area: fs-=1
	var width := font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
	var baseline := r.get_center().y+fs*.34-(13 if menu_hero and not subtitle.is_empty() else (10 if not subtitle.is_empty() else 0))
	var p := Vector2(left+(area-width)*.5,baseline)
	var ink := Color("fffbe9") if not disabled else Color("acb8cc")
	draw_string_outline(font,p,shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,5,Color(0.06,.12,.23,.65))
	draw_string(font,p,shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,ink)
	if not subtitle.is_empty():
		var subsize := 18 if compact else 21
		var subwidth := font.get_string_size(subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,subsize).x
		draw_string(font,Vector2(left+(area-subwidth)*.5,baseline+subsize+5+(9 if menu_hero and symbol=="paw" else 0)),subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,subsize,ink)
func draw_symbol(kind: String, p: Vector2, radius: float) -> void:
	var white := Color("fff6d5")
	match kind:
		"play":
			var corners := [p+Vector2(-radius*.65,-radius),p+Vector2(radius*.8,0),p+Vector2(-radius*.65,radius)]
			var points := PackedVector2Array()
			for i in range(3):
				var a: Vector2 = corners[i].lerp(corners[(i+2)%3],.17)
				var b: Vector2 = corners[i].lerp(corners[(i+1)%3],.17)
				for step in range(7):
					var t := step/6.0
					points.append(a*(1-t)*(1-t)+corners[i]*2*t*(1-t)+b*t*t)
			draw_colored_polygon(points,white)
			points.append(points[0]); draw_polyline(points,Color("d8f08a"),3,true)
		"paw":
			draw_paw(p,radius)
		"pause":
			for x in [-8,8]: box(Rect2(p+Vector2(x-4,-14),Vector2(8,28)),white,3,Color.TRANSPARENT,0)
		"plus":
			draw_line(p-Vector2(radius,0),p+Vector2(radius,0),white,8,true)
			draw_line(p-Vector2(0,radius),p+Vector2(0,radius),white,8,true)
		"levels":
			for y in [10,1,-8]:
				var diamond := PackedVector2Array([p+Vector2(-radius,y),p+Vector2(0,y-11),p+Vector2(radius,y),p+Vector2(0,y+11)])
				draw_colored_polygon(diamond,Color("d1d5ff") if y==-8 else Color("8c99ea"))
				diamond.append(diamond[0]); draw_polyline(diamond,white,2.5,true)
		"undo":
			draw_arc(p+Vector2(1,3),radius*.7,-PI*.7,PI*.8,24,white,6,true)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-radius,-10),p+Vector2(-radius,7),p+Vector2(-radius+15,0)]),white)
		"hint":
			draw_circle(p-Vector2(0,5),radius*.62,Color("ffe992"))
			draw_arc(p-Vector2(0,5),radius*.62,0,TAU,32,white,2,true)
			draw_line(p+Vector2(-7,11),p+Vector2(7,11),white,4,true)
			draw_line(p+Vector2(-5,16),p+Vector2(5,16),white,3,true)
			for i in range(5):
				var a := PI+i*PI/4
				draw_line(p-Vector2(0,5)+Vector2.from_angle(a)*radius*.9,p-Vector2(0,5)+Vector2.from_angle(a)*radius*1.15,white,2,true)
		"settings":
			for i in range(8):
				var a := i*TAU/8
				draw_line(p+Vector2.from_angle(a)*radius*.55,p+Vector2.from_angle(a)*radius,white,8,true)
			draw_circle(p,radius*.72,white)
			draw_circle(p,radius*.3,tint.darkened(.4))
		"back": draw_polyline(PackedVector2Array([p+Vector2(7,-13),p+Vector2(-7,0),p+Vector2(7,13)]),white,5,true)
		"story":
			box(Rect2(p-Vector2(17,13),Vector2(34,26)),Color.TRANSPARENT,4,white,3)
			draw_line(p-Vector2(0,12),p+Vector2(0,12),white,2,true)

func draw_foliage() -> void:
	for side in [-1,1]:
		for i in range(7):
			var origin := Vector2(10 if side<0 else size.x-10,15+i*(size.y-25)/7)
			var direction := Vector2(side*(16+sin(i*1.8)*7),-12 if i%2==0 else 11)
			var normal := direction.orthogonal().normalized()*7
			var leaf := PackedVector2Array([origin,origin+direction*.4+normal,origin+direction,origin+direction*.4-normal])
			draw_colored_polygon(leaf,Color("84a52c") if i%2==0 else Color("3e7e26"))
			draw_line(origin,origin+direction*.84,Color("bdcb54"),1.2,true)

func paw_shape(center: Vector2, radius: float, tint: Color) -> void:
	var s:=radius/27.0
	for i in range(4):
		var pos: Vector2=[Vector2(-18,-8),Vector2(-7,-18),Vector2(7,-18),Vector2(18,-8)][i]
		var angle: float=[-.42,-.14,.14,.42][i]
		var oval:=PackedVector2Array()
		for j in range(28):
			var t:=j*TAU/28
			oval.append(center+(pos+Vector2(cos(t)*6.3,sin(t)*8.1).rotated(angle))*s)
		draw_colored_polygon(oval,tint)
	var corners: Array[Vector2]=[Vector2(0,-1),Vector2(-9,2),Vector2(-17,13),Vector2(-14,22),Vector2(-7,22),Vector2(0,25),Vector2(7,22),Vector2(14,22),Vector2(17,13),Vector2(9,2)]
	var pad:=PackedVector2Array()
	for i in range(corners.size()):
		var a:=corners[i].lerp(corners[(i+corners.size()-1)%corners.size()],.43)
		var b:=corners[i].lerp(corners[(i+1)%corners.size()],.43)
		for j in range(8):
			var t:=j/7.0
			pad.append(center+(a*(1-t)*(1-t)+corners[i]*2*t*(1-t)+b*t*t)*s)
	draw_colored_polygon(pad,tint)

func draw_paw(center: Vector2, radius: float) -> void:
	# One solid white silhouette, without outline, shadow or highlights.
	paw_shape(center,radius,Color.WHITE)
