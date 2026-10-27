extends Node

var manager: Node
var banner: AdView
var rewarded: RewardedAd
var loading := false
var active_id := -1
var sdk_ready := false
var load_callback: RewardedAdLoadCallback
var reward_listener: OnUserEarnedRewardListener
var init_listener: OnInitializationCompleteListener
var status := "Starting ads"
var reward_load_serial:=0

func _ready() -> void:
	if not Engine.has_singleton("PoingGodotAdMob"):
		status = "AdMob native SDK missing: rebuild with Gradle"
		push_warning(status)
		return
	init_listener = OnInitializationCompleteListener.new()
	init_listener.on_initialization_complete = func(_result):
		sdk_ready = true
		load_banner()
		load_rewarded()
	MobileAds.initialize(init_listener)

func load_banner() -> void:
	if banner:
		banner.destroy()
	banner = AdView.new(manager.get_ad_unit("banner"), AdSize.BANNER, AdPosition.BOTTOM)
	banner.ad_listener.on_ad_loaded = func():
		if manager.banner_hidden:banner.hide()
		manager.banner_height_pixels = maxi(0,banner.get_height_in_pixels())
		manager.banner_geometry_changed.emit()
		status = "Test banner ready" if manager.configuration.test_mode else "Banner ready"
	banner.ad_listener.on_ad_failed_to_load = func(error):
		status = "Banner: " + error.message
		push_warning(status)
		get_tree().create_timer(30).timeout.connect(load_banner, CONNECT_ONE_SHOT)
	banner.load_ad(AdRequest.new())
	if manager.banner_hidden:banner.hide()

func load_rewarded() -> void:
	if not sdk_ready or loading or rewarded:
		return
	loading = true
	reward_load_serial+=1
	var serial:=reward_load_serial
	load_callback = RewardedAdLoadCallback.new()
	load_callback.on_ad_loaded = func(ad):
		if serial!=reward_load_serial:ad.destroy();return
		loading = false
		rewarded = ad
	load_callback.on_ad_failed_to_load = func(error):
		if serial!=reward_load_serial:return
		loading = false
		status = "Video: " + error.message
		push_warning(status)
		get_tree().create_timer(30).timeout.connect(load_rewarded, CONNECT_ONE_SHOT)
	RewardedAdLoader.new().load(manager.get_ad_unit("rewarded"), AdRequest.new(), load_callback)
	get_tree().create_timer(35).timeout.connect(func():
		if loading and serial==reward_load_serial:
			loading=false;reward_load_serial+=1
			get_tree().create_timer(30).timeout.connect(load_rewarded,CONNECT_ONE_SHOT),CONNECT_ONE_SHOT)

func show_rewarded(id: int) -> void:
	if not rewarded or active_id >= 0:
		manager.finish_reward(id, manager.Result.UNAVAILABLE)
		load_rewarded()
		return
	active_id = id
	manager.presentation_changed.emit(true)
	reward_listener = OnUserEarnedRewardListener.new()
	reward_listener.on_user_earned_reward = func(_item):
		if active_id==id:manager.finish_reward(id, manager.Result.COMPLETED)
	rewarded.full_screen_content_callback.on_ad_showed_full_screen_content=func():
		if active_id==id:manager.mark_presented(id)
	rewarded.full_screen_content_callback.on_ad_dismissed_full_screen_content = func():
		# SDK dispatches earned before dismissed. Defer once to preserve this order.
		finish_video.call_deferred(id, manager.Result.CANCELLED)
	rewarded.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(_error):
		finish_video(id, manager.Result.UNAVAILABLE)
	rewarded.show(reward_listener)

func finish_video(id: int, result: int) -> void:
	if active_id!=id:return
	manager.presentation_changed.emit(false)
	manager.presentation_active=false
	manager.finish_reward(id, result)
	active_id = -1
	if rewarded:
		rewarded.destroy()
	rewarded = null
	load_rewarded()

func _exit_tree() -> void:
	if banner:
		banner.destroy()
	if rewarded:
		rewarded.destroy()
