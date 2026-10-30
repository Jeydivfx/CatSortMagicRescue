extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var c=load("res://scripts/avatar_client_test_double.gd").new();root.add_child(c);c.user_id="existing-player"
 c.choose_name(" New Name ","black");assert(c.player_name=="New Name" and c.avatar_id=="black" and c.avatar_pending and c.persisted.id=="existing-player")
 c.access_token="test-only-token";await c.sync_avatar();assert(not c.avatar_pending);assert(c.calls[0].body=={"p_avatar":"black","p_name":"New Name"})
 c.choose_name("Other","white");c.response={"ok":false,"code":0,"data":{}};await c.sync_avatar();assert(c.avatar_pending and c.avatar_id=="white")
 c.response={"ok":true,"code":200,"data":"white"};await c.sync_avatar();assert(not c.avatar_pending)
 c.choose_name("X","silver");assert(c.player_name=="Other" and c.avatar_id=="white")
 c.choose_name("Valid","INVALID");assert(c.avatar_id=="orange")
 for call in c.calls:assert(not call.body.has("total_score") and not call.body.has("id"))
 c.free();print("PASS profile RPC payload, stable player identity, avatar/name validation, offline retry, no score updates; no live server or disk writes");quit()
