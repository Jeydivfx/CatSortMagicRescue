extends RefCounted

var coins := 100
var total_score := 0
var records: Dictionary = {}
const SCORE_VERSION=2
var legacy_total_score:=0

func restore(saved: Dictionary, catalog:Array=[]) -> void:
	coins=maxi(0,int(saved.get("coins",100)))
	legacy_total_score=maxi(0,int(saved.get("legacy_total_score",saved.get("total_score",0))))
	records=saved.get("score_records",{}).duplicate(true)
	var migrating=int(saved.get("score_version",1))<SCORE_VERSION
	total_score=0
	for key in records:
		var record=records[key]
		if not record is Dictionary:continue
		if migrating:
			var index=int(str(key));var hard=index>=0 and index<catalog.size() and catalog[index].get("difficulty","")=="hard"
			record["legacy_score"]=int(record.get("score",0))
			record["score"]=10+clampi(int(record.get("stars",1)),1,3)*10+(5 if hard else 0)
			record["score_version"]=SCORE_VERSION
		total_score+=int(record.get("score",0))

func hint_price(level: int) -> int:
	return mini(75, 25 + (level / 100)*5)

func star_rating(moves: int, target: int, assisted: bool) -> int:
	var budget := maxi(3,target)
	var limits := preload("res://scripts/move_budget.gd").limits(budget)
	var stars := 3 if moves <= limits.x else (2 if moves <= limits.y else 1)
	if assisted:
		stars = mini(stars,2)
	return stars

func award(level: int, moves: int, target: int, assisted: bool, hard: bool=false) -> Dictionary:
	var budget := maxi(3,target)
	var stars := star_rating(moves,target,assisted)
	var efficiency_bonus:=5 if moves<budget and not assisted else 0
	var difficulty_bonus:=5 if hard else 0
	var score:=10+stars*10+efficiency_bonus+difficulty_bonus
	var key := str(level)
	var old: Dictionary = records.get(key,{})
	var old_score := int(old.get("score",0))
	var gain := maxi(0,score-old_score)
	var reward := (15 + stars*5 + mini(15,level/50)) if old.is_empty() else (5 if gain>0 else 0)
	if gain>0:
		records[key]=old.duplicate(true)
		records[key].merge({"score":score,"stars":stars,"score_version":SCORE_VERSION,"moves":moves,"target":budget,"assisted":assisted,"hard":hard},true)
		total_score += gain
	coins += reward
	return {"score":score,"stars":stars,"coins":reward,"improved":gain>0,"efficiency_bonus":efficiency_bonus,"difficulty_bonus":difficulty_bonus}

func buy_hint(level: int) -> bool:
	var cost := hint_price(level)
	if coins < cost:
		return false
	coins -= cost
	return true
