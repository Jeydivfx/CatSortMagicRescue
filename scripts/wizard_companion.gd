extends Control

signal laugh_started

var portrait: Texture2D
var gentle := false
var age := 0.0
var cast_age := 10.0
var spell_target := Vector2.ZERO
var cast_count := 0
var angry := false
var emotion := 0
var previous_emotion := 0
var expression_blend := 1.0
var next_laugh := 6.0
var laugh_left := 0.0
var angry_age := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait = load("res://assets/characters/witch_expressions.png")

func cast(target: Vector2) -> void:
	spell_target = target-position
	cast_age = 0
	cast_count += 1

func reset() -> void:
	cast_age = 10
	cast_count = 0
	angry = false
	emotion = 0
	previous_emotion = 0
	expression_blend = 1
	laugh_left = 0
	angry_age = 0
	next_laugh = age+randf_range(5,9)

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	age += delta
	cast_age += delta
	if not angry and age>=next_laugh:
		laugh_left = 1.8
		next_laugh = age+randf_range(16,25)
		laugh_started.emit()
	angry_age = angry_age+delta if angry else 0.0
	laugh_left = maxf(0,laugh_left-delta)
	var desired := 2 if angry else (1 if laugh_left>0 else 0)
	if desired!=emotion:
		previous_emotion = emotion
		emotion = desired
		expression_blend = 0
	expression_blend = minf(1,expression_blend+delta/0.25)
	queue_redraw()

func _draw() -> void:
	const ART_SCALE := 1.65
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*ART_SCALE)
	var strength := maxf(0,1-cast_age/1.1)
	var bob := 0.0 if gentle else sin(age*1.8)*1.5
	var anger_envelope := sin(minf(angry_age/.35,1)*PI*.5)*exp(-angry_age*.8)
	var shake := sin(angry_age*9)*2.2*anger_envelope if angry and not gentle else 0.0
	var laugh_progress := clampf((1.8-laugh_left)/1.8,0,1)
	var laugh_envelope := sin(laugh_progress*PI)
	var chuckle := (1-cos(laugh_progress*TAU*3))*.9*laugh_envelope if emotion==1 and not gentle else 0.0
	draw_set_transform(Vector2(54,103)*ART_SCALE,0,Vector2(1,.13)*ART_SCALE)
	draw_circle(Vector2.ZERO,32,Color(0.05,0.08,0.15,.32))
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*ART_SCALE)
	if portrait:
		var breathe := 1.0 if gentle else 1.0+sin(age*2)*.012
		draw_set_transform(Vector2(48,106)*ART_SCALE,shake*.006,Vector2(1,breathe)*ART_SCALE)
		var destination := Rect2(-48+shake,-106+bob-chuckle,96,108)
		var cell := Vector2(portrait.get_width()/3.0,portrait.get_height())
		if expression_blend<1:
			draw_texture_rect_region(portrait,destination,Rect2(Vector2(previous_emotion*cell.x,0),cell),Color(1,1,1,1-expression_blend))
		draw_texture_rect_region(portrait,destination,Rect2(Vector2(emotion*cell.x,0),cell),Color(1,1,1,expression_blend))
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE*ART_SCALE)
	var pivot := Vector2(83,80+bob)
	var swing := sin(angry_age*7)*.24*anger_envelope if angry and not gentle else sin(age*1.4)*.025
	var tip := pivot+Vector2(13,-53).rotated(swing)
	draw_line(pivot,tip,Color("936443"),4,true)
	draw_circle(tip,5,Color("ffe29a"))
	draw_circle(tip,9,Color(1,.83,.45,.15+strength*.4))
	if strength<=0: return
	var end := spell_target
	if gentle:
		draw_circle(end,25,Color(.7,1,.87,strength*.15))
		return
	var curve := PackedVector2Array()
	for step in range(25):
		var t := step/24.0
		curve.append(tip.lerp(end,t)+Vector2(0,-sin(t*PI)*65))
	draw_polyline(curve,Color(.7,.86,1,strength*.65),2,true)
	for i in range(12):
		var t := fposmod(cast_age*1.4+i/12.0,1)
		var point := tip.lerp(end,t)+Vector2(0,-sin(t*PI)*65)
		draw_circle(point,2.5,Color(1,.88,.5,strength))
	draw_arc(end,18+cast_age*36,0,TAU,40,Color(.7,1,.87,strength),2,true)
