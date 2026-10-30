extends RefCounted
## One coordinate system for content, native ads and shared cat/book anchors.
static func home(g) -> void:
	if not is_instance_valid(g.menu_ui) or not g.menu_ui.has_node("HomeDecoration"):return
	preload("res://scripts/royal_home_layout.gd").apply(g)

static func gameplay(g) -> void:
	if not is_instance_valid(g.game_ui) or not is_instance_valid(g.undo_button):return
	var footer: float=g.footer_y()
	g.hud.position=Vector2(12,g.content_rect().position.y+12)
	for button in [g.undo_button,g.hint_button,g.tube_button]:button.position.y=footer
	var speech=g.game_ui.get_node("WitchSpeech")
	speech.position=Vector2(206,footer-110)
	g.status.position.y=speech.position.y+11
	if not g.entering:g.wizard.position=Vector2(8,g.wizard_home_y())
	var reservation=g.game_ui.get_node_or_null("BannerReservation")
	if reservation:reservation.position.y=g.get_banner_rect().position.y+g.get_banner_rect().size.y*.45
