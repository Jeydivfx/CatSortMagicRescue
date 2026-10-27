extends SceneTree
const OUT="res://store_assets/"
const FONT=preload("res://assets/fonts/Montserrat-Bold.ttf")
var views: Array=[]
func _initialize() -> void:call_deferred("run")
func texture(file: String) -> ImageTexture:
	return ImageTexture.create_from_image(Image.load_from_file(file))
func rect(parent: Node,p: Vector2,extent: Vector2,color: Color) -> ColorRect:
	var item:=ColorRect.new();item.position=p;item.size=extent;item.color=color;parent.add_child(item);return item
func picture(parent: Node,tex: Texture2D,area: Rect2,cover: bool = false) -> TextureRect:
	var t:=TextureRect.new()
	t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_SCALE
	t.texture=tex;t.position=area.position;t.size=area.size
	parent.add_child(t)
	assert(t.size.is_equal_approx(area.size),"Store image must fit the intended frame")
	return t
func view(extent: Vector2i) -> SubViewport:
	var v:=SubViewport.new();v.size=extent;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(v);views.append(v);return v
func words(canvas: Node2D,value: String,baseline: float,fs: int,color: Color,width: float=1080) -> void:
	while fs>32 and FONT.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>width-110:fs-=1
	var w:=FONT.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
	canvas.draw_string_outline(FONT,Vector2((width-w)*.5,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,9,Color(.025,.04,.12,.8))
	canvas.draw_string(FONT,Vector2((width-w)*.5,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,color)
func header(canvas: Node2D,title: String,second: String,accent: Color) -> void:
	words(canvas,"CAT SORT: MAGIC RESCUE",67,25,Color("c8d7f7"))
	words(canvas,title,167,72,Color("fffaf1"))
	words(canvas,second,263,72,accent)
	canvas.draw_line(Vector2(476,303),Vector2(604,303),Color(accent,.6),3,true)
func rounded_style(color: Color,border: Color,radius: int) -> StyleBoxFlat:
	var s:=StyleBoxFlat.new();s.bg_color=color;s.border_color=border;s.set_border_width_all(3);s.set_corner_radius_all(radius)
	s.shadow_color=Color(.01,.015,.045,.5);s.shadow_size=18;s.shadow_offset=Vector2(0,10);return s
func poster(index: int,file: String,world: String,title: String,second: String,accent: Color) -> void:
	var v:=view(Vector2i(1080,1920))
	var bg:=picture(v,load(world),Rect2(0,0,1080,1920),true)
	var shader:=Shader.new()
	shader.code="shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV)*2.0;for(int i=0;i<8;i++){float a=float(i)*.785398;c+=texture(TEXTURE,UV+vec2(cos(a),sin(a))*.014);} c/=10.0; COLOR=vec4(c.rgb*vec3(.30,.35,.55),1.0);}"
	var material:=ShaderMaterial.new();material.shader=shader;bg.material=material
	var canvas:=Node2D.new();v.add_child(canvas)
	var raw:=texture(OUT+"raw/"+file+".png")
	var card:=Rect2(78,344,924,1512)
	canvas.draw.connect(func():
		header(canvas,title,second,accent)
		canvas.draw_style_box(rounded_style(Color("182441"),Color(accent,.6),34),card.grow(5))
		for i in range(12):
			var x:=25.0 if i%2==0 else 1055.0
			canvas.draw_circle(Vector2(x,420+i*113),1.6,Color(accent,.35)))
	var image:=picture(v,raw,card)
	var mask:=Shader.new()
	mask.code="shader_type canvas_item; uniform vec2 extent;void fragment(){vec2 q=abs(UV*extent-extent*.5)-(extent*.5-vec2(28.));float d=length(max(q,vec2(0.)))+min(max(q.x,q.y),0.)-28.;vec4 c=texture(TEXTURE,UV);c.a*=1.-smoothstep(-1.,1.,d);COLOR=c;}"
	var mat:=ShaderMaterial.new();mat.shader=mask;mat.set_shader_parameter("extent",card.size);image.material=mat
	await create_timer(.08).timeout;RenderingServer.force_draw()
	var result:=v.get_texture().get_image();result.convert(Image.FORMAT_RGB8)
	result.save_png(OUT+"en-US/%02d_%s.png"%[index,file.trim_prefix("%02d_"%index)])
	print("Rendered screenshot ",index)
	v.queue_free();views.erase(v)
func cover() -> void:
	var v:=view(Vector2i(1024,500))
	picture(v,texture(OUT+"source/feature_background.png"),Rect2(0,0,1024,500),true)
	var logo:=load("res://assets/branding/magic_rescue_logo.png")
	var mark:=picture(v,logo,Rect2(52,92,460,190));mark.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var caption:=Node2D.new();v.add_child(caption)
	caption.draw.connect(func():
		var lines: Array=["Sort kittens.","Break the spell."]
		for i in range(2):
			caption.draw_string_outline(FONT,Vector2(84,327+i*39),lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,31,5,Color("102044"))
			caption.draw_string(FONT,Vector2(84,327+i*39),lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,31,Color("fff1c8")))
	await create_timer(.08).timeout;RenderingServer.force_draw()
	var result:=v.get_texture().get_image();result.convert(Image.FORMAT_RGB8);result.save_png(OUT+"en-US/05_feature_graphic.png");print("Rendered feature graphic")
	v.queue_free();views.erase(v)
func contact() -> void:
	var sheet:=Image.create(1280,1194,false,Image.FORMAT_RGB8)
	var cover_image:=Image.load_from_file(OUT+"en-US/05_feature_graphic.png");cover_image.resize(1280,625,Image.INTERPOLATE_LANCZOS);sheet.blit_rect(cover_image,Rect2i(0,0,1280,625),Vector2i.ZERO)
	var names: Array=["01_match_four","02_witch","03_kittens","04_rescue"]
	for i in range(4):
		var shot:=Image.load_from_file(OUT+"en-US/"+names[i]+".png");shot.resize(320,569,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(shot,Rect2i(0,0,320,569),Vector2i(i*320,625))
	sheet.save_png(OUT+"preview_contact.png")
func run() -> void:
	root.size=Vector2i(540,840)
	await poster(1,"01_match_four","res://assets/environments/laboratory.png","MATCH FOUR.","BREAK THE SPELL.",Color("ffdc83"))
	await poster(2,"02_witch","res://assets/environments/cave.png","OUTSMART","THE WITCH.",Color("e1b5ff"))
	await poster(3,"03_kittens","res://assets/environments/garden.png","1,000 LEVELS.","SO MANY KITTENS.",Color("a6efcd"))
	await poster(4,"04_rescue","res://assets/environments/laboratory.png","RESCUE THEM.","SEE THEM SMILE.",Color("ffdc83"))
	if FileAccess.file_exists(OUT+"source/feature_background.png"):
		await cover();contact()
	print("PASS composed RGB store screenshots at 1080x1920; feature graphic at 1024x500 if artwork is ready")
	quit()
