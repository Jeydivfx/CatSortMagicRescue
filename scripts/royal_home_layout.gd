extends RefCounted
const SEAT_UV=Vector2(.5,.588)
static func background_rect(g)->Rect2:
	# Keep the editor's 720 x 1120 framing on every phone. Cover based on
	# the live aspect ratio revealed extra sky on tall Android screens.
	var full=Rect2(-g.position,g.get_viewport_rect().size)
	var safe:Rect2=g.content_rect()
	var texture_size:Vector2=g.home_backdrop.get_size()
	var factor=maxf(720.0/texture_size.x,1120.0/texture_size.y)
	var reference_extent=texture_size*factor
	var reference_y=clampf(1000.0*.588-reference_extent.y*SEAT_UV.y,1120.0-reference_extent.y,0.0)
	var reference_feet=reference_y+reference_extent.y*SEAT_UV.y
	var vertical_scale=maxf(safe.size.y/1000.0,maxf(full.size.x/reference_extent.x,full.size.y/reference_extent.y))
	var extent=reference_extent*vertical_scale
	var origin=Vector2(full.get_center().x-extent.x*.5,safe.position.y+safe.size.y*reference_feet/1000.0-extent.y*SEAT_UV.y)
	# The art may extend behind the ad, but content remains above it.
	origin.y=clampf(origin.y,full.end.y-extent.y,full.position.y)
	return Rect2(origin,extent)
static func apply(g)->void:
	var safe:Rect2=g.content_rect();var scene=background_rect(g);g.menu_ui.scale=Vector2.ONE;g.menu_ui.position=Vector2.ZERO;g.menu_ui.set_meta("l10n_x",0);g.menu_cats.scale=Vector2.ONE;g.menu_cats.position=Vector2.ZERO
	var visual_scale=minf(minf(scene.size.x/720.0,safe.size.x/650.0),safe.size.y/1100.0)
	var feet=scene.position.y+scene.size.y*SEAT_UV.y
	for i in range(g.menu_cats.get_child_count()):
		var actor=g.menu_cats.get_child(i);var cat_scale=(2.15 if i==1 else 1.75)*visual_scale
		var x=scene.get_center().x+(i-1)*safe.size.x*.16;var origin=Vector2(x,feet-40*cat_scale);actor.set_meta("menu_scale",cat_scale);actor.set_meta("menu_origin",origin);actor.set_meta("menu_base_origin",origin);actor.animate_menu(g.clock,origin,cat_scale,g.reduced_motion)
	var logo=g.menu_ui.get_node("HomeLogo");logo.size=Vector2(minf(560,safe.size.x*.76),safe.size.y*.22);logo.position=Vector2(safe.get_center().x-logo.size.x*.5,safe.position.y+safe.size.y*.165);logo.set_meta("l10n_x",logo.position.x)
	var card_side=minf(200,minf((safe.size.x-64)/3.0-8,safe.size.y*.155));var card_height=card_side*124.0/135.0;var row_width=card_side*3+24;var nav_y=safe.position.y+safe.size.y*.90-card_height*.5
	for i in range(3):
		var b=g.menu_ui.get_node(["HomeLevels","HomeGlobalRankings","HomeSanctuary"][i]);b.size=Vector2(card_side,card_height);b.position=Vector2(safe.get_center().x-row_width*.5+i*(card_side+12),nav_y);b.set_meta("l10n_x",b.position.x)
	var seat_bottom=scene.position.y+scene.size.y*.633
	var play=g.menu_ui.get_node("HomePlay");play.size=Vector2(minf(430,safe.size.x*.59),minf(130,safe.size.y*.118));play.position=Vector2(safe.get_center().x-play.size.x*.5,(seat_bottom+nav_y-play.size.y)*.5);play.set_meta("l10n_x",play.position.x)
	var settings=g.menu_ui.get_node("HomeSettings");settings.size=Vector2(64,64);settings.position=Vector2(safe.position.x+18,safe.position.y+16);settings.set_meta("l10n_x",settings.position.x)
	var counters=g.menu_ui.get_node("HomeCounters");counters.position=Vector2(safe.end.x-364,safe.position.y+22);counters.set_meta("l10n_x",counters.position.x)
	var decor=g.menu_ui.get_node("HomeDecoration");decor.book_rect=Rect2(scene.get_center().x-240,feet,480,80);decor.queue_redraw()
	for name in ["HomeCoins","HomeScore","HomeJourneyTitle","HomeJourneyCount","HomeRescueLink"]:
		if g.menu_ui.has_node(name):g.menu_ui.get_node(name).hide()
