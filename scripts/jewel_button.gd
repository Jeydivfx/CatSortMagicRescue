extends Button
## Native scalable candy button: no rasterized labels, all locales remain live.
var tint := Color("4164c8")
var symbol := ""
var subtitle := ""
var caption_override := ""
var title_size := 28
var compact := false
var menu_hero := false
var menu_medal := false
var navigation_art: Texture2D
var levels_art: Texture2D
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
	if name=="HomeSettings":
		var center:=size*.5
		var radius:=minf(size.x,size.y)*.47
		draw_circle(center+Vector2(0,2),radius,Color("3e190c"))
		draw_circle(center,radius-1,Color("e9a943"))
		draw_circle(center,radius-4,Color("7b401d"))
		draw_circle(center-Vector2(0,1),radius-7,Color("b87835"))
		draw_arc(center,radius-5,PI,TAU,40,Color("ffe2a0"),1.5,true)
		draw_symbol("settings",center,18)
		return
	var localizer=preload("res://scripts/localization.gd")
	# Captions can be assigned directly by live counters, bypassing t().
	var subtitle: String=localizer.digits(self.subtitle)
	if menu_medal:
		draw_medal();return
	var c := tint
	if disabled: c=c.lerp(Color("27324b"),.65)
	elif is_pressed(): c=c.darkened(.12)
	elif is_hovered(): c=c.lightened(.08)
	var r := Rect2(Vector2(2,2),size-Vector2(4,7))
	var radius := int(r.size.y*.39) if menu_hero else int(minf(28,r.size.y*.32))
	if name in ["ResultNext","ResultHome"]:radius=int(r.size.y*.48)
	var hero_play: bool=menu_hero and symbol in ["play","paw"]
	box(Rect2(0,4,size.x,size.y-4),Color("090e28"),radius+4,Color("313e72"),2)
	if hero_play:
		c=Color("41bf2e").lightened(.07 if is_hovered() else 0)
		if is_pressed():c=c.darkened(.14)
		box(Rect2(0,7,size.x,size.y-8),Color("241633"),radius+3,Color("51315d"),3)
		box(r,Color("64406d"),radius,Color("b99a66"),3)
	if not hero_play:box(r,c.darkened(.43),radius,c.lightened(.5),3 if menu_hero else 2)
	if name=="ResultNext":box(r,Color.TRANSPARENT,radius,Color("84ef76"),3)
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
	if hero_play:
		box(inner.grow(2),Color.TRANSPARENT,int(rad)+2,Color("2c2339"),2)
		box(inner.grow(-2),Color.TRANSPARENT,int(rad)-2,Color(.54,1,.80,.45),2)
		# A broad, curved translucent highlight gives the face depth while
		# keeping the center behind the lettering clear.
		var gloss:=PackedVector2Array()
		for i in range(33):
			var t: float=i/32.0
			gloss.append(Vector2(23+t*(size.x-46),20+sin(t*PI)*8))
		for i in range(32,-1,-1):
			var t: float=i/32.0
			gloss.append(Vector2(23+t*(size.x-46),size.y*.40+sin(t*PI)*8))
		draw_colored_polygon(gloss,Color(.68,1,.89,.07))
		for side in [-1,1]:
			var ornament:=Vector2(size.x*.5+side*(size.x*.5-5),size.y*.5-3)
			draw_colored_polygon(PackedVector2Array([ornament+Vector2(0,-12),ornament+Vector2(7,0),ornament+Vector2(0,12),ornament+Vector2(-7,0)]),Color("d6b779"))
			draw_circle(ornament,3,Color("ae7ed0"))
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
	var shown := localizer.digits(caption_override if not caption_override.is_empty() else text)
	var fs := title_size
	while fs>14 and font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>area: fs-=1
	var width := font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
	var baseline := r.get_center().y+fs*.34-(17 if hero_play and not subtitle.is_empty() else (13 if menu_hero and not subtitle.is_empty() else (10 if not subtitle.is_empty() else 0)))
	var p := Vector2(left+(area-width)*.5,baseline)
	var ink := Color("fffbe9") if not disabled else Color("acb8cc")
	draw_string_outline(font,p,shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,5,Color(0.06,.12,.23,.65))
	draw_string(font,p,shown,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,ink)
	if not subtitle.is_empty():
		var subsize := 18 if compact else 21
		var subwidth := font.get_string_size(subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,subsize).x
		var sub_baseline: float=size.y-29 if hero_play else baseline+subsize+5
		var sub_p:=Vector2(left+(area-subwidth)*.5,sub_baseline)
		draw_string_outline(font,sub_p,subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,subsize,3,Color(.05,.20,.07,.6))
		draw_string(font,sub_p,subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,subsize,ink)
func draw_medal() -> void:
	var center:=Vector2(size.x*.5,size.y*.40)
	var radius:=minf(size.x*.44,size.y*.41)
	draw_circle(center+Vector2(0,4),radius+3,Color("3e190c"))
	draw_circle(center,radius,Color("e9a943"))
	if has_focus():draw_arc(center,radius+3,0,TAU,64,Color("fff0b0"),2,true)
	draw_circle(center,radius-4,Color("7b401d"))
	draw_circle(center-Vector2(0,2),radius-9,Color("b87835").lightened(.08 if is_hovered() else 0))
	draw_arc(center,radius-6,PI,TAU,40,Color("ffe2a0"),2,true)
	if navigation_art==null:navigation_art=load("res://assets/branding/menu_navigation_icons.png")
	var icons: Texture2D=navigation_art
	if symbol=="map":
		if levels_art==null:levels_art=load("res://assets/branding/menu_levels_trail.png")
		draw_texture_rect(levels_art,Rect2(center-Vector2.ONE*radius*.94,Vector2.ONE*radius*1.88),false)
	elif icons:
		var index: int=0 if symbol=="trophy" else (1 if symbol=="settings" else 2)
		var cell_width: float=icons.get_width()/3.0
		var bounds:=Rect2(index*cell_width,0,cell_width,icons.get_height())
		draw_texture_rect_region(icons,Rect2(center-Vector2(radius*.92,radius*.94),Vector2.ONE*radius*1.84),bounds)
	else:draw_symbol(symbol,center-Vector2(0,3),radius*.55)
	var plate:=Rect2(1,size.y*.69,size.x-2,size.y*.29)
	box(plate,Color("69300e"),18,Color("efb563"),3)
	var font:=get_theme_font("font")
	var fs:=22
	while fs>12 and font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>size.x-14:fs-=1
	var width:=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
	var p:=Vector2((size.x-width)*.5,plate.get_center().y+fs*.34)
	var shaped:=TextLine.new()
	shaped.direction=TextServer.DIRECTION_RTL if preload("res://scripts/localization.gd").rtl() else TextServer.DIRECTION_AUTO
	shaped.add_string(text,font,fs)
	var origin:=Vector2((size.x-shaped.get_size().x)*.5,p.y-shaped.get_line_ascent())
	shaped.draw_outline(get_canvas_item(),origin,4,Color("38200e"))
	shaped.draw(get_canvas_item(),origin,Color("fff2ce"))
func draw_symbol(kind: String, p: Vector2, radius: float) -> void:
	var white := Color("fff6d5")
	if kind=="settings" and name=="HomeSettings":
		if navigation_art==null:navigation_art=load("res://assets/branding/menu_navigation_icons.png")
		var cell_width: float=navigation_art.get_width()/3.0
		draw_texture_rect_region(navigation_art,Rect2(p-Vector2(25,25),Vector2(50,50)),Rect2(cell_width,0,cell_width,navigation_art.get_height()))
		return
	match kind:
		"home":
			draw_polyline(PackedVector2Array([p+Vector2(-radius,-radius*.05),p+Vector2(0,-radius*.9),p+Vector2(radius,-radius*.05)]),white,5,true)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-radius*.7,0),p+Vector2(0,-radius*.6),p+Vector2(radius*.7,0),p+Vector2(radius*.7,radius*.85),p+Vector2(radius*.22,radius*.85),p+Vector2(radius*.22,radius*.3),p+Vector2(-radius*.22,radius*.3),p+Vector2(-radius*.22,radius*.85),p+Vector2(-radius*.7,radius*.85)]),white)
		"shelter":
			var roof:=PackedVector2Array([p+Vector2(-radius,radius*.05),p+Vector2(0,-radius*.85),p+Vector2(radius,radius*.05)])
			draw_polyline(roof,Color("ffdf85"),6,true)
			box(Rect2(p+Vector2(-radius*.7,-radius*.02),Vector2(radius*1.4,radius*.95)),Color("f5c477"),4,Color("ffe8ad"),2)
			draw_set_transform(p+Vector2(0,radius*.35),0,Vector2.ONE*.45)
			draw_paw(Vector2.ZERO,radius)
			draw_set_transform(Vector2.ZERO)
		"trophy":
			for side in [-1,1]:draw_arc(p+Vector2(side*radius*.65,-radius*.25),radius*.44,0,TAU,32,Color("ffcd36"),5,true)
			var cup:=PackedVector2Array([p+Vector2(-radius*.65,-radius*.8),p+Vector2(radius*.65,-radius*.8),p+Vector2(radius*.45,radius*.25),p+Vector2(0,radius*.47),p+Vector2(-radius*.45,radius*.25)])
			draw_colored_polygon(cup,Color("ffcf31"));cup.append(cup[0]);draw_polyline(cup,Color("fff0a0"),2,true)
			draw_line(p+Vector2(0,radius*.35),p+Vector2(0,radius*.8),Color("ffda46"),7,true)
			box(Rect2(p+Vector2(-radius*.5,radius*.73),Vector2(radius,radius*.23)),Color("ef9d14"),3,Color("ffe99a"),2)
		"map":
			var paper:=PackedVector2Array([p+Vector2(-radius,-radius*.65),p+Vector2(-radius*.3,-radius*.9),p+Vector2(radius*.3,-radius*.6),p+Vector2(radius,-radius*.85),p+Vector2(radius,radius*.85),p+Vector2(radius*.3,radius),p+Vector2(-radius*.3,radius*.7),p+Vector2(-radius,radius)])
			draw_colored_polygon(paper,Color("ffdc8c"));paper.append(paper[0]);draw_polyline(paper,Color("fff2bc"),2,true)
			draw_polyline(PackedVector2Array([p+Vector2(-radius*.6,radius*.5),p+Vector2(-radius*.1,0),p+Vector2(radius*.4,radius*.3)]),Color("d28b30"),2,true)
			draw_circle(p+Vector2(radius*.25,-radius*.7),radius*.35,Color("ed4935"))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-radius*.05,-radius*.6),p+Vector2(radius*.55,-radius*.6),p+Vector2(radius*.25,0)]),Color("ed4935"))
			draw_circle(p+Vector2(radius*.25,-radius*.7),radius*.14,Color("ffdf9a"))
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
		"music":
			# Musical note, scaled to the button's icon radius.
			var k := radius / 22.0
			draw_line(p + Vector2(3,-13)*k, p + Vector2(3,12)*k, white, 3.4*k, true)
			draw_line(p + Vector2(3,-13)*k, p + Vector2(16,-17)*k, white, 3.4*k, true)
			draw_line(p + Vector2(16,-17)*k, p + Vector2(16,8)*k, white, 3.4*k, true)
			draw_circle(p + Vector2(-3,12)*k, 6*k, white)
			draw_circle(p + Vector2(10,8)*k, 6*k, white)
		"effects":
			# Speaker with two sound waves.
			var k := radius / 22.0
			var speaker := PackedVector2Array([p+Vector2(-17,-7)*k,p+Vector2(-9,-7)*k,p+Vector2(1,-15)*k,p+Vector2(1,15)*k,p+Vector2(-9,7)*k,p+Vector2(-17,7)*k])
			draw_colored_polygon(speaker, white)
			draw_arc(p+Vector2(1,0)*k, 10*k, -PI*.38, PI*.38, 16, white, 2.7*k, true)
			draw_arc(p+Vector2(1,0)*k, 18*k, -PI*.35, PI*.35, 20, white, 2.7*k, true)
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
