extends SceneTree
const INK=Color("34253f")
const CELL=Vector2i(512,512)
var mode:=""
func _initialize() -> void:call_deferred("run")
func poly(n: Node2D,points: Array,color: Color) -> void:
	var p:=PackedVector2Array(points);n.draw_colored_polygon(p,color);p.append(p[0]);n.draw_polyline(p,INK,2,true)
func oval(n: Node2D,p: Vector2,r: Vector2,color: Color) -> void:
	n.draw_set_transform(p,0,r);n.draw_circle(Vector2.ZERO,1,color);n.draw_set_transform(Vector2.ZERO)
func paint(n: Node2D) -> void:
	match mode:
		"head":
			for side in [-1,1]:
				oval(n,Vector2(side*25,0),Vector2(13,29),Color("bfc0d6"));oval(n,Vector2(side*30,12),Vector2(10,13),Color("e0d9ed"))
			oval(n,Vector2(0,-3),Vector2(28,30),INK);oval(n,Vector2(0,-4),Vector2(26,28),Color("efb995"));oval(n,Vector2(-4,-10),Vector2(22,21),Color("f9d0ac"))
		"hat":
			poly(n,[Vector2(-26,-26),Vector2(-16,-63),Vector2(0,-77),Vector2(23,-65),Vector2(11,-59),Vector2(24,-26)],Color("633984"))
			poly(n,[Vector2(-17,-59),Vector2(0,-72),Vector2(12,-65),Vector2(-2,-60),Vector2(-8,-28),Vector2(-21,-28)],Color("8f5ab0"))
			poly(n,[Vector2(-24,-36),Vector2(22,-36),Vector2(24,-26),Vector2(-26,-26)],Color("7fb06a"))
			oval(n,Vector2(0,-25),Vector2(43,9),INK);oval(n,Vector2(0,-27),Vector2(42,8),Color("73448f"))
			poly(n,[Vector2(4,-39),Vector2(11,-32),Vector2(4,-25),Vector2(-3,-32)],Color("f4ce75"))
		"body":
			poly(n,[Vector2(-20,-22),Vector2(20,-22),Vector2(40,51),Vector2(0,56),Vector2(-40,51)],Color("693c87"))
			poly(n,[Vector2(-14,-18),Vector2(5,-18),Vector2(22,49),Vector2(-14,52)],Color("8454a3"))
			poly(n,[Vector2(-23,-20),Vector2(0,-8),Vector2(23,-20),Vector2(14,-2),Vector2(-14,-2)],Color("82ba78"))
			n.draw_line(Vector2(-25,13),Vector2(25,13),INK,9,true)
			poly(n,[Vector2(0,4),Vector2(9,13),Vector2(0,22),Vector2(-9,13)],Color("f7cd6e"));oval(n,Vector2(0,13),Vector2(4,5),Color("51bc9e"))
			for x in [-22,18]:n.draw_line(Vector2(x,29),Vector2(x*1.5,47),Color("a47fbb"),1.5,true)
		"upper_left","upper_right":
			poly(n,[Vector2(-7,-24),Vector2(7,-24),Vector2(9,24),Vector2(-9,24)],Color("734792"))
			n.draw_line(Vector2(-4,-20),Vector2(-5,20),Color("9862b0"),2,true)
		"fore_left","fore_right":
			poly(n,[Vector2(-8,-30),Vector2(8,-30),Vector2(8,14),Vector2(-8,14)],Color("734792"))
			poly(n,[Vector2(-9,9),Vector2(9,9),Vector2(9,15),Vector2(-9,15)],Color("b6dbb1"))
			oval(n,Vector2(0,21),Vector2(9,9),INK);oval(n,Vector2(0,20),Vector2(7,7),Color("f4c1a3"))
			for x in [-3,0,3]:n.draw_line(Vector2(x,18),Vector2(x,23),Color("d0937e"),.6,true)
		"staff":
			n.draw_line(Vector2(0,44),Vector2(0,-39),INK,6,true);n.draw_line(Vector2(0,44),Vector2(0,-39),Color("ba895a"),3,true)
			oval(n,Vector2(0,-40),Vector2(6,8),Color("8de4bd"));oval(n,Vector2(-1,-42),Vector2(2,3),Color("d7fff0"))
		"shoe_left","shoe_right":
			oval(n,Vector2.ZERO,Vector2(18,7),INK);oval(n,Vector2(0,-2),Vector2(16,5),Color("59406e"))
		"point_hand":
			oval(n,Vector2.ZERO,Vector2(8,7),Color("f4c1a3"));n.draw_line(Vector2(0,0),Vector2(0,-13),Color("f4c1a3"),5,true)
		"broom":
			n.draw_line(Vector2(-42,0),Vector2(48,0),INK,7,true);n.draw_line(Vector2(-42,0),Vector2(48,0),Color("ba895a"),4,true)
			poly(n,[Vector2(-28,-3),Vector2(-50,-16),Vector2(-65,-16),Vector2(-55,-5),Vector2(-67,0),Vector2(-55,5),Vector2(-63,14),Vector2(-46,14),Vector2(-28,3)],Color("d5a74b"))
			for y in [-9,-3,4,10]:n.draw_line(Vector2(-57,y),Vector2(-31,0),Color("ae7737"),1,true)
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/witch_classic")
	var viewport:=SubViewport.new();viewport.size=CELL;viewport.transparent_bg=true;viewport.msaa_2d=Viewport.MSAA_4X;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
	var canvas:=Node2D.new();canvas.position=Vector2(256,256);canvas.scale=Vector2.ONE*3;viewport.add_child(canvas);canvas.draw.connect(paint.bind(canvas))
	var sheet:=Image.create(CELL.x*4,CELL.y*3,false,Image.FORMAT_RGBA8);var parts:={}
	var names: Array=["head","hat","body","upper_left","fore_left","upper_right","fore_right","staff","shoe_left","shoe_right","point_hand","broom"]
	for i in range(names.size()):
		mode=names[i];canvas.queue_redraw();await process_frame;RenderingServer.force_draw()
		var im:=viewport.get_texture().get_image();var used:=im.get_used_rect();var offset:=Vector2i((i%4)*512,(i/4)*512)
		sheet.blit_rect(im,Rect2i(Vector2i.ZERO,CELL),offset)
		parts[mode]={"rect":[used.position.x+offset.x,used.position.y+offset.y,used.size.x,used.size.y]}
		if mode=="head":
			var skin:=Rect2(Vector2(256,256)+Vector2(-26,-32)*3,Vector2(52,56)*3)
			parts[mode].face=[(skin.position.x-used.position.x)/used.size.x,(skin.position.y-used.position.y)/used.size.y,skin.size.x/used.size.x,skin.size.y/used.size.y]
	assert(sheet.save_png("res://assets/witch_classic/parts.png")==OK)
	var file:=FileAccess.open("res://assets/witch_classic/parts.json",FileAccess.WRITE);file.store_string(JSON.stringify({"parts":parts},"\t"));file.close()
	viewport.free();await process_frame;print("Built old witch artwork from original vector paths; 12 fixed parts");quit()
