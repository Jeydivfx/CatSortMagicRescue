extends SceneTree
func _initialize() -> void:call_deferred("run")
func snapshot() -> Image:
	await process_frame;await process_frame;RenderingServer.force_draw()
	return root.get_texture().get_image()
func run() -> void:
	root.size=Vector2i(480,480);root.content_scale_size=Vector2i(480,480)
	var c=preload("res://scripts/cat_actor.gd").new();root.add_child(c);c.setup(null,1,0);c.animate(20,false,0,0,false)
	c.position=Vector2(240,290);c.scale=Vector2.ONE*3;c.rotation=0
	for parameter in ["idle_motion","head_tilt","ear_flick"]:c.face_material.set_shader_parameter(parameter,0)
	c.face_material.set_shader_parameter("weights",Vector4(1,0,0,0))
	var neutral: Image=await snapshot()
	c.face_material.set_shader_parameter("authored_lids",false);c.face_material.set_shader_parameter("original_fur_fill",false)
	var original: Image=await snapshot()
	assert(neutral.get_data()==original.get_data(),"Neutral must render the original portrait exactly, without any donor eyebrows")
	c.face_material.set_shader_parameter("authored_lids",true);c.face_material.set_shader_parameter("original_fur_fill",true)
	for closure in [.25,.5,.75,1.0]:
		c.face_material.set_shader_parameter("weights",Vector4(1-closure,closure,0,0))
		var frame: Image=await snapshot()
		assert(frame.get_data()!=neutral.get_data(),"Blink must actually animate")
		# Compute the top quarter from the actual registered sprite bounds. This
		# includes both original brows, not merely the tips of the ears.
		var view_height: float=c.sprite.region_rect.size.y*c.sprite.scale.y
		var forehead_bottom: int=int(c.position.y+c.scale.y*(c.sprite.position.y-.25*view_height))
		for y in range(forehead_bottom):
			for x in range(480):assert(frame.get_pixel(x,y)==neutral.get_pixel(x,y),"Blink must not repaint forehead or eyebrows")
	# A conspicuous synthetic base catches even faint surviving original ink at
	# the four outer eye corners. Fully closed corners must use clean fur only.
	var source_shader: Shader=c.face_material.shader
	var diagnostic:=Shader.new()
	diagnostic.code=source_shader.code.replace("vec4 base = texture(TEXTURE, UV);","vec4 base = texture(TEXTURE, UV); base.rgb=vec3(1.0,0.0,1.0);")
	var profile=preload("res://scripts/cat_motion_catalog.gd").profile(1)
	var extent: Vector2=c.sprite.region_rect.size*c.sprite.scale
	for expression in [Vector4(0,1,0,0),Vector4(0,0,1,0)]:
		c.face_material.set_shader_parameter("weights",expression)
		c.face_material.shader=source_shader;var clean: Image=await snapshot()
		c.face_material.shader=diagnostic;var probe: Image=await snapshot()
		for eye in range(2):
			for side in [-1,1]:
				var uv:=Vector2(profile.eyes[eye*2]+side*profile.eye_radius[0]*1.4,profile.eyes[eye*2+1])
				var point: Vector2=c.to_global((uv-Vector2(.5,.5))*extent+c.sprite.position)
				var x:=roundi(point.x);var y:=roundi(point.y)
				assert(clean.get_pixel(x,y)==probe.get_pixel(x,y),"Original eye-corner ink must be completely covered in sleep and smile")
	c.free();print("PASS original neutral pixels, four blink stages, fixed brows, all four eye corners fully cleaned during sleep and smile");quit()
