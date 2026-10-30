extends SceneTree
func _initialize() -> void:
	var l=preload("res://scripts/localization.gd")
	l.set_locale("fa")
	assert(l.t("0123456789")=="۰۱۲۳۴۵۶۷۸۹")
	for source in ["Level 92","2006","13/24","Score 150", "Hint 25"]:
		var result: String=l.t(source)
		for digit in "0123456789":assert(not result.contains(digit))
	l.set_locale("en");assert(l.t("Level 92")=="Level 92")
	print("PASS Persian digits, counters, ratios and English preservation");quit()
