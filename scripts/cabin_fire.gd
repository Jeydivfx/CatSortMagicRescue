extends RefCounted
# Source-UV anchored fire and warm light, drawn between the background and gameplay.
static func crop_rect(texture: Texture2D,target: Rect2) -> Rect2:
	var scale: float=maxf(target.size.x/texture.get_width(),target.size.y/texture.get_height())
	var size: Vector2=target.size/scale
	return Rect2(Vector2((texture.get_width()-size.x)*.15,(texture.get_height()-size.y)*.5),size)
static func image_point(texture: Texture2D,target: Rect2,uv: Vector2) -> Vector2:
	var crop:=crop_rect(texture,target)
	return target.position+(uv*texture.get_size()-crop.position)*target.size/crop.size
static func ellipse(g,point: Vector2,radius: Vector2,color: Color) -> void:
	g.draw_set_transform(point,0,radius);g.draw_circle(Vector2.ZERO,1,color);g.draw_set_transform(Vector2.ZERO)
static func flame_shape(base: Vector2,width: float,height: float,sway: float) -> PackedVector2Array:
	var result:=PackedVector2Array();var tip:=base+Vector2(sway,-height)
	var left:=base+Vector2(-width*.5,0);var right:=base+Vector2(width*.5,0)
	for i in range(13):result.append(left.bezier_interpolate(base+Vector2(-width*.65,-height*.30),tip+Vector2(-width*.18,height*.24),tip,i/12.0))
	for i in range(1,13):result.append(tip.bezier_interpolate(tip+Vector2(width*.3,height*.32),base+Vector2(width*.7,-height*.12),right,i/12.0))
	return result
static func draw(g,texture: Texture2D,target: Rect2,time: float,gentle: bool,alpha: float=1.0) -> void:
	if alpha<.001:return
	var pixel_scale: float=target.size.x/crop_rect(texture,target).size.x
	var hearth:=image_point(texture,target,Vector2(.075,.475))
	var flicker:=.84+.09*sin(time*2.7)+.05*sin(time*4.13+.8)+.02*sin(time*6.3)
	for layer in range(12,0,-1):
		var f:=layer/12.0
		ellipse(g,hearth,Vector2(155,118)*pixel_scale*f,Color(1,.46,.10,(1-f*.7)*.016*flicker*alpha))
	var floor_point:=image_point(texture,target,Vector2(.13,.51))
	for layer in range(8,0,-1):
		var f:=layer/8.0
		ellipse(g,floor_point,Vector2(240,32)*pixel_scale*f,Color(1,.55,.17,.012*flicker*alpha))
	for i in range(6):
		var phase:=time*(1.5+i*.13)+i*1.7
		var base:=image_point(texture,target,Vector2(.012+i*.016,.473-i%2*.007))
		var height: float=(44+13*sin(phase)+8*sin(phase*.71+1))*pixel_scale
		var sway: float=sin(phase*.8)*8*pixel_scale*(.25 if gentle else 1.0)
		var width: float=(15+i%3*3)*pixel_scale
		g.draw_colored_polygon(flame_shape(base,width,height,sway),Color(1,.39,.04,.22*alpha))
		g.draw_colored_polygon(flame_shape(base,width*.58,height*.76,sway*.72),Color(1,.77,.23,.27*alpha))
		g.draw_colored_polygon(flame_shape(base,width*.22,height*.44,sway*.40),Color(1,.95,.64,.32*alpha))
	if not gentle:
		for i in range(4):
			var age:=fposmod(time*.24+i*.257,1.0)
			var uv:=Vector2(.025+i*.019+sin(age*4+i)*.006,.468-age*.078)
			var p:=image_point(texture,target,uv)
			g.draw_circle(p,(1.2-age*.6)*pixel_scale,Color(1,.72,.30,sin(PI*age)*.50*alpha))
