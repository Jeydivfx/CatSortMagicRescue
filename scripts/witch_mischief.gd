extends RefCounted
# One reversible witch trick per six successful player transfers; no accumulated back-to-back casts.
const MISCHIEF_CHANCE := 0.35
var successful_moves:=0
var next_due:=100000
var mischief_enabled_this_level:=false
var extra_moves:=0
var bonus_records: Array=[]
var phase:=""
var elapsed:=0.0
var targets: Array[int]=[]
var moving: Array=[]
var starts: Array[Vector2]=[]
var finishes: Array[Vector2]=[]
var effects_age:=10.0
var smoke_layer: Node2D
var smoke_points: Array[Vector2]=[]
var smoke_age:=10.0
func reset() -> void:
	successful_moves=0
	mischief_enabled_this_level=randf()<MISCHIEF_CHANCE
	next_due=6 if mischief_enabled_this_level else 100000
	extra_moves=0
	bonus_records.clear()
	clear()
	smoke_points.clear()
	smoke_age=10
	if is_instance_valid(smoke_layer):smoke_layer.queue_redraw()
func clear() -> void:
	for actor in moving:
		if is_instance_valid(actor):actor.set_meta("witch_swapping",false);actor.modulate.a=1.0
	phase="";elapsed=0;targets.clear();moving.clear();starts.clear();finishes.clear();effects_age=10
func due() -> bool:
	return mischief_enabled_this_level and successful_moves>=next_due and next_due<100000
func record_move(g) -> void:
	successful_moves+=1
	try_cast(g)
func choose_targets(g) -> Array[int]:
	# An empty buffer guarantees the exchanged top cats can be restored legally.
	if not g.tubes.any(func(t):return t.is_empty()):return []
	for a in range(g.tubes.size()):
		if not g.is_complete(g.tubes[a]):continue
		for b in range(a+1,g.tubes.size()):
			if g.is_complete(g.tubes[b]) and g.tubes[a].back()!=g.tubes[b].back():return [a,b]
	return []
func try_cast(g) -> bool:
	if not due() or not phase.is_empty() or g.screen!="game" or g.entering or g.busy or g.drag_active or g.won or g.lost or g.pending_reward>=0:return false
	if not g.audio.suspension_reasons.is_empty() or g.curse.pending>=0 or g.curse.left>0 or g.wizard.reaction in ["sort","curse","mischief"]:return false
	var pair:=choose_targets(g)
	if pair.size()!=2:return false
	targets.assign(pair);phase="cast";elapsed=0;g.busy=true;next_due=100000
	g.wizard.cast_mischief();g.audio.stop_cue("witch_laugh");g.audio.play("witch_laugh")
	g.message="The witch has another trick!";g.refresh()
	return true
func impact(g) -> bool:
	if phase!="cast":return false
	phase="swap";elapsed=0;effects_age=0;smoke_age=0;smoke_points.clear()
	for i in range(2):
		var tube: int=targets[i]
		for actor in g.actors:
			if int(actor.get_meta("tube"))==tube and int(actor.get_meta("slot"))==3:
				actor.set_meta("witch_swapping",true);moving.append(actor);starts.append(g.cat_position(tube,3));finishes.append(g.cat_position(targets[1-i],3))
	for point in starts:smoke_points.append(point)
	if not is_instance_valid(smoke_layer):
		smoke_layer=Node2D.new();smoke_layer.name="WitchExchangeSmoke";smoke_layer.z_index=70;g.add_child(smoke_layer)
		smoke_layer.draw.connect(func():draw_smoke(g))
	g.audio.play("witch_entry_spell")
	return true
func update(delta: float,g) -> void:
	effects_age+=delta
	if g.screen=="game" and g.audio.suspension_reasons.is_empty():smoke_age+=delta
	if is_instance_valid(smoke_layer):
		smoke_layer.visible=g.screen=="game" and smoke_age<1.05
		if smoke_layer.visible:smoke_layer.queue_redraw()
	if phase.is_empty():try_cast(g);return
	if g.screen!="game" or not g.audio.suspension_reasons.is_empty():return
	elapsed+=delta
	if phase=="cast":
		if elapsed>1.5:impact(g) # Safety if the visual character is unavailable.
		return
	for i in range(moving.size()):
		var actor=moving[i]
		if not is_instance_valid(actor):continue
		actor.animate(g.clock,false,0,0,g.reduced_motion);actor.scale*=g.board_scale();actor.z_index=40+i
		# Disappear and reappear inside two stationary smoke clouds. Never show
		# a kitten sliding through the board or a silhouette jumping between them.
		actor.position=starts[i] if elapsed<.36 else finishes[i]
		actor.modulate.a=1.0-smoothstep(.04,.25,elapsed) if elapsed<.36 else smoothstep(.43,.70,elapsed)
	if elapsed>=.72:
		var a: int=targets[0];var b: int=targets[1]
		var saved: int=g.tubes[a][3];g.tubes[a][3]=g.tubes[b][3];g.tubes[b][3]=saved
		bonus_records.append({"depth":g.history.size(),"moves":3})
		extra_moves+=3 # The reversible trick needs a three-move buffer recovery.
		clear();effects_age=0;g.busy=false;g.message="The witch swapped two kittens!  +3 moves";g.refresh()
func draw_smoke(g) -> void:
	if smoke_age>=1.05:return
	var fade: float=smoothstep(0,.16,smoke_age)*(1.0-smoothstep(.62,1.05,smoke_age))
	var grow: float=lerpf(.45,1.0,smoothstep(0,.32,smoke_age))
	var scale: float=g.board_scale()
	for index in range(smoke_points.size()):
		var center: Vector2=smoke_points[index]-Vector2(0,12*scale)
		for strand in range(3):
			var ribbon:=PackedVector2Array()
			for step in range(36):
				var t: float=step/35.0
				var angle: float=t*TAU*1.25+strand*TAU/3+smoke_age*3
				ribbon.append(center+Vector2(cos(angle)*(14+28*t)*grow,sin(angle)*(9+18*t)*grow-20*smoke_age)*scale)
			smoke_layer.draw_polyline(ribbon,Color(.83,.56,1,fade*.45),2*scale,true)
		for spark in range(9):
			var angle: float=spark*2.399+smoke_age
			var point: Vector2=center+Vector2.from_angle(angle)*(25+smoke_age*38)*scale
			var sparkle: float=fade*(.5+.5*sin(spark+smoke_age*7))
			smoke_layer.draw_line(point-Vector2(2,0)*scale,point+Vector2(2,0)*scale,Color(.96,.8,1,sparkle),1.3,true)
			smoke_layer.draw_line(point-Vector2(0,3)*scale,point+Vector2(0,3)*scale,Color(.96,.8,1,sparkle),1.3,true)
		for puff in range(11):
			var angle: float=puff*2.399+index*.7+smoke_age*(.2 if g.reduced_motion else 1.5)
			var spread: float=(13+sqrt(float(puff))*9)*scale*grow
			var drift: float=smoke_age*(5 if g.reduced_motion else 18)*scale
			var point: Vector2=center+Vector2(cos(angle)*spread,sin(angle)*spread*.7-drift)
			var radius: float=(23+puff%3*5)*scale*grow
			var tint:=Color(.41,.20,.62) if index==0 else Color(.58,.25,.76)
			for layer in range(5,0,-1):
				var f: float=layer/5.0
				var shade: Color=tint.lerp(Color(.80,.59,.94),puff/22.0)
				shade.a=fade*(.09 if layer==5 else .16)
				smoke_layer.draw_circle(point,radius*f,shade)
func soft_glow(g,point: Vector2,radius: float,color: Color,alpha: float) -> void:
	for layer in range(10,0,-1):
		var f:=layer/10.0;var tint:=color;tint.a=.025*(1.0-f*.65)*alpha
		g.draw_circle(point,radius*f,tint)
func rune_circle(g,point: Vector2,radius: float,spin: float,alpha: float) -> void:
	var pale:=Color(.84,.60,1,alpha*.75)
	g.draw_set_transform(point,spin,Vector2(1,.42))
	g.draw_arc(Vector2.ZERO,radius,0,TAU,64,pale,1.5,true)
	g.draw_arc(Vector2.ZERO,radius*.78,.3,TAU-.5,48,Color(.62,.35,1,alpha*.45),1.0,true)
	for i in range(8):
		var direction:=Vector2.from_angle(i*TAU/8)
		g.draw_line(direction*(radius-3),direction*(radius+3),pale,1.5,true)
	g.draw_set_transform(Vector2.ZERO)
func beam_point(origin: Vector2,target: Vector2,t: float,clock: float,gentle: bool) -> Vector2:
	var lift:=minf(260.0,origin.distance_to(target)*.32)
	var bend: float=85.0 if target.x>origin.x else -85.0
	var p:=origin.bezier_interpolate(origin+Vector2(bend,-lift),target+Vector2(-bend,-45),target,t)
	return p+Vector2(sin(t*TAU*2+clock*2.0)*(0.5 if gentle else 2.0)*sin(PI*t),0)
func draw_magic(g) -> void:
	if phase.is_empty():return
	var gentle: bool=g.reduced_motion
	var strength: float=smoothstep(0,.30,elapsed) if phase=="cast" else 1.0-smoothstep(.40,.72,elapsed)
	var origin: Vector2=g.wizard.position+g.wizard.staff_position()
	var purple:=Color(.71,.30,1)
	var charge: float=smoothstep(0,.85,elapsed) if phase=="cast" else 1.0
	soft_glow(g,origin,38+charge*30,purple,strength*1.5)
	g.draw_circle(origin,4+charge*3,Color(.94,.80,1,strength))
	rune_circle(g,origin,13+charge*9,g.clock*.65,strength*.7)
	var ground: Vector2=g.wizard.position+g.wizard.staff_ground_position()
	rune_circle(g,ground,32,g.clock*.22,strength*.40)
	for index in range(targets.size()):
		var point: Vector2=g.cat_position(targets[index],3)
		if phase=="swap" and index<moving.size() and is_instance_valid(moving[index]):point=moving[index].position
		point.y-=8*g.board_scale()
		var tint:=Color(.73,.38,1) if index==0 else Color(.48,.64,1)
		soft_glow(g,point,62*g.board_scale(),tint,strength*1.5)
		rune_circle(g,point+Vector2(0,12*g.board_scale()),48*g.board_scale(),g.clock*(.45 if index==0 else -.45),strength)
		for spark in range(3 if gentle else 6):
			var angle: float=g.clock*.8+spark*TAU/6.0+index
			var orbit: Vector2=point+Vector2(cos(angle)*48,sin(angle)*40)*g.board_scale()
			var size: float=(2.0+.7*sin(g.clock*2+spark))*g.board_scale()
			g.draw_line(orbit-Vector2(size,0),orbit+Vector2(size,0),Color(.93,.76,1,strength*.8),1.2,true)
			g.draw_line(orbit-Vector2(0,size),orbit+Vector2(0,size),Color(.93,.76,1,strength*.8),1.2,true)
		if phase=="cast":
			var reveal: float=smoothstep(.08,.78,elapsed)
			var path:=PackedVector2Array()
			for j in range(49):path.append(beam_point(origin,point,j/48.0*reveal,g.clock,gentle))
			if path.size()>1:
				g.draw_polyline(path,Color(.60,.25,1,.07*strength),16,true)
				g.draw_polyline(path,Color(.71,.43,1,.22*strength),7,true)
				g.draw_polyline(path,Color(.90,.72,1,.85*strength),1.8,true)
			for j in range(3 if gentle else 7):
				var t: float=fposmod(elapsed*.60+j/7.0+index*.09,1.0)
				if t>reveal:continue
				var mote:=beam_point(origin,point,t,g.clock,gentle)
				var alpha: float=sin(PI*t)*strength
				g.draw_circle(mote,2.5,Color(.98,.84,1,alpha))


func on_undo(history_depth: int) -> void:
	bonus_records=bonus_records.filter(func(record):return int(record.depth)<=history_depth)
	extra_moves=0
	for record in bonus_records:extra_moves+=int(record.moves)
