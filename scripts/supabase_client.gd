
extends Node

signal profile_ready
signal rankings_ready(rows: Array)
signal status_changed(value: String)

const BASE = "https://mwcbiwrcnsrxqsygdhwj.supabase.co"
const API_KEY = "sb_publishable_DyXbcHVFYY9SvmHXWRgzVA_Ej-Ubr1C"
const SAVE = "user://leaderboard_identity.json"

var player_name := ""
var avatar_id := "orange"
var avatar_pending := true
var syncing_avatar := false
var access_token := ""
var refresh_token := ""
var user_id := ""
var pending_scores: Dictionary = {}
var sending := false
var connecting := false
var status := "Connecting..."
var request_node: HTTPRequest

func _ready() -> void:
    request_node = HTTPRequest.new()
    add_child(request_node)
    load_identity()
    var retry = Timer.new()
    retry.wait_time = 30.0
    retry.autostart = true
    add_child(retry)
    retry.timeout.connect(func():
        if player_name == "":
            return
        if access_token == "":
            connect_player()
        elif not sending:
            sync_avatar()
            flush_scores()
    )
    if player_name != "":
        connect_player()

func load_identity() -> void:
    if not FileAccess.file_exists(SAVE):
        return
    var d = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
    if d is Dictionary:
        player_name = str(d.get("name", ""))
        avatar_id = preload("res://scripts/player_avatars.gd").valid(str(d.get("avatar_id","orange")))
        avatar_pending = bool(d.get("avatar_pending",true))
        access_token = str(d.get("access", ""))
        refresh_token = str(d.get("refresh", ""))
        user_id = str(d.get("id", ""))
        pending_scores = d.get("pending", {}) if int(d.get("pending_score_version",1))>=2 else {}

func persist() -> void:
    var f = FileAccess.open(SAVE, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"name":player_name,"avatar_id":avatar_id,"avatar_pending":avatar_pending,"access":access_token,"refresh":refresh_token,"id":user_id,"pending":pending_scores,"pending_score_version":2}))

func set_status(s: String) -> void:
    status = s
    status_changed.emit(s)

func http(method: int, path: String, body: Dictionary = {}, authenticated := true) -> Dictionary:
    # Auth, score sync and rankings may overlap. Each call owns its request.
    var request_node = HTTPRequest.new()
    request_node.timeout = 20.0
    add_child(request_node)
    var headers = PackedStringArray(["apikey: " + API_KEY, "Content-Type: application/json"])
    if authenticated and access_token != "":
        headers.append("Authorization: Bearer " + access_token)
    var error = request_node.request(BASE + path, headers, method, JSON.stringify(body) if method != HTTPClient.METHOD_GET else "")
    if error != OK:
        request_node.queue_free()
        return {"ok":false,"code":0,"data":{}}
    var response = await request_node.request_completed
    request_node.queue_free()
    var code = int(response[1])
    var parsed = null
    var payload: String=response[3].get_string_from_utf8()
    if not payload.is_empty():
        var decoder=JSON.new()
        if decoder.parse(payload)==OK:parsed=decoder.data
    return {"ok":code >= 200 and code < 300,"code":code,"data":parsed}

func choose_name(name: String, selected_avatar: String="orange") -> void:
    name = name.strip_edges()
    if name.length() < 2 or name.length() > 20:
        set_status("Name must be 2-20 characters.")
        return
    player_name = name
    avatar_id = preload("res://scripts/player_avatars.gd").valid(selected_avatar)
    avatar_pending = true
    persist()
    connect_player()

func connect_player() -> void:
    if player_name == "" or connecting:
        return
    connecting = true
    set_status("Connecting...")
    var ok := false
    if refresh_token != "":
        var result = await http(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=refresh_token", {"refresh_token":refresh_token}, false)
        if result.ok and result.data is Dictionary:
            accept_session(result.data)
            ok = true
        elif result.code == 0 or result.code >= 500:
            set_status("Offline. Retrying automatically.")
            connecting = false
            return
    if not ok:
        # New anonymous identity; no email or password.
        var result = await http(HTTPClient.METHOD_POST, "/auth/v1/signup", {}, false)
        if not result.ok or not (result.data is Dictionary):
            set_status("Offline. Retrying automatically.")
            connecting = false
            return
        accept_session(result.data)
    var profile = await http(HTTPClient.METHOD_POST, "/rest/v1/players?on_conflict=id",
        {"id":user_id,"player_name":player_name},
        true)
    # PostgREST upsert would need UPDATE policy; instead insert below if necessary.
    if not profile.ok:
        var create = await http(HTTPClient.METHOD_POST, "/rest/v1/players",
            {"id":user_id,"player_name":player_name})
        if not create.ok and create.code != 409:
            set_status("Profile setup failed (" + str(create.code) + ")")
            connecting = false
            return
    connecting = false
    await sync_avatar()
    if not avatar_pending:set_status("Online")
    profile_ready.emit()
    sync_existing_scores()
    flush_scores()

func sync_avatar() -> void:
    if not avatar_pending or syncing_avatar or connecting or access_token.is_empty():return
    syncing_avatar=true
    var selected=avatar_id
    var selected_name=player_name
    var result=await http(HTTPClient.METHOD_POST,"/rest/v1/rpc/set_player_avatar",{"p_avatar":selected,"p_name":selected_name})
    if result.ok:
        if avatar_id==selected and player_name==selected_name:avatar_pending=false
        persist()
    elif result.code==404:
        set_status("Avatar sync requires server setup (set_player_avatar).")
    elif result.code==401:
        syncing_avatar=false
        connect_player()
        return
    else:set_status("Avatar saved on device. Retrying automatically.")
    syncing_avatar=false

func accept_session(d: Dictionary) -> void:
    access_token = str(d.get("access_token",""))
    refresh_token = str(d.get("refresh_token",""))
    var u = d.get("user",{})
    if u is Dictionary:
        user_id = str(u.get("id",user_id))
    persist()

func sync_existing_scores() -> void:
    var game = get_parent()
    if game == null:
        return
    for key in game.wallet.records.keys():
        var record = game.wallet.records[key]
        if record is Dictionary:
            var score = int(record.get("score", 0))
            if score > 0:
                var k = str(key)
                pending_scores[k] = maxi(int(pending_scores.get(k, 0)), score)
    persist()

func queue_score(level: int, score: int) -> void:
    if score <= 0:
        return
    var k = str(level)
    pending_scores[k] = maxi(int(pending_scores.get(k,0)), score)
    persist()
    flush_scores()

func flush_scores() -> void:
    if sending or connecting or access_token == "" or pending_scores.is_empty():
        return
    sending = true
    for k in pending_scores.keys():
        var score = int(pending_scores[k])
        var result = await http(HTTPClient.METHOD_POST, "/rest/v1/rpc/submit_level_score_v2",
            {"p_level":int(k),"p_score":score})
        if result.code == 401:
            sending = false
            connect_player()
            return
        if result.ok:
            if int(pending_scores.get(k,0)) <= score:
                pending_scores.erase(k)
            persist()
        else:
            if result.code == 404 and result.data is Dictionary and str(result.data.get("code",""))=="PGRST202":
                set_status("Score sync unavailable: server setup required (submit_level_score_v2).")
            else:set_status("Sync failed: HTTP " + str(result.code))
            break
    sending = false
    if pending_scores.is_empty():
        set_status("Online")

func fetch_rankings() -> void:
    var result = await http(HTTPClient.METHOD_GET,
        "/rest/v1/players?select=player_name,total_score_v2,avatar_id&order=total_score_v2.desc&limit=50",{},false)
    # Older servers still show scores while the avatar migration is pending.
    if not result.ok and result.code==400:
        result=await http(HTTPClient.METHOD_GET,"/rest/v1/players?select=player_name,total_score_v2&order=total_score_v2.desc&limit=50",{},false)
    if result.ok and result.data is Array:
        for row in result.data:row["total_score"]=int(row.get("total_score_v2",0))
        rankings_ready.emit(result.data)
    else:
        set_status("Ranking update requires server setup (score v2)." if result.code==400 else "Cannot load rankings. Check internet.")
