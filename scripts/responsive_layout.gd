extends RefCounted
## One coordinate system for content, native ads and shared cat/book anchors.
static func home(g) -> void:
	if not is_instance_valid(g.menu_ui) or not g.menu_ui.has_node("HomeDecoration"):return
	var safe: Rect2=g.content_rect()
	var s: float=minf(1.03,minf(safe.size.y/1050.0,(minf(720,safe.size.x)-24)/680.0))
	var offset:=Vector2(360-360*s,safe.position.y)
	g.menu_ui.position=offset
	g.menu_ui.set_meta("l10n_x",offset.x)
	g.menu_ui.scale=Vector2.ONE*s
	g.menu_cats.position=offset
	g.menu_cats.scale=Vector2.ONE*s
	var extra: float=maxf(0,safe.size.y/s-1050)
	var book_y:=540+extra*.42
	var decor=g.menu_ui.get_node("HomeDecoration")
	decor.book_rect=Rect2(90,book_y,540,180)
	decor.journey_rect=Rect2(130,920+extra,460,104)
	if g.menu_ui.has_node("HomeRescueLink"):
		var link=g.menu_ui.get_node("HomeRescueLink")
		link.position=decor.journey_rect.position;link.size=decor.journey_rect.size;link.set_meta("l10n_x",link.position.x)
	decor.queue_redraw()
	var positions: Dictionary={"HomeCoins":Vector2(102,37),"HomeSettings":Vector2(604,24),"HomeLogo":Vector2(62,118+extra*.08),"HomePlay":Vector2(114,650+extra*.42),"HomeLevels":Vector2(124,802+extra*.42),"HomeJourneyTitle":Vector2(155,930+extra),"HomeJourneyCount":Vector2(150,990+extra)}
	for key in positions:
		var item=g.menu_ui.get_node(key)
		item.position=positions[key]
		item.set_meta("l10n_x",item.position.x)
	g.menu_ui.get_node("HomeLogo").size=Vector2(596,220)
	g.menu_ui.get_node("HomePlay").size=Vector2(492,136)
	g.menu_ui.get_node("HomeLevels").size=Vector2(472,88)
	# Contact offsets measured at each kitten's x-position on the painted book surface.
	var feet:=book_y+24
	for actor in g.menu_cats.get_children():
		var origin: Vector2=actor.get_meta("menu_base_origin")
		var cat_scale: float=actor.get_meta("menu_scale")
		origin.y=feet-40*cat_scale
		actor.set_meta("menu_origin",origin)
		actor.animate_menu(g.clock,origin,cat_scale,g.reduced_motion)

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
