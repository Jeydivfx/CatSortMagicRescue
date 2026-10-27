extends RefCounted

const WORLDS = [
	{"name":"Moonlit Lab", "file":"res://assets/environments/laboratory.png", "accent":"75bce0", "shade":"102039", "particle":"ffd88a"},
	{"name":"Cozy Cafe", "file":"res://assets/environments/cafe.png", "accent":"e7b07f", "shade":"2c1928", "particle":"ffe4b7"},
	{"name":"Blossom Garden", "file":"res://assets/environments/garden.png", "accent":"a4d3b4", "shade":"102e2c", "particle":"f8bed2"},
	{"name":"Witch Tower", "file":"res://assets/environments/tower.png", "accent":"bc96ed", "shade":"201530", "particle":"d9b0ff"},
	{"name":"Crystal Cave", "file":"res://assets/environments/cave.png", "accent":"7fd9dc", "shade":"102d36", "particle":"9cecf0"},
	{"name":"Forest Cottage", "file":"res://assets/environments/cottage.png", "accent":"d9b784", "shade":"263024", "particle":"ffe2a5"}
]

static func for_level(level: int, override_world: int = -1) -> int:
	if override_world >= 0:
		return clampi(override_world,0,WORLDS.size()-1)
	# Every hundred levels changes world. Cycle all available environments.
	return (maxi(0,level)/100) % WORLDS.size()
