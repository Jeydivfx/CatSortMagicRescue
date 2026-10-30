extends RefCounted
const ACTIVE=preload("res://scripts/cat_breeds.gd").ACTIVE_IDS
static var profiles: Dictionary={}
static func profile(kind: int) -> Dictionary:
	if profiles.is_empty():profiles=JSON.parse_string(FileAccess.get_file_as_string("res://assets/cats/motion_profiles.json"))
	return profiles.get(str(kind),{})
static func vec2(a: Array) -> Vector2:return Vector2(a[0],a[1])
static func vec3(a: Array) -> Vector3:return Vector3(a[0],a[1],a[2])
static func vec4(a: Array) -> Vector4:return Vector4(a[0],a[1],a[2],a[3])
static func configure_face(actor) -> void:
	var m: ShaderMaterial=actor.face_material
	m.set_shader_parameter("authored_lids",true)
	m.set_shader_parameter("original_fur_fill",actor.kind==1)
	if actor.kind==0:
		m.set_shader_parameter("eye_centers",Vector4(.3005,.3732,.6166,.3769))
		m.set_shader_parameter("lids_texture",load("res://assets/cats/orange_pose_trial/sleep.png"))
		return
	var p:=profile(actor.kind)
	m.set_shader_parameter("eye_centers",vec4(p.eyes))
	# Cleanup coverage is independent of the fitted moving-eye aperture.
	# Silver's original eyeliner extends farther sideways than its iris.
	m.set_shader_parameter("eye_radius",vec2(p.eye_radius)*(1.8 if actor.kind==1 else 1.15))
	m.set_shader_parameter("eye_aperture_radius",vec2(p.eye_radius))
	m.set_shader_parameter("lids_texture",load(p.lids_texture))
	m.set_shader_parameter("lids_centers",vec4(p.lids_centers))
	m.set_shader_parameter("lids_sample_radius",vec2(p.lids_radius))
	m.set_shader_parameter("lash_left",vec3(p.lash_left))
	m.set_shader_parameter("lash_right",vec3(p.lash_right))
	m.set_shader_parameter("mouth_target",vec2(p.mouth_target))
	m.set_shader_parameter("mouth_source",vec2(p.mouth_source))
	m.set_shader_parameter("mouth_map_scale",vec2(p.mouth_scale))
	m.set_shader_parameter("mouth_mask_center",vec2(p.mouth_mask_center))
	m.set_shader_parameter("mouth_mask_radius",vec2(p.mouth_mask_radius))
	if actor.kind==1:configure_silver_underlay(actor,p)

static func configure_silver_underlay(actor,p: Dictionary) -> void:
	var texture=load(p.lids_texture) as Texture2D
	var target_mid: Vector2=(Vector2(p.eyes[0],p.eyes[1])+Vector2(p.eyes[2],p.eyes[3]))*.5
	var source_mid: Vector2=(Vector2(p.lids_centers[0],p.lids_centers[1])+Vector2(p.lids_centers[2],p.lids_centers[3]))*.5
	var ratio: float=(float(p.lids_centers[2])-float(p.lids_centers[0]))/(float(p.eyes[2])-float(p.eyes[0]))
	var region: Rect2=actor.sprite.region_rect
	var vertical: float=ratio*texture.get_width()/region.size.x*region.size.y/texture.get_height()
	var mapping:=Vector2(ratio,vertical)
	actor.face_material.set_shader_parameter("silver_face_scale",mapping)
	actor.face_material.set_shader_parameter("silver_face_origin",source_mid-target_mid*mapping)
