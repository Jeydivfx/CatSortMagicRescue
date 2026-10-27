shader_type canvas_item;
uniform vec4 base_rect;
uniform vec4 neutral_rect;
uniform vec4 blink_rect;
uniform vec4 happy_rect;
uniform vec4 grumpy_rect;
uniform vec4 weights = vec4(1.0, 0.0, 0.0, 0.0);
uniform bool ears_only = false;
uniform float compact_stack = 0.0;
uniform float celebration = 0.0;
uniform float motion_age = 0.0;
uniform float idle_motion = 0.0;
uniform float ear_flick = 0.0;
uniform float head_tilt = 0.0;
uniform vec2 menu_ears = vec2(0.0);
uniform vec4 eye_centers = vec4(.267,.385,.577,.385);
uniform vec2 eye_radius = vec2(.105,.095);
uniform float paw_reach = 0.0;
uniform float pleading = 0.0;
uniform float story_meow = 0.0;
uniform float story_walk = 0.0;
varying vec4 item_tint;

void vertex() {
	item_tint = COLOR;
	vec2 p = (UV - base_rect.xy) / base_rect.zw;
	// Shorten the seated torso while translating the face rigidly; paws stay anchored.
	VERTEX.y += 10.0*(1.0-smoothstep(.52,1.0,p.y))*compact_stack;
	float head = 1.0-smoothstep(0.42,0.66,p.y);
	// Small independent ear rotations, feathered to a fixed ear base.
	for(int side=0;side<2;side++) {
		float amount = side==0 ? menu_ears.x : menu_ears.y;
		float mask = (1.0-smoothstep(.13,.27,p.y))*(side==0 ? 1.0-smoothstep(.30,.42,p.x) : smoothstep(.55,.68,p.x));
		vec2 pivot = vec2(side==0 ? .18 : .76,.24);
		vec2 offset_ear = (p-pivot)*vec2(75.0,82.0);
		float angle = amount*(side==0 ? .13 : -.13);
		vec2 turned = vec2(cos(angle)*offset_ear.x-sin(angle)*offset_ear.y,sin(angle)*offset_ear.x+cos(angle)*offset_ear.y);
		VERTEX += (turned-offset_ear)*mask;
	}
	vec2 head_pivot = vec2(0.46,0.55);
	vec2 offset = (p-head_pivot)*vec2(75.0,82.0);
	float tilt = head_tilt*.055*head;
	VERTEX += vec2(-offset.y,offset.x)*tilt;
	float ear = (1.0-smoothstep(.08,.24,p.y))*smoothstep(.12,.28,abs(p.x-.45));
	VERTEX.x += ear*ear_flick*1.1;
	VERTEX.y += ear*ear_flick*0.75;
	float left_step = exp(-pow((p.x-.28)/.12,2.0))*smoothstep(.72,.87,p.y);
	float right_step = exp(-pow((p.x-.58)/.12,2.0))*smoothstep(.72,.87,p.y);
	VERTEX.y -= (left_step*max(0.0,sin(motion_age*8.0))+right_step*max(0.0,-sin(motion_age*8.0)))*3.0*story_walk;
	float reaching_paw = exp(-pow((p.x-.28)/.12,2.0))*smoothstep(.72,.87,p.y);
	VERTEX.y -= reaching_paw*18.0*paw_reach;
	VERTEX.x += reaching_paw*2.0*paw_reach;
	float ear_tip = (1.0-smoothstep(.08,.24,p.y))*smoothstep(.12,.28,abs(p.x-.45));
	VERTEX.y += ear_tip*2.5*pleading;
	float tail_idle = smoothstep(0.70,0.90,p.x)*smoothstep(0.45,0.65,p.y);
	VERTEX.x += sin(motion_age*1.65)*tail_idle*3.8*idle_motion;
	VERTEX.y += cos(motion_age*1.65)*tail_idle*1.3*idle_motion;
	VERTEX.x += sin(motion_age*.8)*head*.6*idle_motion;
	VERTEX.y -= sin(motion_age*1.8)*(1.0-smoothstep(.4,.85,p.y))*.7*idle_motion;
	VERTEX.x += sin(motion_age*2.5)*head*1.4*celebration;
	float paw = smoothstep(0.75,0.87,p.y)*(1.0-smoothstep(0.35,0.53,p.x))*smoothstep(0.10,0.20,p.x);
	VERTEX.y -= max(0.0,sin(motion_age*4.2))*paw*3.0*celebration;
	float tail = smoothstep(0.73,0.9,p.x)*smoothstep(0.50,0.69,p.y);
	VERTEX.x += sin(motion_age*3.5)*tail*2.2*celebration;
}

void fragment() {
	vec2 p = (UV - base_rect.xy) / base_rect.zw;
	vec4 base = texture(TEXTURE, UV);
	// Preserve one body, ears, paws and silhouette for every expression.
	// Only blend the painted facial oval, never dissolve whole cat sprites.
	vec2 face_uv = (p - vec2(0.43, 0.36)) / vec2(0.39, 0.265);
	float mask = 1.0 - smoothstep(0.70, 1.0, length(face_uv));
	vec3 result=base.rgb;
	if(mask>.001 && (weights.z>.001 || weights.w>.001)) {
		vec4 face=base*(weights.x+weights.y);
		if(weights.z>.001) face+=texture(TEXTURE,happy_rect.xy+p*happy_rect.zw)*weights.z;
		if(weights.w>.001) face+=texture(TEXTURE,grumpy_rect.xy+p*grumpy_rect.zw)*weights.w;
		result=mix(base.rgb,face.rgb,mask*face.a);
	}
	float closure = clamp(max(weights.y,weights.z),0.0,1.0);
	for(int eye=0;eye<2;eye++) {
		vec2 center = eye==0 ? eye_centers.xy : eye_centers.zw;
		vec2 q = (p-center)/eye_radius;
		float eye_patch = 1.0-smoothstep(1.03,1.17,length(q));
		if(eye_patch<=0.0) continue;
		// A solid eyeball remains behind the moving lid opening; no frame dissolve.
		vec3 open_eye = base.rgb;
		result = mix(result,open_eye,eye_patch);
		if(closure<=.001) continue;
		float seam = .60-.45*(1.0-clamp(q.x*q.x,0.0,1.0));
		float top = mix(-1.30,seam,closure);
		float bottom = mix(1.30,seam,closure);
		float upper_cover = 1.0-smoothstep(top-.025,top+.025,q.y);
		float lower_cover = smoothstep(bottom-.025,bottom+.025,q.y);
		// Preserve the original painted fur coordinates, including tabby stripes.
		vec3 fur = texture(TEXTURE,blink_rect.xy+p*blink_rect.zw).rgb;
		float cover = clamp(upper_cover+lower_cover,0.0,1.0)*eye_patch;
		result = mix(result,fur,cover);
	}
	float mouth = 1.0-smoothstep(.7,1.0,length((p-vec2(.43,.49))/vec2(.026,.045)));
	result = mix(result,vec3(.32,.11,.17),mouth*story_meow);
	float alpha=base.a;
	if(ears_only) alpha *= (1.0-smoothstep(.22,.29,p.y))*smoothstep(.15,.23,abs(p.x-.47));
	COLOR = vec4(result, alpha) * item_tint;
}
