extends Node2D

var sprite: Sprite2D
var overlay: Sprite2D
var face_tween: Tween
var phase := 0.0
var kind := 0
var art_kind := 0
var cell := Vector2.ZERO
var face := -1
var forced_face := -1
var face_material: ShaderMaterial
var face_weights := Vector4(1, 0, 0, 0)
var last_age := -1.0
var greet_until := -1.0
var last_blink := 0.0
var frame_rects: Dictionary = {}
static var atlas_rect_cache: Dictionary = {}
static var size_profiles: Dictionary = {}
var ear_mesh: MeshInstance2D
var ear_material: ShaderMaterial
var stack_target := 0.0
var stack_weight := 0.0
var victory_mesh: MeshInstance2D
var menu_ears_enabled := false
var pose_motion: Node2D
var orange_pose: Node2D:
	get:return pose_motion

func setup(atlas: Texture2D, cat_kind: int, offset: float) -> void:
	phase = offset
	kind = cat_kind
	atlas = preload("res://scripts/cat_breeds.gd").texture_for(cat_kind)
	art_kind = cat_kind%4
	modulate = Color.WHITE
	cell = atlas.get_size() / 4.0
	frame_rects = atlas_rect_cache.get(atlas.resource_path, {})
	if frame_rects.is_empty():
		var image := atlas.get_image()
		if atlas.resource_path.contains("/cats/breeds_"):
			var indexed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cats/frames.json"))[atlas.resource_path]
			for row in range(4):
				for col in range(4):
					var bounds: Array = indexed["%d,%d" % [col,row]]
					frame_rects[Vector2i(col,row)] = Rect2(bounds[0],bounds[1],bounds[2],bounds[3])
			atlas_rect_cache[atlas.resource_path] = frame_rects
	if frame_rects.is_empty():
		var image := atlas.get_image()
		# The painted atlas has uneven gutters; explicit separators avoid sampling
		# the next row's ears and keep the grumpy pose's head intact.
		var columns := [0.0,0.267,0.504,0.748,1.0] if cat_kind >= 7 else [0.0,0.262,0.5,0.738,1.0]
		var rows := [0.0,0.25,0.492,0.732,1.0] if cat_kind >= 7 else [0.0,0.245,0.475,0.705,1.0]
		for row in range(4):
			for col in range(4):
				var origin := Vector2i(Vector2(columns[col], rows[row]) * atlas.get_size())
				var end := Vector2i(Vector2(columns[col + 1], rows[row + 1]) * atlas.get_size())
				var used := image.get_region(Rect2i(origin, end - origin)).get_used_rect()
				# Ignore detached paint flecks from the neighboring pose's gutter.
				var best_start := 0
				var best_length := 0
				var run_start := -1
				for y in range(origin.y, end.y + 1):
					var count := 0
					if y < end.y:
						for x in range(origin.x, end.x):
							if image.get_pixel(x, y).a > 0.3:
								count += 1
					if count > 3:
						if run_start < 0:
							run_start = y
					elif run_start >= 0:
						if y - run_start > best_length:
							best_start = run_start
							best_length = y - run_start
						run_start = -1
				if best_length > 0:
					used.position.y = best_start - origin.y
					used.size.y = best_length
				frame_rects[Vector2i(col, row)] = Rect2(origin + used.position, used.size)
		atlas_rect_cache[atlas.resource_path] = frame_rects
	sprite = Sprite2D.new()
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.position.y = -1
	add_child(sprite)
	var region: Rect2 = frame_rects[Vector2i(art_kind, 0)]
	sprite.region_rect = region
	if size_profiles.is_empty(): size_profiles = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cats/size_profiles.json"))
	var display_scale := minf(82.0 / region.size.y, 94.0 / region.size.x)
	var profile: Dictionary = size_profiles.get(str(kind),{})
	if not profile.is_empty() and absf(region.size.x-float(profile.width))<1 and absf(region.size.y-float(profile.height))<1:
		# Match occupied silhouette area, preserving breed proportions and paw baseline.
		display_scale = clampf(sqrt(4700.0/float(profile.opaque_pixels)),75.0/region.size.y,minf(84.0/region.size.y,82.0/region.size.x))
	sprite.scale = Vector2.ONE * display_scale
	sprite.position.y = 40.0 - region.size.y * sprite.scale.y / 2.0
	face_material = ShaderMaterial.new()
	face_material.shader = preload("res://scripts/cat_face.gdshader")
	var eyes: Dictionary={0:Vector4(.2942,.3648,.625,.3665),1:Vector4(.2885,.363,.6269,.3701),2:Vector4(.2817,.3714,.6082,.3661),3:Vector4(.2593,.375,.6213,.375),4:Vector4(.2659,.3609,.6236,.3609),5:Vector4(.3487,.3415,.6118,.3606),6:Vector4(.2724,.3987,.6082,.3955),10:Vector4(.299,.3663,.6046,.363),11:Vector4(.2657,.3854,.6236,.3854)}
	face_material.set_shader_parameter("eye_centers",eyes.get(kind,Vector4(.29,.37,.62,.37)))
	var atlas_size := atlas.get_size()
	face_material.set_shader_parameter("base_rect", Vector4(region.position.x / atlas_size.x, region.position.y / atlas_size.y, region.size.x / atlas_size.x, region.size.y / atlas_size.y))
	for i in range(4):
		var part: Rect2 = frame_rects[Vector2i(art_kind, i)]
		face_material.set_shader_parameter(["neutral_rect", "blink_rect", "happy_rect", "grumpy_rect"][i], Vector4(part.position.x / atlas_size.x, part.position.y / atlas_size.y, part.size.x / atlas_size.x, part.size.y / atlas_size.y))
	if kind in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:preload("res://scripts/cat_motion_catalog.gd").configure_face(self)
	sprite.material = face_material
	set_face(0)

func set_stack_count(count: int, reveal_ears: bool = true) -> void:
	stack_target = 1.0 if count>1 else 0.0
	if count>1:
		enable_victory_rig()
		if not is_instance_valid(ear_mesh):
			ear_mesh=MeshInstance2D.new()
			ear_mesh.mesh=victory_mesh.mesh
			ear_mesh.texture=victory_mesh.texture
			ear_material=face_material.duplicate()
			ear_material.set_shader_parameter("ears_only",true)
			ear_mesh.material=ear_material
			ear_mesh.z_index=3
			add_child(ear_mesh)
	if is_instance_valid(ear_mesh):ear_mesh.visible=count>1 and reveal_ears

func set_face(expression: int) -> void:
	face = expression

func animate(age: float, active: bool, squash: float = 0.0, mood: int = 0, gentle: bool = false) -> void:
	enable_victory_rig()
	face_material.set_shader_parameter("menu_ears",Vector2.ZERO)
	var delta := clampf(age - last_age, 0.0, 0.05) if last_age >= 0 else 1.0 / 60.0
	last_age = age
	stack_weight = lerpf(stack_weight,stack_target,1-exp(-delta*18))
	face_material.set_shader_parameter("compact_stack",stack_weight)
	if is_instance_valid(ear_material):ear_material.set_shader_parameter("compact_stack",stack_weight)
	var breath := sin(age * 1.9 + phase)
	var intensity := 0.25 if gentle else 1.0
	scale = Vector2(1.0 - breath * 0.005 * intensity + squash * 0.08, 1.0 + breath * 0.012 * intensity - squash * 0.09)
	rotation = sin(age * 0.75 + phase) * 0.006 * intensity
	var expression := mood
	if mood == 0 and active:
		expression = 2
	if forced_face >= 0:
		expression = forced_face
	set_face(expression)
	var target := Vector4.ZERO
	target[expression] = 1.0
	face_weights = face_weights.lerp(target, 1.0 - exp(-delta * (38.0 if expression == 1 else 17.0)))
	if expression == 0:
		var close := blink_amount(age)
		face_weights = Vector4(1-close,close,0,0)
	face_material.set_shader_parameter("weights", face_weights)
	set_life_motion(age, intensity * (0.32 if stack_target>0 else 0.65), active)
	if is_instance_valid(ear_material):
		ear_material.set_shader_parameter("weights",face_weights)
		ear_material.set_shader_parameter("motion_age",age+phase*2)
		ear_material.set_shader_parameter("idle_motion",intensity*.32)
		ear_material.set_shader_parameter("ear_flick",ear_flick(age)*intensity)

func blink_amount(age: float) -> float:
	# Different rhythms per kitten, with a quick close and slower, soft reopening.
	var period := 3.8+fposmod(phase*1.31,2.7)
	var t := fposmod(age+phase*1.71,period)
	var blink := smoothstep(0.0,.065,t)*(1-smoothstep(.085,.23,t))
	if int(floor((age+phase*1.71)/period))%3==1:
		blink=maxf(blink,smoothstep(.32,.38,t)*(1-smoothstep(.40,.55,t)))
	return blink

func ear_flick(age: float) -> float:
	var t := fposmod(age+phase*2.3,7.1+fposmod(phase,2.0))
	return sin(t*TAU/0.65)*pow(sin(clampf(t/.65,0,1)*PI),2) if t<.65 else 0.0

func set_life_motion(age: float, amount: float, active: bool) -> void:
	face_material.set_shader_parameter("idle_motion",amount)
	face_material.set_shader_parameter("motion_age",age+phase*2)
	face_material.set_shader_parameter("ear_flick",ear_flick(age)*amount)
	# An occasional curious head tilt; never changes the cat's occupied slot.
	var t := fposmod(age+phase*2.1,11.0)
	var curiosity := pow(sin(clampf((t-5)/2.4,0,1)*PI),2) if t>5 and t<7.4 else 0.0
	face_material.set_shader_parameter("head_tilt",(.65 if active else sin(phase+1)*curiosity)*amount)
	if is_instance_valid(ear_material):
		ear_material.set_shader_parameter("head_tilt",(.65 if active else sin(phase+1)*curiosity)*amount)

func animate_menu(age: float, origin: Vector2, display_scale: float, gentle: bool) -> void:
	enable_victory_rig()
	var hello_cycle := fposmod(age+phase*2.1,13.0)
	var smiling := age < greet_until or (hello_cycle>8.2 and hello_cycle<9.4)
	animate(age, false, 0.0, 2 if smiling else 0, gentle)
	face_material.set_shader_parameter("idle_motion",.25 if gentle else 1.0)
	face_material.set_shader_parameter("motion_age",age+phase*2)
	if not smiling:
		var close := blink_amount(age)
		face_weights = Vector4(1-close,close,0,0)
		face_material.set_shader_parameter("weights",face_weights)
	set_life_motion(age,.2 if gentle else 1.0,false)
	if menu_ears_enabled:
		face_material.set_shader_parameter("head_tilt",0.0)
		face_material.set_shader_parameter("ear_flick",0.0)
		face_material.set_shader_parameter("menu_ears",menu_ear_pose(age,gentle))
	var intensity := 0.2 if gentle else 1.0
	var breath := sin(age * 1.65 + phase)
	# Slow continuous breathing, anchored paws and a small, relaxed head/body sway.
	scale = Vector2(display_scale * (1.0 - breath * 0.005 * intensity), display_scale * (1.0 + breath * 0.012 * intensity))
	rotation = sin(age * 0.62 + phase) * 0.008 * intensity
	position = origin + Vector2(sin(age * 0.48 + phase) * 0.7 * intensity, -40.0 * (scale.y - display_scale))

func menu_ear_pose(age: float, gentle: bool) -> Vector2:
	var left:=ear_pulse(fposmod(age+phase*1.9,5.7+phase*.3))
	var right:=ear_pulse(fposmod(age+phase*2.7+2.2,7.4+phase*.2))
	return Vector2(left,right)*(.25 if gentle else 1.0)

func ear_pulse(t: float) -> float:
	return sin(t*TAU/.72)*pow(sin(t/.72*PI),2) if t<.72 else 0.0

func enable_victory_rig() -> void:
	if is_instance_valid(victory_mesh):
		return
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var region: Rect2 = sprite.region_rect
	var view_size := region.size * sprite.scale
	var resolution := Vector2i(18, 22)
	for y in range(resolution.y + 1):
		for x in range(resolution.x + 1):
			var p := Vector2(float(x) / resolution.x, float(y) / resolution.y)
			vertices.append(Vector3((p.x-0.5)*view_size.x, (p.y-0.5)*view_size.y+sprite.position.y, 0))
			uvs.append((region.position+p*region.size)/sprite.texture.get_size())
	for y in range(resolution.y):
		for x in range(resolution.x):
			var a := y*(resolution.x+1)+x
			indices.append_array(PackedInt32Array([a,a+1,a+resolution.x+1,a+1,a+resolution.x+2,a+resolution.x+1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	victory_mesh = MeshInstance2D.new()
	victory_mesh.mesh = mesh
	victory_mesh.texture = sprite.texture
	victory_mesh.material = face_material
	add_child(victory_mesh)
	sprite.hide()

func animate_victory(age: float, gentle: bool) -> void:
	enable_victory_rig()
	animate(age, false, 0, 2, gentle)
	face_material.set_shader_parameter("celebration", 0.20 if gentle else 1.0)
	face_material.set_shader_parameter("motion_age", age)
	var cycle := fmod(maxf(age-0.85, 0.0), 2.6)
	var hop := sin(clampf(cycle/0.70, 0.0, 1.0)*PI)
	var intensity := 0.18 if gentle else 1.0
	scale = Vector2(2.3*(1.0-hop*0.025*intensity),2.3*(1.0+hop*0.025*intensity))
	rotation = sin(age*2.5)*0.025*intensity
	position = Vector2(360, 408-hop*16.0*intensity)

func victory_head_anchor(age: float, gentle: bool) -> Vector2:
	var extent: Vector2=sprite.region_rect.size*sprite.scale
	var anchor: Vector2=(Vector2(.46,.17)-Vector2(.5,.5))*extent+sprite.position
	# Match the head's lateral deformation in cat_face.gdshader as well as parent motion.
	anchor.x+=sin(age*2.5)*1.4*(.2 if gentle else 1.0)
	return anchor

func ensure_pose_motion() -> void:
	if kind not in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS or is_instance_valid(pose_motion):return
	pose_motion=preload("res://scripts/cat_pose_motion.gd").new();add_child(pose_motion);pose_motion.configure(kind)
func animate_sleep(age: float,idle: float,eligible: bool,gentle: bool=false) -> void:
	if kind not in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:return
	ensure_pose_motion();pose_motion.update_sleep(self,age,idle,eligible,gentle)
func animate_air(t: float,airborne: bool) -> void:
	if kind not in preload("res://scripts/cat_breeds.gd").ACTIVE_IDS:return
	ensure_pose_motion();pose_motion.update_air(self,t,airborne)
# Compatibility with saved orange-only preview scenes.
func ensure_orange_pose() -> void:ensure_pose_motion()
func orange_sleep(age: float,idle: float,eligible: bool,gentle: bool=false) -> void:animate_sleep(age,idle,eligible,gentle)
func orange_air(t: float,airborne: bool) -> void:animate_air(t,airborne)
