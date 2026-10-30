extends "res://scripts/witch_model_v2.gd"
func art_texture_path() -> String:return "res://assets/witch_classic/parts.png"
func art_manifest_path() -> String:return "res://assets/witch_classic/parts.json"
func staff_grip_offset() -> float:return 32.0
func build() -> void:
	if atlas:return
	super.build()
	face.scale=Vector2.ONE*1.88;face.position.y+=7.52
func apply_pose(p: Dictionary) -> void:
	var adjusted:=p.duplicate()
	adjusted.left_y-=32*smoothstep(-160,-32,p.left_y);adjusted.right_y-=32*smoothstep(-160,-32,p.right_y)
	super.apply_pose(adjusted)
	hat_art.rotation=-p.head_angle*.18+p.surprise*.025
	shoulder_l.z_index=4 if p.tear>.05 or p.point>.5 else 0
	shoulder_r.z_index=4 if p.tear>.05 else 0
func draw_face() -> void:
	if pose_data.is_empty():return
	var p:=pose_data;var ink:=Color("34253f")
	var cheer: float=clampf((p.smile-.28)/.65,0,1)*(1-p.sad)
	var opening: float=minf(clampf(1-p.blink,0,1),1-cheer*.98)
	for side in [-1,1]:
		var eye:=Vector2(side*11,-7)
		if opening>.10:
			oval(face,eye,Vector2(7,6*opening*(1+p.surprise*.3)),Color("fff9df"))
			var glance:=Vector2(p.gaze_x,p.gaze_y)+gaze*.45
			oval(face,eye+glance,Vector2(3,4*opening),Color("5a8b5d"));oval(face,eye+glance,Vector2(1.5,3*opening),ink)
			oval(face,eye+glance+Vector2(-.7,-1.5),Vector2(.65,.8*opening),Color("fff9df"))
		else:
			var lid:=PackedVector2Array()
			for i in range(17):
				var t:=i/16.0;lid.append(eye+Vector2(lerpf(-7,7,t),2+sin(t*PI)*lerpf(-3.2,2.5,clampf(p.sad,0,1))))
			line_curve(face,lid,ink,2.2)
		var brow:=PackedVector2Array()
		for i in range(17):
			var t:=i/16.0
			brow.append(eye+Vector2(lerpf(-8,8,t),-10-sin(t*PI)*1.4-side*(t-.5)*p.anger*9+side*(t-.5)*p.sad*9-p.surprise*3-cheer))
		line_curve(face,brow,ink,2.1)
		oval(face,Vector2(side*17,6),Vector2(6,3),Color(.9,.42,.44,.25+p.anger*.18))
	face.draw_colored_polygon(PackedVector2Array([Vector2(0,-4),Vector2(12,5),Vector2(1,8),Vector2(-2,5)]),Color("e8a683"))
	if p.surprise>.45:oval(face,Vector2(1,16),Vector2(4,5*p.surprise),Color("703146"))
	elif p.mouth>.14 and cheer>.15:
		var mouth:=PackedVector2Array()
		for i in range(17):
			var t:=i/16.0;var x:=lerpf(-11,12,t);mouth.append(Vector2(x,11+sin(t*PI)*3))
		for i in range(16,-1,-1):
			var t:=i/16.0;mouth.append(Vector2(lerpf(-11,12,t),11+sin(t*PI)*(4+p.mouth*13)))
		face.draw_colored_polygon(mouth,Color("703146"))
		face.draw_colored_polygon(PackedVector2Array([Vector2(-7,13),Vector2(8,13),Vector2(6,16),Vector2(-5,16)]),Color("fff4df"))
		oval(face,Vector2(1,15+p.mouth*8),Vector2(5,2.3),Color("ef8e9a"))
	else:
		var mouth:=PackedVector2Array()
		for i in range(17):
			var t:=i/16.0;mouth.append(Vector2(lerpf(-9,10,t),14+sin(t*PI)*(p.smile*8-p.sad*3)))
		line_curve(face,mouth,Color("8e4056"),2.0)
	if p.tear>.01:
		var phase: float=p.get("tear_phase",0.0)
		for side in [-1,1]:
			var fall:=fposmod(phase*.8+(0.3 if side>0 else 0),1.0)
			oval(face,Vector2(side*19,3+fall*12),Vector2(1.4,2.6),Color(.55,.82,.96,p.tear*(1-fall*.6)))
	if p.sweat>.01:oval(face,Vector2(25,-13),Vector2(2,4),Color(.55,.82,.96,p.sweat))
