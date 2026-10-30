extends RefCounted
const L=preload("res://scripts/localization.gd")
const Design=preload("res://scripts/settings_menu.gd")
static func build(g)->void:
	var p=Design.plate(g,Rect2(60,100,600,870),"0b1b33","8ba4d1",32);p.name="RankingsPanel"
	var back=g.button_at("",Rect2(80,118,60,60),func():g.show_menu(),Color("7951b1"));back.symbol="back";back.compact=true
	var crown=TextureRect.new();crown.texture=preload("res://scripts/ranking_badges.gd").texture(0);crown.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;crown.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;crown.size=Vector2(110,95);crown.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.ui.add_child(crown);crown.position=Vector2(305,113)
	Design.label(g,"Global Rankings",Rect2(95,204,530,54),37,"fff2cb",true)
	Design.label(g,"Top 50 magic cat rescuers",Rect2(95,256,530,34),21,"a8c6ee",true)
	Design.plate(g,Rect2(202,298,316,44),"142f50","294b72",22)
	var own=Design.label(g,"",Rect2(207,298,306,44),21,"fff0c0",true);own.name="PersonalScore";own.text=L.t("Your score")+": "+L.digits(str(g.wallet.total_score))
	var status=Design.label(g,"Loading...",Rect2(90,344,540,24),13,"b5c9e5",true);status.name="RankingStatus"
	var scroll=ScrollContainer.new();scroll.name="RankingScroll";scroll.layout_direction=Control.LAYOUT_DIRECTION_LTR;scroll.size=Vector2(550,480);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;g.ui.add_child(scroll);scroll.position=Vector2(85,372)
	var list=VBoxContainer.new();list.layout_direction=Control.LAYOUT_DIRECTION_LTR;list.custom_minimum_size=Vector2(530,0);list.add_theme_constant_override("separation",6);scroll.add_child(list)
	var state={"loading":false,"loaded":false}
	var refresh=g.button_at("Refresh",Rect2(105,883,230,60),func():
		if state.loading:return
		state.loading=true;status.text=L.t("Loading...");g.leaderboard.fetch_rankings(),Color("4b70a7"));refresh.title_size=27;refresh.name="RankingRefresh"
	var home=g.button_at("Home",Rect2(385,883,230,60),func():g.show_menu(),Color("4d8c77"));home.title_size=27
	var status_callback=func(value):
		if not is_instance_valid(status):return
		if value=="Online":status.text="";return
		if "Cannot load rankings" in value or "server setup" in value:state.loading=false;status.text=L.t(str(value));return
		if state.loading or not state.loaded:status.text=L.t(str(value))
	g.leaderboard.status_changed.connect(status_callback)
	var rows_callback=func(rows:Array):
		if not is_instance_valid(list):return
		for child in list.get_children():list.remove_child(child);child.queue_free()
		state.loading=false;state.loaded=true;status.text=L.t("No rankings yet") if rows.is_empty() else ""
		for i in range(mini(50,rows.size())):
			var row=preload("res://scripts/ranking_row.gd").new();row.rank=i+1;row.data=rows[i];list.add_child(row)
		own.text=L.t("Your score")+": "+L.digits(str(g.wallet.total_score))
	g.leaderboard.rankings_ready.connect(rows_callback)
	scroll.tree_exiting.connect(func():
		if g.leaderboard.rankings_ready.is_connected(rows_callback):g.leaderboard.rankings_ready.disconnect(rows_callback)
		if g.leaderboard.status_changed.is_connected(status_callback):g.leaderboard.status_changed.disconnect(status_callback))
	state.loading=true;g.leaderboard.fetch_rankings()
