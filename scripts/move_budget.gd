extends RefCounted

static func limits(target: int) -> Vector3i:
	var three := maxi(3,target)
	var maximum := maxi(three+2,ceili(three*4.0/3.0))
	var two := mini(maximum-1,maxi(three+1,ceili(three*7.0/6.0)))
	return Vector3i(three,two,maximum)
