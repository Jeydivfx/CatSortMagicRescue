extends RefCounted

const WORLDS = [
	{"name":"Moonlit Lab", "file":"res://assets/environments/laboratory.png", "accent":"75bce0", "shade":"102039", "particle":"ffd88a"},
	{"name":"Blossom Garden", "file":"res://assets/environments/garden.png", "accent":"a4d3b4", "shade":"102e2c", "particle":"f8bed2"},
	{"name":"Crystal Cave", "file":"res://assets/environments/cave.png", "accent":"7fd9dc", "shade":"102d36", "particle":"9cecf0"},
	{"name":"Forest Cottage", "file":"res://assets/environments/cottage.png", "accent":"d9b784", "shade":"263024", "particle":"ffe2a5"},
	{"name":"Magic Forest", "file":"res://assets/environments/enchanted_forest.png", "accent":"8fbace", "shade":"162a39", "particle":"a9e8d4"},
	{"name":"Witch Cabin", "file":"res://assets/environments/classic_witch_cabin_v2.png", "accent":"bc96ed", "shade":"172737", "particle":"efc78b"}
]

static func for_level(level: int, override_world: int = -1) -> int:
	if override_world >= 0:
		return clampi(override_world,0,WORLDS.size()-1)
	# Campaign chapters use a shared stable environment schedule.
	return preload("res://scripts/chapter_catalog.gd").world_for(level)
