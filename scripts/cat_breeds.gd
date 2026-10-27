extends RefCounted

const ACTIVE_IDS := [0,1,2,3,4,5,6,10,11]

const NAMES := ["Ginger Tabby","Silver Tabby","Calico Bobtail","Tuxedo","Bombay","White Persian","Siamese","Sphynx","Scottish Fold","Bengal","Ragdoll","Russian Blue"]
const ATLASES := ["res://assets/cats/breeds_a.png","res://assets/cats/breeds_b.png","res://assets/cats/breeds_c.png"]
static var textures: Dictionary = {}

static func texture_for(kind: int) -> Texture2D:
	var group := clampi(kind,0,NAMES.size()-1)/4
	if kind<3: group = -1
	if not textures.has(group): textures[group] = load("res://assets/cats_expressions.png" if group<0 else ATLASES[group])
	return textures[group]
