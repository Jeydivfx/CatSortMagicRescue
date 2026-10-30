extends RefCounted
# One fixed skeleton. Angles/targets are continuous; root and global scale never animate.
const DURATIONS={"mischief_spell":3.0,"evil_idle":4.8,"inspect_staff":2.6,"taunt":2.4,"evil_laugh":2.8,"mock_player":2.6,"angry":2.8,"shocked":2.2,"evil_spell":2.8,"nervous":4.8,"panic":2.4,"defeated":2.6,"defeated_idle":4.8,"victory_laugh":3.2,"fake_cry":2.8,"broom_entry":4.8}
const IMPACT_TIME=1.08
static func duration(state: String) -> float:return float(DURATIONS.get(state,4.8))
static func eased(a: float,b: float,t: float) -> float:return smoothstep(a,b,t)
static func pulse(t: float,start: float,rise: float,fall: float,end: float) -> float:return eased(start,rise,t)*(1-eased(fall,end,t))
static func neutral() -> Dictionary:
	return {"body_angle":0.0,"head_angle":0.0,"body_y":0.0,"head_y":0.0,"left_x":-49.0,"left_y":-32.0,"right_x":49.0,"right_y":-32.0,"staff_angle":-.025,"staff_show":1.0,"staff_drop":0.0,"broom":0.0,"feet_up":0.0,"smile":.28,"mouth":.05,"anger":0.0,"sad":0.0,"surprise":0.0,"blink":0.0,"gaze_x":0.0,"gaze_y":0.0,"sweat":0.0,"tear":0.0,"tear_phase":0.0,"spell":0.0,"point":0.0}
static func sample(state: String,time: float) -> Dictionary:
	var p:=neutral();var d:=duration(state);var t:=clampf(time,0,d)
	var u:=t/d;var breathe:=sin(TAU*t/4.8)
	if state in ["evil_idle","nervous","defeated_idle","broom_entry"]:t=fposmod(maxf(time,0),d);u=t/d;breathe=sin(TAU*u)
	match state:
		"mischief_spell":
			p=sample("evil_spell",t)
			var laugh:=pulse(t,.12,.40,1.45,2.0)
			p.smile=.28+.65*laugh;p.mouth=.05+.65*laugh;p.blink=.55*laugh
		"sleep":
			var breath=sin(TAU*time/3.8)
			p.blink=1.0;p.smile=.02;p.mouth=.10+.035*(1+breath);p.head_angle=.13;p.head_y=3.0+.6*breath;p.body_y=.5*breath;p.staff_angle=.06
		"evil_idle":
			p.body_y=-.70*breathe;p.head_y=-.35*breathe;p.head_angle=.008*breathe
			p.blink=pulse(t,2.76,2.84,2.91,3.05)
		"inspect_staff":
			var e:=pulse(t,.25,.9,1.7,2.6)
			p.right_x=lerpf(49,75,e);p.right_y=lerpf(-32,-66,e);p.staff_angle=lerpf(-.025,-.16,e)
			p.head_angle=-.055*e;p.gaze_x=2.0*e;p.left_x=lerpf(-49,-30,e);p.left_y=lerpf(-32,-75,e)
		"taunt":
			var e:=pulse(t,.2,.85,1.55,2.4)
			p.gaze_x=-2.0*e;p.mouth=.05+.20*e;p.staff_angle=-.025+.10*e
			p.head_angle=.04*e;p.left_x=lerpf(-49,-62,e);p.left_y=lerpf(-32,-95,e);p.smile=.28+.35*e;p.blink=.5*pulse(t,1.02,1.15,1.24,1.42)
		"evil_laugh","victory_laugh":
			var e:=pulse(t,.15,.65,d-.65,d)
			var chuckle:=sin((t-.65)*TAU/1.05)*e
			p.smile=.28+.65*e;p.mouth=.05+.7*e;p.blink=.65*e
			p.head_angle=-.035*e;p.head_y=-.45*chuckle;p.body_y=-.25*chuckle
			p.left_x=lerpf(-49,-61,e);p.left_y=lerpf(-32,-70,e)
			p.right_x=lerpf(49,59,.35*e);p.right_y=lerpf(-32,-46,.35*e)
		"mock_player":
			var e:=pulse(t,.25,.85,1.7,2.6)
			p.left_x=lerpf(-49,-15,e);p.left_y=lerpf(-32,-150,e);p.head_angle=.04*e;p.smile=.28+.45*e;p.mouth=.05+.25*e;p.point=e
		"angry","evil_spell":
			var emotion:=pulse(t,.12,.55,2.0,2.8)
			var raise:=eased(.25,.78,t)*(1-eased(.84,IMPACT_TIME,t))
			p.right_x=lerpf(49,82,raise);p.right_y=lerpf(-32,-103,raise)
			p.staff_angle=lerpf(-.025,-.16,raise)
			p.left_x=lerpf(-49,-62,emotion);p.left_y=lerpf(-32,-58,emotion)
			if state=="angry":p.anger=emotion;p.smile=.28-.85*emotion;p.mouth=.05
			else:p.smile=.28+.4*emotion;p.gaze_x=1.5*emotion;p.spell=pulse(t,.7,.94,1.35,1.9)
			p.head_angle=-.045*emotion;p.body_angle=-.020*emotion
		"shocked":
			var e:=pulse(t,.15,.55,1.35,2.2)
			p.surprise=e;p.mouth=.05+.6*e;p.smile=.28*(1-e);p.head_angle=.045*e
			p.left_x=lerpf(-49,-70,e);p.left_y=lerpf(-32,-108,e);p.right_x=lerpf(49,76,e);p.right_y=lerpf(-32,-80,e)
		"nervous":
			p.sad=.45;p.smile=-.15;p.mouth=.08;p.sweat=.7
			p.gaze_x=1.3*sin(TAU*u);p.left_x=-30;p.left_y=-91;p.staff_angle=-.025+.006*sin(TAU*u)
			p.blink=pulse(t,3.0,3.08,3.16,3.3)
		"panic":
			var e:=pulse(t,.15,.8,1.5,2.4)
			p.sad=.7*e;p.surprise=.6*e;p.mouth=.05+.4*e;p.smile=.28-.5*e;p.sweat=e
			p.left_x=lerpf(-49,-61,e);p.left_y=lerpf(-32,-156,e);p.right_x=lerpf(49,80,e);p.right_y=lerpf(-32,-86,e)
		"defeated":
			var e:=eased(.2,1.0,t)
			p.anger=e;p.sad=.4*e;p.smile=.28-.75*e;p.head_angle=.07*e
			var raise:=eased(.3,.8,t)*(1-eased(.86,IMPACT_TIME,t))
			p.right_x=lerpf(49,82,raise);p.right_y=lerpf(-32,-103,raise);p.staff_angle=lerpf(-.025,-.16,raise)
			p.staff_drop=eased(IMPACT_TIME,1.9,t)
			p.left_x=lerpf(-49,-43,e);p.left_y=lerpf(-32,-45,e)
		"defeated_idle":
			p.anger=1;p.sad=.4;p.smile=-.47;p.head_angle=.07;p.staff_drop=1;p.left_x=-43;p.left_y=-45
			p.body_y=-.2*breathe;p.head_y=-.1*breathe
		"fake_cry":
			p.anger=1;p.sad=.4;p.smile=-.47;p.head_angle=.07;p.staff_drop=1;p.left_x=-43;p.left_y=-45
			var e:=pulse(t,.2,.8,1.8,2.8)
			p.left_x=lerpf(-43,-34,e);p.left_y=lerpf(-45,-169,e);p.right_x=lerpf(49,36,e);p.right_y=lerpf(-32,-166,e)
			p.blink=.95*e;p.tear=e;p.tear_phase=t;p.sad=.4+.6*e;p.anger=1-.85*e;p.mouth=.05
			p.body_y=-.45*e*sin(t*TAU/1.6);p.head_angle=.07+.015*e*sin(t*TAU/1.6)
		"broom_entry":
			p.broom=1;p.staff_show=0;p.feet_up=24;p.left_x=-65;p.left_y=-119;p.right_x=34;p.right_y=-34
			p.smile=.8;p.mouth=.45;p.blink=.30+.18*sin(TAU*u);p.head_angle=-.035
	return p
