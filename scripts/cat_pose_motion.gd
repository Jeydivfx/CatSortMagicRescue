extends Node2D
# Authored airborne body + continuous sleep on the original silhouette. No skeleton or frame sheet.
var cat_kind:=0
var motion_profile: Dictionary={}
var image: Sprite2D
var surfaces: Dictionary={}
var textures: Dictionary={}
var regions: Dictionary={}
var waking := 0.0
var sleeping := false
var last_age := -1.0
var current := ""
var gentle_motion := false
var sleep_progress := 0.0
var sleep_age := 0.0
var z_strength := 0.0
var z_origin := Vector2(25,-49)
var z_font: Font=preload("res://assets/fonts/game_font.tres")
func configure(kind: int=0) -> void:
	cat_kind=kind
	motion_profile=preload("res://scripts/cat_motion_catalog.gd").profile(kind)
	image=Sprite2D.new();add_child(image);image.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	for state in ["air"]:
		var path: String="res://assets/cats/orange_pose_trial/%s.png"%state if cat_kind==0 else str(motion_profile.get("air_path",""))
		var texture=load(path) as Texture2D if ResourceLoader.exists(path) else null
		if texture:
			textures[state]=texture
			var bounds: Array=motion_profile.get("air_region",[198,59,941,1107])
			regions[state]=Rect2(bounds[0],bounds[1],bounds[2],bounds[3])
	hide()
func clear_pose(actor) -> void:
	hide()
	actor.face_material.set_shader_parameter("drowse",0.0)
	if is_instance_valid(actor.ear_material):actor.ear_material.set_shader_parameter("drowse",0.0)
	for surface in surfaces.values():surface.hide()
	if is_instance_valid(actor.victory_mesh):actor.victory_mesh.show()
	else:actor.sprite.show()
func pose(actor,state: String) -> void:
	if not textures.has(state):return
	show();image.show();image.texture=textures[state];image.region_enabled=true;image.region_rect=regions[state];image.region_filter_clip_enabled=true
	var region: Rect2=regions[state]
	var target: Vector2=actor.sprite.region_rect.size*actor.sprite.scale
	# Keep occupied height and planted paw baseline equal to the original kitten.
	var factor: float=target.y/region.size.y*1.12
	if cat_kind!=0:
		var eyes: Array=motion_profile.eyes
		factor=absf(float(eyes[2])-float(eyes[0]))*target.x/float(motion_profile.air_eye_spacing)*float(motion_profile.get("air_scale_adjust",1.0))
	image.scale=Vector2.ONE*factor
	image.position=Vector2(0,40-target.y*.5)
	if state=="air":
		# Match the eyes/head center, not the tucked feet, to avoid a head-size jump.
		var original_eye:=Vector2(-.04*target.x,actor.sprite.position.y-.135*target.y)
		var source_eye:=Vector2(610,420)
		if cat_kind!=0:
			var eyes: Array=motion_profile.eyes
			original_eye=(Vector2((float(eyes[0])+float(eyes[2]))*.5,(float(eyes[1])+float(eyes[3]))*.5)-Vector2.ONE*.5)*target+actor.sprite.position
			source_eye=preload("res://scripts/cat_motion_catalog.gd").vec2(motion_profile.air_eye_center)
		var air_eye:=(source_eye-region.get_center())*factor
		image.position=original_eye-air_eye
	else:image.position.y+=actor.stack_weight*4.0
	actor.sprite.hide()
	if is_instance_valid(actor.victory_mesh):actor.victory_mesh.hide()
	if is_instance_valid(actor.ear_mesh):actor.ear_mesh.hide()
	current=state
func update_sleep(actor,age: float,idle: float,eligible: bool,gentle: bool=false) -> void:
	gentle_motion=gentle
	clear_pose(actor)
	var delta: float=clampf(age-last_age,0,.05) if last_age>=0 else 1.0/60.0
	last_age=age
	var onset: float=12.0+fposmod(actor.phase*1.3,4.0)
	var dozing: bool=eligible and idle>onset
	var elapsed: float=maxf(0,idle-onset)
	var target: float=smoothstep(0,2.6,elapsed) if dozing else 0.0
	sleep_progress=move_toward(sleep_progress,target,delta/.35)
	sleeping=sleep_progress>.001
	sleep_age=elapsed
	z_strength=smoothstep(.94,1.0,sleep_progress) if dozing else 0.0
	var audible: bool=dozing and sleep_progress>.98
	if audible and not is_in_group("sleeping_cat_audio"):add_to_group("sleeping_cat_audio")
	elif not audible and is_in_group("sleeping_cat_audio"):remove_from_group("sleeping_cat_audio")
	z_origin=Vector2(25,-49+actor.stack_weight*10)
	if sleeping:
		# Keep the original silhouette and face coordinate system through the entire transition.
		show();image.hide()
		current="sleep" if sleep_progress>.98 else "drowsy"
		var closure: float=sleep_progress
		actor.face_material.set_shader_parameter("weights",Vector4(1-closure,closure,0,0))
		actor.face_material.set_shader_parameter("drowse",sleep_progress*(.3 if gentle else 1.0))
		actor.face_material.set_shader_parameter("head_tilt",0.0)
		actor.face_material.set_shader_parameter("idle_motion",.18 if gentle else .35)
		if is_instance_valid(actor.ear_material):
			actor.ear_material.set_shader_parameter("weights",Vector4(1-closure,closure,0,0))
			actor.ear_material.set_shader_parameter("drowse",sleep_progress*(.3 if gentle else 1.0))
	queue_redraw()
func _draw() -> void:
	if z_strength<.001:return
	for i in range(3):
		var t:=fposmod(sleep_age+i*.95,2.85)/2.85
		var alpha:=smoothstep(0,.18,t)*(1-smoothstep(.65,1,t))*z_strength
		var point:=z_origin+Vector2(i*3+sin(t*PI)*3,-t*22)
		var glyph: String="Z" if i==0 else "z"
		var font_size:=9 if i==0 else 7
		draw_string_outline(z_font,point,glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,1,Color(.08,.14,.24,alpha*.8))
		draw_string(z_font,point,glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(.78,.92,1,alpha))
func update_air(actor,t: float,airborne: bool) -> void:
	clear_pose(actor);sleeping=false;waking=0;sleep_progress=0;z_strength=0
	if is_in_group("sleeping_cat_audio"):remove_from_group("sleeping_cat_audio")
	actor.face_material.set_shader_parameter("weights",Vector4(1,0,0,0))
	if is_instance_valid(actor.ear_material):actor.ear_material.set_shader_parameter("weights",Vector4(1,0,0,0))
	if airborne and t>.16 and t<.86:
		pose(actor,"air");image.rotation=0
