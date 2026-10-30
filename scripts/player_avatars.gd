extends RefCounted
const IDS=["orange","silver","black","white","siamese","clover","dreamer","calico"]
const FILE="res://assets/branding/player_avatars_v2.png"
static func valid(id:String)->String:return id if id in IDS else IDS[0]
static func texture(id:String)->AtlasTexture:
	var source=load(FILE) as Texture2D
	var i=IDS.find(valid(id));var result=AtlasTexture.new();result.atlas=source
	var cell=source.get_size()/Vector2(4,2);result.region=Rect2(Vector2(i%4,i/4)*cell,cell);return result
