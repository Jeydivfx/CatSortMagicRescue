extends RefCounted
## Stable campaign chapters. Levels and saved record indexes never change.
const SIZE=50
const WORLD_ORDER=[0,1,2,3,4,5,2,4,0,1,3,5,4,2,1,0,5,3,2,4]
static func chapter_for(level:int)->int:return clampi(maxi(0,level)/SIZE,0,WORLD_ORDER.size()-1)
static func world_for(level:int)->int:return WORLD_ORDER[chapter_for(level)]
static func completed_in(chapter:int,unlocked:int,records:Dictionary,total:int)->int:
 var first=chapter*SIZE;var last=mini(total,first+SIZE);var done=0
 for i in range(first,last):
  if i<unlocked-1 or records.has(str(i)):done+=1
 return done
