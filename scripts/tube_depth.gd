extends RefCounted
static func oval(center: Vector2,radius: Vector2) -> PackedVector2Array:
	var points:=PackedVector2Array()
	for i in range(65):
		var a: float=i*TAU/64
		points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
	return points
static func base(g,rect: Rect2,s: float) -> void:
	var center:=Vector2(rect.get_center().x,rect.end.y+6*s)
	var radius:=Vector2(rect.size.x*.5+5*s,9*s)
	g.draw_colored_polygon(oval(center+Vector2(0,13*s),radius),Color("342342"))
	for row in range(14):
		var t: float=row/13.0
		g.draw_line(center+Vector2(-radius.x,row*s),center+Vector2(radius.x,row*s),Color("bc8550").lerp(Color("633c36"),t),s*1.2,true)
	g.draw_colored_polygon(oval(center,radius),Color("8e6380"))
	g.draw_polyline(oval(center,radius),Color("e8bd83"),1.8*s,true)
	g.draw_polyline(oval(center+Vector2(0,13*s),radius),Color(.32,.20,.29,.6),1.2*s,true)
	g.draw_polyline(oval(center-Vector2(0,2*s),Vector2(rect.size.x*.48,7*s)),Color(.68,.83,1,.6),1.3*s,true)
static func rim(g,rect: Rect2,s: float,tint: Color) -> void:
	var center:=Vector2(rect.get_center().x,rect.position.y+2*s)
	var radius:=Vector2(rect.size.x*.5,9*s)
	g.draw_polyline(oval(center,radius),Color(.45,.68,1,.15),7*s,true)
	g.draw_polyline(oval(center+Vector2(0,5*s),radius),Color(.70,.82,1,.65),2*s,true)
	g.draw_polyline(oval(center,radius),tint.lightened(.3),2.4*s,true)
	g.draw_polyline(oval(center,Vector2(radius.x-3*s,radius.y-2*s)),Color(.82,.94,1,.55),1*s,true)
