extends Control
var books: Texture2D = preload("res://assets/branding/menu_books.png")
var book_rect:=Rect2(90,540,540,180)
var journey_rect:=Rect2(130,920,460,104)
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
	# Coin counter and book podium share the same gold/purple material language.
	box(Rect2(30,24,244,68),Color(.035,.055,.15,.91),30,Color("7d80ae"))
	draw_circle(Vector2(67,58),24,Color("a76520"))
	draw_circle(Vector2(67,55),22,Color("ffca49"))
	draw_arc(Vector2(67,55),17,0,TAU,40,Color("ffec9a"),2,true)
	var font := load("res://assets/fonts/game_font.tres") as Font
	draw_string(font,Vector2(59,65),"$",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("fff1ba"))
	draw_texture_rect(books,book_rect,false)
	# Slow fireflies orbit the podium edges; no motion of the kittens' support.
	for i in range(12):
		var t := age*(.12 if gentle else .32)+i*2.399
		var point := Vector2(360+cos(t)* (245+i%3*13),book_rect.position.y-95+sin(t*.83+i)*95)
		var glow := .25+.3*(.5+.5*sin(age*1.3+i*1.7))
		draw_circle(point,7,Color(1,.76,.3,glow*.08))
		draw_circle(point,3,Color(1,.85,.42,glow*.22))
		draw_circle(point,1.25,Color(1,.94,.65,glow))
	box(journey_rect,Color(.04,.06,.17,.91),23,Color("626992"))
	var arrow:=journey_rect.position+Vector2(journey_rect.size.x-22,23)
	draw_polyline(PackedVector2Array([arrow-Vector2(4,6),arrow+Vector2(3,0),arrow+Vector2(-4,6)]),Color("ffe0a0"),2,true)
	box(Rect2(journey_rect.position+Vector2(26,43),Vector2(408,15)),Color("111b35"),8,Color("69769d"))
	if completed>0:
		box(Rect2(journey_rect.position+Vector2(28,45),Vector2(maxf(12,404.0*completed/total),11)),Color("ffd563"),6,Color("ffeaa2"))
