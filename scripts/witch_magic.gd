extends Node2D
## Short, non-blocking spell exchange: the completed kittens repel her magic.
var game
var bursts: Array[Dictionary] = []
func draw_warning() -> void:
	if not is_instance_valid(game) or game.curse.pending<0:return
	var rect: Rect2=game.tube_rect(game.curse.pending)
	var pulse:=.55+.25*sin(Time.get_ticks_msec()*.012)
	var frame:=StyleBoxFlat.new();frame.bg_color=Color(.8,.25,1,.04);frame.border_color=Color(.95,.55,1,pulse)
	frame.set_corner_radius_all(25);frame.set_border_width_all(3)
	draw_style_box(frame,rect.grow(6))
	var center:=rect.position+Vector2(rect.size.x*.5,-18)
	draw_circle(center,17,Color(.28,.08,.40,.95))
	draw_string(preload("res://assets/fonts/game_font.tres"),center+Vector2(-4,7),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("ffe2a0"))
func strike(origin: Vector2, target: Vector2, protected: bool, shield_size: Vector2 = Vector2(108,250)) -> void:
	if bursts.size()>=3: bursts.pop_front()
	bursts.append({"origin":origin,"target":target,"protected":protected,"age":0.0,"shield_size":shield_size})
	queue_redraw()
func _process(delta: float) -> void:
	if not is_visible_in_tree() or not is_instance_valid(game) or game.screen!="game" or game.entering or not game.audio.suspension_reasons.is_empty(): return
	for burst in bursts: burst.age+=delta
	bursts=bursts.filter(func(b):return b.age<1.65)
	queue_redraw()
func _draw() -> void:
	draw_warning()
	draw_curse()
	for burst in bursts:
		var age: float=burst.age
		var origin: Vector2=burst.origin
		var target: Vector2=burst.target
		var alpha:=1-smoothstep(.7,1.65,age)
		var power:=.45 if game.reduced_motion else 1.0
		# Elliptical paint splash sits on the ground, clear of controls and cats.
		for i in range(16):
			var a:=i*TAU/16
			var radius: float=(18+minf(age,.6)*105)*power
			var p:=origin+Vector2(cos(a)*radius,sin(a)*radius*.26)
			draw_circle(p,(3+sin(i*2.3)*1.5)*power,Color(.65,.24,.95,alpha*.6))
		var paint:=PackedVector2Array()
		for i in range(24):
			var a:=i*TAU/24
			var reach: float=(20+minf(age,.6)*60)*(1+sin(i*2.2)*.2)*power
			paint.append(origin+Vector2(cos(a)*reach,sin(a)*reach*.3))
		draw_colored_polygon(paint,Color(.55,.12,.83,alpha*.2))
		var ring:=PackedVector2Array()
		for i in range(65):
			var a:=i*TAU/64
			ring.append(origin+Vector2(cos(a)*(14+minf(age,.7)*100)*power,sin(a)*(5+minf(age,.7)*24)*power))
		draw_polyline(ring,Color(.76,.36,1,alpha*.55),3,true)
		if not burst.protected: continue
		var travel:=clampf((age-.12)/.65,0,1)
		if travel<1:
			for i in range(12):
				var t:=maxf(0,travel-i*.024)
				var p:=origin.lerp(target,t)+Vector2(sin(t*TAU)*13,-sin(t*PI)*65)*power
				draw_circle(p,maxf(1,6-i*.4),Color(.78,.4,1,.65-i*.045))
		else:
			var impact:=age-.77
			var fade:=1-clampf(impact/.85,0,1)
			var shield:=PackedVector2Array()
			var extent: Vector2=burst.shield_size*.55+Vector2.ONE*impact*12*power
			for i in range(65):
				var a:=i*TAU/64
				shield.append(target+Vector2(cos(a),sin(a))*extent)
			draw_polyline(shield,Color(1,.83,.35,fade*.75),3,true)
			draw_arc(target,24+impact*65*power,0,TAU,48,Color(1,.83,.35,fade*.5),2,true)
			for i in range(14):
				var direction:=Vector2.from_angle(i*TAU/14)
				var p:=target+direction*(18+impact*95)*power
				draw_line(p-direction*4,p+direction*4,Color(1,.89,.58,fade),2,true)

func draw_curse() -> void:
	if not is_instance_valid(game) or game.curse.left<=0:return
	var rect: Rect2=game.tube_rect(game.curse.tube)
	var alpha: float=minf(1,game.curse.left/.3)
	var frame:=StyleBoxFlat.new()
	frame.bg_color=Color(.42,.13,.66,.13*alpha)
	frame.border_color=Color(.76,.43,1,alpha*.85)
	frame.set_border_width_all(3)
	frame.set_corner_radius_all(28)
	draw_style_box(frame,rect.grow(4))
	var center:=rect.position+Vector2(rect.size.x*.5,18)
	draw_circle(center,20,Color(.20,.08,.35,alpha*.92))
	draw_string(preload("res://assets/fonts/game_font.tres"),center+Vector2(22,7),str(game.curse.turns_left),HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ffe4a0"))
	draw_arc(center-Vector2(0,4),7,PI,TAU,16,Color(.94,.77,1,alpha),3,true)
	var lock:=StyleBoxFlat.new()
	lock.bg_color=Color(.85,.65,1,alpha)
	lock.set_corner_radius_all(3)
	draw_style_box(lock,Rect2(center+Vector2(-10,-4),Vector2(20,16)))
	draw_circle(center+Vector2(0,2),2,Color(.22,.08,.39,alpha))
	draw_arc(center,23,-PI/2,-PI/2+TAU*game.curse.left/2.6,32,Color(.93,.78,1,alpha),2,true)
	for i in range(6):
		var t: float=fposmod(game.clock*.4+i/6.0,1)
		var side: float=-1 if i%2==0 else 1
		var p:=rect.get_center()+Vector2(side*(rect.size.x*.5+8),rect.size.y*(t-.5))
		draw_circle(p,2.5,Color(.88,.62,1,alpha*.7))
