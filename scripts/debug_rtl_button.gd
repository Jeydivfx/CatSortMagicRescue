extends SceneTree
func _initialize() -> void: call_deferred("run_test")
func run_test() -> void:
	var L = preload("res://scripts/localization.gd")
	L.set_locale("fa")
	var panel := Control.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	root.add_child(panel)
	var button := Button.new()
	L.style(button)
	button.text = "افکت‌ها روشن"
	button.position = Vector2(132,345)
	button.size = Vector2(180,54)
	print("BEFORE ADD ",button.position," size ",button.size)
	panel.add_child(button)
	print("AFTER ADD ",button.position," size ",button.size)
	L.style(button)
	print("AFTER STYLE ",button.position," size ",button.size)
	L.restyle_tree(panel)
	print("AFTER TREE ",button.position," size ",button.size)
	await create_timer(.1).timeout
	print("AFTER FRAME ",button.position," size ",button.size)
	quit()
