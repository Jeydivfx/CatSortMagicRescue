extends RefCounted
static func texture(index:int)->AtlasTexture:
	var source=load("res://assets/branding/ranking_badges_v1.png") as Texture2D
	var regions=[Rect2(23,61,616,526),Rect2(652,68,473,572),Rect2(1168,68,470,569),Rect2(1671,68,461,572)]
	var t=AtlasTexture.new();t.atlas=source;t.region=regions[clampi(index,0,3)];return t
