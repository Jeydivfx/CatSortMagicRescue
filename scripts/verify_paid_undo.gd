extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false)
 g.start_game(2);g.cancel_witch_entry();g.busy=false;g.wallet.coins=30
 var state=g.tubes.duplicate(true)
 g.history=[state.duplicate(true),state.duplicate(true),state.duplicate(true),state.duplicate(true),state.duplicate(true)];g.moves=5
 for remaining in [2,1,0]:
  g.request_undo();assert(g.undo_left==remaining and g.wallet.coins==30)
 assert(g.moves==2 and g.history.size()==2 and g.undo_button.subtitle==g.L.t("VIDEO"))
 g.undo();assert(g.history.size()==2)
 g.request_undo();assert(g.pending_reward>=0 and g.history.size()==2)
 g.cancel_reward();assert(g.undo_left==0 and g.history.size()==2)
 g.request_undo();var id=g.pending_reward;g.ads.finish_reward(id,g.ads.Result.COMPLETED)
 assert(g.undo_left==0 and g.history.size()==1 and g.moves==1 and g.wallet.coins==30)
 g.ads.finish_reward(id,g.ads.Result.COMPLETED);assert(g.history.size()==1)
 g.request_undo();g.ads.finish_reward(g.pending_reward,g.ads.Result.UNAVAILABLE);assert(g.history.size()==1)
 g.start_game(2);g.cancel_witch_entry();assert(g.undo_left==3)
 g.history=[];g.request_undo();assert(g.undo_left==3 and g.pending_reward<0)
 g.free();await process_frame;print("PASS three free undos, one earned undo per video, cancellation/unavailable/duplicate safe, reset and no coin charge");quit()
