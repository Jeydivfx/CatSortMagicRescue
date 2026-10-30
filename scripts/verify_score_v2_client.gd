extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var c=load("res://scripts/avatar_client_test_double.gd").new();root.add_child(c);c.access_token="test-only";c.pending_scores={"0":40};c.response={"ok":true,"code":200,"data":40}
 await c.flush_scores();assert(c.pending_scores.is_empty());assert(c.calls[-1].path=="/rest/v1/rpc/submit_level_score_v2" and c.calls[-1].body.p_score==40)
 c.response={"ok":true,"code":200,"data":[{"player_name":"Test","total_score_v2":45,"avatar_id":"white"}]};var captured:Array=[]
 c.rankings_ready.connect(func(rows):captured.assign(rows));await c.fetch_rankings();assert(captured[0].total_score==45)
 c.response={"ok":false,"code":400,"data":{}};await c.fetch_rankings();assert("server setup" in c.status)
 c.free();print("PASS score v2 payload, pending acknowledgement, v2 ranking normalization and required-migration status; no live requests");quit()
