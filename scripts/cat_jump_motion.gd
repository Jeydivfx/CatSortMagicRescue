extends RefCounted
# Analytic motion on the existing artwork: no new frames, mesh or skeleton.
static func air_pose(t: float, direction: float, gentle: bool) -> Dictionary:
	var envelope:=sin(PI*clampf(t,0,1))
	var strength:=.25 if gentle else 1.0
	var stretch:=.065*envelope*strength
	return {"scale":Vector2(1.0-stretch*.6,1.0+stretch),"angle":-.095*sin(TAU*t)*direction*strength}
static func landing(age: float, gentle: bool) -> float:
	if age<0 or age>=.38:return 0.0
	var t:=age/.38
	# One soft compression and recovery; no repeated bouncing.
	return sin(PI*t)*pow(1-t,.7)*(.32 if gentle else .85)
static func duration(distance: float, gentle: bool) -> float:
	return .42 if gentle else clampf(.62+distance/2200.0,.68,.90)
static func arc(start: Vector2,finish: Vector2,ceiling: float,t: float) -> Vector2:
	var high:=maxf(ceiling,minf(start.y,finish.y)-145)
	return start.bezier_interpolate(Vector2(start.x,high),Vector2(finish.x,high),finish,t)
