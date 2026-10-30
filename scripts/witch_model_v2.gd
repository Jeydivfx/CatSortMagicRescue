extends Node2D
const POSES=preload("res://scripts/witch_pose_v2.gd")
const MODEL_HEIGHT=328.0
var atlas: Texture2D
var parts: Dictionary={}
var pose_data: Dictionary={}
var torso: Node2D
var neck: Node2D
var shoulder_l: Node2D
var shoulder_r: Node2D
var elbow_l: Node2D
var elbow_r: Node2D
var staff: Sprite2D
var broom: Sprite2D
var shoe_l: Sprite2D
var shoe_r: Sprite2D
var face: Node2D
var hat_art: Sprite2D
var spell_glow: Node2D
var drop_base:=Vector2(62,0)
var was_dropped:=false
var gaze:=Vector2.ZERO
func _ready() -> void:build()
func art_texture_path() -> String:return "res://assets/witch_v2/parts.png"
func art_manifest_path() -> String:return "res://assets/witch_v2/parts.json"
func staff_grip_offset() -> float:return 66.0
func bone(parent: Node,pos: Vector2=Vector2.ZERO) -> Node2D:
	var n:=Node2D.new();n.position=pos;parent.add_child(n);return n
func art(name: String,parent: Node,width: float,height: float=0) -> Sprite2D:
	var s:=Sprite2D.new();s.texture=atlas;s.region_enabled=true;s.region_filter_clip_enabled=true
	var r: Array=parts[name].rect;s.region_rect=Rect2(r[0],r[1],r[2],r[3])
	s.scale=Vector2(width/r[2],width/r[2] if height<=0 else height/r[3]);parent.add_child(s);return s
func build() -> void:
	if atlas:return
	atlas=load(art_texture_path());parts=JSON.parse_string(FileAccess.get_file_as_string(art_manifest_path())).parts
	broom=art("broom",self,196);broom.position=Vector2(0,-28);broom.visible=false
	shoe_l=art("shoe_left",self,42);shoe_l.position=Vector2(-24,-shoe_l.region_rect.size.y*shoe_l.scale.y*.5)
	shoe_r=art("shoe_right",self,42);shoe_r.position=Vector2(24,-shoe_r.region_rect.size.y*shoe_r.scale.y*.5)
	torso=bone(self)
	var gown:=art("body",torso,137,128);gown.position=Vector2(0,-76)
	shoulder_l=bone(torso,Vector2(-43,-122));shoulder_r=bone(torso,Vector2(43,-122))
	var upper_l:=art("upper_left",shoulder_l,36,54);upper_l.position=Vector2(0,25)
	var upper_r:=art("upper_right",shoulder_r,36,54);upper_r.position=Vector2(0,25)
	elbow_l=bone(shoulder_l,Vector2(0,42));elbow_r=bone(shoulder_r,Vector2(0,42))
	var lower_l:=art("fore_left",elbow_l,35,64);lower_l.position=Vector2(0,30)
	var lower_r:=art("fore_right",elbow_r,35,64);lower_r.position=Vector2(0,30)
	staff=art("staff",self,24,192);staff.z_index=1
	neck=bone(torso,Vector2(0,-143));neck.z_index=3
	var hair:=art("head",neck,160);hair.position=Vector2(0,-35)
	face=bone(neck);face.scale=Vector2.ONE*1.45
	var skin: Array=parts.head.face
	face.position=hair.position+Vector2((skin[0]+skin[2]*.5-.5)*160,(skin[1]+skin[3]*.5-.5)*hair.region_rect.size.y*hair.scale.y)
	face.draw.connect(draw_face)
	hat_art=art("hat",neck,160);hat_art.position=Vector2(-2,-121);hat_art.z_index=1
	spell_glow=bone(self);spell_glow.z_index=5;spell_glow.draw.connect(draw_spell)
	apply_pose(POSES.neutral())
func ik(root: Node2D,elbow: Node2D,target: Vector2,side: float) -> void:
	var delta:=target-root.position;var d:=clampf(delta.length(),10.0,92.8)
	var angle:=side*acos(clampf((d*d-42.0*42.0-51.0*51.0)/(2*42.0*51.0),-1,1))
	var base:=atan2(delta.y,delta.x)-atan2(51*sin(angle),42+51*cos(angle))
	root.rotation=base-PI*.5;elbow.rotation=angle
func apply_pose(p: Dictionary) -> void:
	if not atlas:build()
	pose_data=p
	torso.position=Vector2(0,p.body_y);torso.rotation=p.body_angle
	neck.position=Vector2(0,-143+p.head_y);neck.rotation=p.head_angle
	ik(shoulder_l,elbow_l,Vector2(p.left_x,p.left_y),-1)
	ik(shoulder_r,elbow_r,Vector2(p.right_x,p.right_y),1)
	shoe_l.position.y=-shoe_l.region_rect.size.y*shoe_l.scale.y*.5-p.feet_up
	shoe_r.position.y=-shoe_r.region_rect.size.y*shoe_r.scale.y*.5-p.feet_up
	broom.visible=p.broom>.5
	# Exactly one staff node. Its held/drop transforms share the same contact point.
	var hand:=elbow_r.position+Vector2(0,51).rotated(elbow_r.rotation)
	hand=shoulder_r.position+hand.rotated(shoulder_r.rotation)
	hand=torso.position+hand.rotated(torso.rotation)
	staff.visible=p.staff_show>.5
	var angle: float=p.staff_angle
	var grip: Vector2=hand
	if p.staff_drop>0:
		if not was_dropped:
			drop_base=hand+Vector2(5,96-staff_grip_offset()).rotated(angle);drop_base.y=0
		was_dropped=true
		angle=lerpf(angle,-PI*.5,p.staff_drop)
		grip=drop_base-Vector2(5,96-staff_grip_offset()).rotated(angle)
	else:was_dropped=false
	staff.rotation=angle;staff.position=grip+Vector2(5,-staff_grip_offset()).rotated(angle)
	face.queue_redraw();spell_glow.queue_redraw()
func staff_tip() -> Vector2:return staff.position+Vector2(0,-92).rotated(staff.rotation)
func staff_bottom() -> Vector2:return staff.position+Vector2(0,96).rotated(staff.rotation)
func head_point() -> Vector2:return torso.position+(neck.position+Vector2(0,-55).rotated(neck.rotation)).rotated(torso.rotation)
func oval(n: Node2D,p: Vector2,r: Vector2,color: Color) -> void:
	n.draw_set_transform(p,0,r);n.draw_circle(Vector2.ZERO,1,color);n.draw_set_transform(Vector2.ZERO)
func line_curve(n: Node2D,points: PackedVector2Array,color: Color,width: float) -> void:n.draw_polyline(points,color,width,true)
func draw_face() -> void:
	if pose_data.is_empty():return
	var p:=pose_data;var ink:=Color("493044")
	var close: float=clampf(p.blink,0,1);var opening:=maxf(.015,1-close)
	for side in [-1,1]:
		var eye:=Vector2(side*12.5,-10)
		if opening>.12:
			oval(face,eye,Vector2(7.0,7.4*opening*(1+p.surprise*.15)),Color("fff6df"))
			var look:=Vector2(p.gaze_x,p.gaze_y)+gaze*.45
			oval(face,eye+look,Vector2(3.6,5.2*opening),Color("5b9c61"))
			oval(face,eye+look,Vector2(1.9,4.1*opening),ink)
			oval(face,eye+look+Vector2(-1.1,-2*opening),Vector2(1.0,1.25*opening),Color("fffdf3"))
		else:
			var eyelid:=PackedVector2Array()
			for i in range(13):
				var t:=i/12.0;eyelid.append(eye+Vector2(lerpf(-7,7,t),1-sin(t*PI)*2.3))
			line_curve(face,eyelid,ink,1.6)
		var brow:=PackedVector2Array()
		for i in range(13):
			var t:=i/12.0
			brow.append(eye+Vector2(lerpf(-8,8,t),-12-sin(t*PI)*1.7-side*(t-.5)*p.anger*7+side*(t-.5)*p.sad*7-p.surprise*3))
		line_curve(face,brow,ink,2.0)
		oval(face,Vector2(side*18,4),Vector2(5.5,2.5),Color(.94,.43,.42,.15+.10*p.anger))
	# A stable shaded pointed nose and a geometric mouth, never facial-image fades.
	face.draw_colored_polygon(PackedVector2Array([Vector2(0,-1),Vector2(8,5),Vector2(1,7),Vector2(-1,4)]),Color("e4aa86"))
	face.draw_line(Vector2(1,6),Vector2(6,5),Color("c58a73"),.9,true)
	if p.surprise>.45:
		oval(face,Vector2(0,17),Vector2(3.5,3.0+p.mouth*5),Color("713447"))
	elif p.mouth>.13:
		var mouth:=PackedVector2Array()
		for i in range(17):
			var x:=lerpf(-10,10,i/16.0);mouth.append(Vector2(x,15-p.smile*2*pow(x/10,2)))
		for i in range(16,-1,-1):
			var x:=lerpf(-10,10,i/16.0);mouth.append(Vector2(x,15-p.smile*2*pow(x/10,2)+p.mouth*11*sqrt(maxf(0,1-pow(x/10,2)))))
		face.draw_colored_polygon(mouth,Color("713447"));mouth.append(mouth[0]);line_curve(face,mouth,Color("8c3e52"),1.0)
		var teeth:=PackedVector2Array([Vector2(-7,14.6),Vector2(7,14.6),Vector2(5,17),Vector2(-5,17)])
		face.draw_colored_polygon(teeth,Color("fff6de"))
		oval(face,Vector2(0,15+p.mouth*8.5),Vector2(4,1.5),Color("e48a96"))
	else:
		var mouth:=PackedVector2Array()
		for i in range(17):
			var t:=i/16.0;mouth.append(Vector2(lerpf(-10,10,t),17+sin(t*PI)*p.smile*4))
		line_curve(face,mouth,Color("8d4355"),1.5)
	if p.sweat>.1:oval(face,Vector2(24,-12),Vector2(2,4),Color(.5,.8,.94,p.sweat))
	if p.tear>.1:
		for side in [-1,1]:oval(face,Vector2(side*14,2),Vector2(1.7,4),Color(.5,.8,.96,p.tear))
func draw_spell() -> void:
	if pose_data.is_empty() or pose_data.spell<=0:return
	var p:=staff_tip();var amount: float=pose_data.spell
	spell_glow.draw_circle(p,14,Color(.64,.28,.97,amount*.16))
	spell_glow.draw_circle(p,8,Color(.77,.47,1,amount*.35))
	spell_glow.draw_circle(p,3,Color(.97,.88,1,amount*.85))
