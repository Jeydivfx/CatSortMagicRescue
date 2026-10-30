extends Button
const L=preload("res://scripts/localization.gd")
var kind:="card"
var card_index:=0
var caption:=""
var level_caption:=""
var title_label:Label
var level_label:Label
var art:Texture2D
var glyph:TextureRect
func _ready()->void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR;mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","focus"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	if kind=="card":
		var atlas=preload("res://assets/branding/menu_navigation_reference_v2.png");var tile=AtlasTexture.new();tile.atlas=atlas;tile.region=[Rect2(16,35,135,124),Rect2(164,35,136,124),Rect2(314,35,135,124)][card_index];art=tile
	else:
		glyph=TextureRect.new();glyph.texture=preload("res://assets/icons/settings.png") if kind=="settings" else preload("res://assets/icons/pets.png");glyph.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;glyph.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;glyph.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var tint=ShaderMaterial.new();tint.shader=preload("res://scripts/home_icon_tint.gdshader");tint.set_shader_parameter("ink",Color("f3dfbc") if kind=="settings" else Color("fff5d7"));glyph.material=tint;add_child(glyph)
	title_label=make_label(caption);level_label=make_label(level_caption);resized.connect(arrange);arrange();arrange.call_deferred()
func make_label(value:String)->Label:
	var label=Label.new();L.style(label);label.text=L.t(value);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.add_theme_color_override("font_color",Color("fff8e9"));label.add_theme_color_override("font_shadow_color",Color("071624"));label.add_theme_constant_override("shadow_offset_y",2);label.add_theme_constant_override("shadow_offset_x",1);add_child(label);return label
func arrange()->void:
	if not is_instance_valid(title_label):return
	if kind=="settings":
		title_label.hide();level_label.hide();glyph.size=size*.58;glyph.position=size*.21;glyph.set_meta("l10n_x",glyph.position.x);return
	if kind=="card":
		title_label.visible=L.locale!="en"
		fit_label(title_label,Rect2(size.x*.13,size.y*.70,size.x*.74,size.y*.18),int(size.y*.145))
	else:
		fit_label(title_label,Rect2(size.x*.25,size.y*.025,size.x*.50,size.y*.59),int(size.y*.47))
		fit_label(level_label,Rect2(size.x*.25,size.y*.64,size.x*.50,size.y*.27),int(size.y*.21))
		glyph.size=Vector2.ONE*size.y*.46;glyph.position=Vector2(size.x*.15-glyph.size.x*.5,(size.y-glyph.size.y)*.5);glyph.set_meta("l10n_x",glyph.position.x)
	level_label.visible=kind=="play";queue_redraw()
func fit_label(label:Label,rect:Rect2,font_size:int)->void:
	var font=label.get_theme_font("font")
	while font_size>10 and (font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x-6 or font.get_height(font_size)>rect.size.y-2):font_size-=1
	# Set the font before the rectangle: otherwise Label's previous minimum
	# height clamps the new rectangle and pushes the caption outside its slot.
	label.add_theme_font_size_override("font_size",font_size);label.size=rect.size;label.position=rect.position;label.set_meta("l10n_x",rect.position.x)
func skin(rect:Rect2,color:Color,radius:int,border:Color,width:int=2)->void:
	var s=StyleBoxFlat.new();s.bg_color=color;s.border_color=border;s.set_border_width_all(width);s.set_corner_radius_all(radius);draw_style_box(s,rect)
func _draw()->void:
	if kind=="card":
		if art:
			var radius=minf(size.x,size.y)*.18
			for row in range(int(size.y)):
				var y=float(row)+.5;var dy=maxf(radius-y,y-(size.y-radius));var inset=radius-sqrt(maxf(0,radius*radius-dy*dy)) if dy>0 else 0.0
				draw_texture_rect_region(art,Rect2(inset,row,size.x-inset*2,1.1),Rect2(inset/size.x*art.get_width(),y/size.y*art.get_height(),(1-inset*2/size.x)*art.get_width(),art.get_height()/size.y),Color(.9,.9,.9) if is_pressed() else Color.WHITE)
		if L.locale!="en":skin(Rect2(size.x*.115,size.y*.683,size.x*.77,size.y*.222),[Color("193553"),Color("452459"),Color("07534f")][card_index],int(size.y*.11),Color.TRANSPARENT,0)
		if has_focus():skin(Rect2(Vector2(4,4),size-Vector2(8,8)),Color.TRANSPARENT,int(size.x*.18),Color("ffe4a0"),3)
		return
	var r=Rect2(Vector2(2,2),size-Vector2(4,6));var radius=int(size.y*.47) if kind=="play" else 17
	skin(Rect2(0,5,size.x,size.y-5),Color("07131c"),radius+2,Color("27374b"))
	skin(r,Color("295d37") if kind=="play" else Color("1c3553"),radius,Color("d6bd88"),3)
	var inner=r.grow(-6);var rad=minf(radius-5,inner.size.y*.5)
	for row in range(int(inner.size.y)):
		var y=float(row);var t=y/inner.size.y;var inset=rad-sqrt(maxf(0,rad*rad-pow(rad-y,2))) if y<rad else (rad-sqrt(maxf(0,rad*rad-pow(y-inner.size.y+rad,2))) if y>inner.size.y-rad else 0.0)
		var c=Color("7cdb69").lerp(Color("087d3b"),t) if kind=="play" else Color("304e70").lerp(Color("12263d"),t)
		if kind=="play" and t<.38:c=c.lightened(.08*(1.0-t/.38))
		if is_pressed():c=c.darkened(.12)
		elif is_hovered():c=c.lightened(.07)
		draw_line(inner.position+Vector2(inset,y),inner.position+Vector2(inner.size.x-inset,y),c,1.3)
	skin(inner,Color.TRANSPARENT,int(rad),Color("cff8b4") if kind=="play" else Color("58758b"),1)
	if kind=="settings":
		return
	var shine=PackedVector2Array()
	for i in range(33):
		var t=float(i)/32;shine.append(Vector2(size.y*.35+t*(size.x-size.y*.7),size.y*.13-sin(t*PI)*size.y*.045))
	draw_polyline(shine,Color(.91,1,.80,.65),2,true)
	if has_focus():skin(r,Color.TRANSPARENT,radius,Color("fff2bb"),3)
