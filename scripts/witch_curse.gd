extends RefCounted
## Warn, allow a counter, then seal for two successful moves with a safety expiry.
var tube := -1
var pending := -1
var left := 0.0
var used := false
var casts := 0
var last_cast_move := -100
var warning_left:=0.0
var launched:=false
var turns_left:=0
func reset() -> void:
	clear();used=false;casts=0;last_cast_move=-100
func clear() -> void:
	tube=-1;pending=-1;left=0;warning_left=0;launched=false;turns_left=0
func blocked(index: int) -> bool:return left>0 and index==tube
func has_alternative(g, excluded: int) -> bool:
	for a in range(g.tubes.size()):
		if a==excluded or g.is_complete(g.tubes[a]):continue
		for b in range(g.tubes.size()):
			if b!=excluded and g.legal(g.tubes,a,b):return true
	return false
func try_cast(g) -> void:
	var hard: bool=g.levels[g.level_index].get("difficulty","")=="hard"
	var maximum := 2 if hard and g.level_index>=30 else 1
	if casts>=maximum or pending>=0 or left>0 or g.level_index<15:return
	if not hard and (g.level_index*7+3)%5>=2:return
	if g.moves-last_cast_move<7:return
	if g.moves<4+g.level_index%3 or g.won or g.lost or g.entering or g.busy or g.drag_active:return
	var total: int=g.levels[g.level_index].get("colors",2)
	var completed: int=g.tubes.filter(func(t):return g.is_complete(t)).size()
	if completed>=total-1:return
	var candidates: Array=[]
	for i in range(g.tubes.size()):
		if not g.is_complete(g.tubes[i]) and has_alternative(g,i):candidates.append(i)
	if candidates.is_empty():return
	pending=candidates[(g.level_index*13+g.moves)%candidates.size()]
	warning_left=1.25;launched=false
	g.message="The witch is aiming! Move this tube to stop her."
	g.refresh()
func impact(g) -> bool:
	if pending<0 or not launched:return false
	var target:=pending
	pending=-1;warning_left=0
	if g.busy or g.drag_active or g.won or g.lost or g.entering or g.screen!="game" or g.is_complete(g.tubes[target]) or not has_alternative(g,target):return false
	tube=target;left=8.0;turns_left=2;used=true;casts+=1;last_cast_move=g.moves
	g.audio.play("witch_entry_spell")
	g.message="Two moves break the seal."
	g.refresh()
	return true
func on_move(g,source: int,destination: int) -> void:
	if pending>=0 and (pending==source or pending==destination):
		pending=-1;warning_left=0;launched=false;used=true;casts+=1;last_cast_move=g.moves
		g.message="You stopped her spell!";g.wizard.react_good_move();g.audio.play("purchase")
		return
	if left>0:
		turns_left=maxi(0,turns_left-1)
		if turns_left==0:release(g)
func release(g) -> void:
	tube=-1;left=0;turns_left=0
	g.message="The spell faded. Keep sorting!";g.audio.play("escape");g.refresh()
func update(delta: float,g) -> void:
	if not g.audio.suspension_reasons.is_empty() or g.entering or g.busy or g.drag_active or g.pending_reward>=0:return
	if pending>=0 and not launched:
		warning_left=maxf(0,warning_left-delta)
		if warning_left==0:launched=true;g.wizard.cast_obstacle()
	if left>0:
		left=maxf(0,left-delta)
		if left==0 or not has_alternative(g,tube):release(g)
func reject(g) -> void:
	g.message="Two moves break the seal."
	g.audio.play("tap")
	g.refresh()
