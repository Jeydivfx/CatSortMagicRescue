extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var wallet=preload("res://scripts/score_wallet.gd").new()
 for hard in [false,true]:
  for assisted in [false,true]:
   for level in [0,50,999]:
    for moves in range(3,45):
     var w=preload("res://scripts/score_wallet.gd").new();var r=w.award(level,moves,10,assisted,hard);assert(r.score>=20 and r.score<=50)
     if assisted:assert(r.stars<=2 and r.efficiency_bonus==0)
 var a=preload("res://scripts/score_wallet.gd").new();var b=preload("res://scripts/score_wallet.gd").new();assert(a.award(0,10,10,false).score==40);assert(b.award(999,10,10,false).score==40)
 var before=a.total_score;var repeat=a.award(0,10,10,false);assert(a.total_score==before and repeat.coins==0)
 var hard=preload("res://scripts/score_wallet.gd").new();assert(hard.award(0,9,10,false,true).score==50)
 var saved={"coins":123,"total_score":2500,"score_records":{"0":{"score":250,"stars":3},"1":{"score":2000,"stars":2}}}
 wallet.restore(saved);assert(wallet.coins==123 and wallet.total_score==70 and wallet.records["0"].legacy_score==250)
 var snapshot={"coins":wallet.coins,"score_version":2,"score_records":wallet.records,"legacy_total_score":wallet.legacy_total_score};var restored=preload("res://scripts/score_wallet.gd").new();restored.restore(snapshot);assert(restored.total_score==70 and restored.records==wallet.records)
 assert(saved.score_records["0"].score==250)
 print("PASS compact scoring 20–50, level-independent, assisted cap, best-only totals/no replay coins, migration/idempotence, original record preservation");quit()
