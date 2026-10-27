extends RefCounted

var coins := 100
var total_score := 0
var records: Dictionary = {}

func restore(saved: Dictionary) -> void:
	coins = maxi(0, int(saved.get("coins",100)))
	total_score = maxi(0, int(saved.get("total_score",0)))
	records = saved.get("score_records",{}).duplicate(true)

func hint_price(level: int) -> int:
	return mini(75, 25 + (level / 100)*5)

func star_rating(moves: int, target: int, assisted: bool) -> int:
	var budget := maxi(3,target)
	var limits := preload("res://scripts/move_budget.gd").limits(budget)
	var stars := 3 if moves <= limits.x else (2 if moves <= limits.y else 1)
	if assisted:
		stars = mini(stars,2)
	return stars

func award(level: int, moves: int, target: int, assisted: bool) -> Dictionary:
	var budget := maxi(3,target)
	var stars := star_rating(moves,target,assisted)
	var score := maxi(50, 100 + stars*50 + mini(level,999)*2 - maxi(0,moves-budget)*5)
	var key := str(level)
	var old: Dictionary = records.get(key,{})
	var old_score := int(old.get("score",0))
	var gain := maxi(0,score-old_score)
	var reward := (15 + stars*5 + mini(15,level/50)) if old.is_empty() else (5 if gain>0 else 0)
	if gain>0:
		records[key] = {"score":score,"stars":stars}
		total_score += gain
	coins += reward
	return {"score":score,"stars":stars,"coins":reward,"improved":gain>0}

func buy_hint(level: int) -> bool:
	var cost := hint_price(level)
	if coins < cost:
		return false
	coins -= cost
	return true
