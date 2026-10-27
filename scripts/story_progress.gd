extends RefCounted
const INTRO_VERSION := 5
var intro_seen := false
var tutorial_seen := false
var worlds: Array = []

func restore(data: Dictionary) -> void:
	intro_seen = bool(data.get("intro_seen",false)) and int(data.get("intro_version",0))==INTRO_VERSION
	tutorial_seen = bool(data.get("tutorial_seen",false))
	worlds = data.get("worlds",[]).duplicate() if data.get("worlds",[]) is Array else []

func snapshot() -> Dictionary:
	return {"intro_version":INTRO_VERSION,"intro_seen":intro_seen,"tutorial_seen":tutorial_seen,"worlds":worlds.duplicate()}
