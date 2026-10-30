extends Control
var books: Texture2D = preload("res://assets/branding/menu_books.png")
var velvet_perch: Texture2D
var book_rect:=Rect2(90,540,540,180)
var journey_rect:=Rect2(130,920,460,104)
var header_offset:=Vector2.ZERO
var header_scale:=1.0
var coins := 0
var completed := 0
var total := 1000
var age := 0.0
var gentle := false
func _process(delta: float) -> void:
	age+=delta
	queue_redraw()
func _ready() -> void: mouse_filter=Control.MOUSE_FILTER_IGNORE
func box(rect: Rect2, color: Color, radius: int, edge: Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color=color; s.border_color=edge
	s.set_corner_radius_all(radius); s.set_border_width_all(2)
	draw_style_box(s,rect)
func _draw() -> void:
	# The cushion is painted into the scene; only subtle live contact shadows
	# and fireflies are rendered here, never a separate perch texture.
	for i in range(3):
		for layer in range(8,0,-1):
			draw_set_transform(Vector2(book_rect.get_center().x+(i-1)*115,book_rect.position.y+2),0,Vector2(1,.12));draw_circle(Vector2.ZERO,layer*5.5,Color(.03,.007,.018,.026));draw_set_transform(Vector2.ZERO)
	for i in range(9):
		var t=age*.18+i*2.399;var point=Vector2(book_rect.get_center().x+cos(t)*240,book_rect.position.y-90+sin(t*.83+i)*85)
		draw_circle(point,3,Color(1,.8,.4,.035));draw_circle(point,1,Color(1,.91,.62,.20+.12*sin(age+i)))
