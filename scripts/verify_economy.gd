extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var wallet = load("res://scripts/score_wallet.gd").new()
	assert(wallet.coins == 100)
	assert(wallet.buy_hint(0) and wallet.coins == 75)
	wallet.coins = 0
	assert(not wallet.buy_hint(0) and wallet.coins == 0)
	var first: Dictionary = wallet.award(0,3,3,false)
	assert(first.stars == 3 and first.coins == 30)
	var repeated: Dictionary = wallet.award(0,3,3,false)
	assert(repeated.coins == 0 and wallet.total_score == first.score)
	var assisted: Dictionary = wallet.award(1,3,3,true)
	assert(assisted.stars == 2)
	var better: Dictionary = wallet.award(1,3,3,false)
	assert(better.coins == 5 and better.stars == 3)
	assert(wallet.hint_price(999)>wallet.hint_price(0))
	var copy = load("res://scripts/score_wallet.gd").new()
	copy.restore({"coins":wallet.coins,"total_score":wallet.total_score,"score_records":wallet.records})
	assert(copy.coins == wallet.coins and copy.records == wallet.records)
	print("PASS score, stars, coin purchases, insufficient balance, replay protection, improvement and persistence")
	quit()
