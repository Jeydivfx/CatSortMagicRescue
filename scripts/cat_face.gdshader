shader_type canvas_item;
uniform bool authored_lids=false;
uniform bool original_fur_fill=false;
uniform vec2 silver_face_origin=vec2(0);
uniform vec2 silver_face_scale=vec2(1);
uniform float drowse=0.0;
uniform sampler2D lids_texture : source_color, filter_linear;
uniform vec4 lids_centers=vec4(.333,.460,.595,.472);
uniform vec2 lids_sample_radius=vec2(.084,.065);
uniform vec3 lash_left=vec3(-.19448,.24610,-.01268);
uniform vec3 lash_right=vec3(-.24084,.07711,.14213);
uniform vec2 eye_aperture_radius=vec2(.094,.082);
uniform vec2 mouth_target=vec2(.4615,.526);
uniform vec2 mouth_source=vec2(.495,.531);
uniform vec2 mouth_map_scale=vec2(.906,1.041);
uniform vec2 mouth_mask_center=vec2(.4615,.535);
uniform vec2 mouth_mask_radius=vec2(.10,.080);
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
	// Continuous dozing on the same body/UVs: no replacement-pose cut.
	VERTEX.y += head*drowse*(1.8+.35*sin(motion_age*.75));
	VERTEX.x += head*drowse*.35*sin(motion_age*.55);
	float chest=smoothstep(.48,.62,p.y)*(1.0-smoothstep(.81,.96,p.y));
	VERTEX.x += (p.x-.46)*1.1*sin(motion_age*1.3)*chest*drowse;

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

vec4 silver_fur(vec2 p){
	// Dedicated clean fur plate: no baked eyes, lashes, threshold switches or runtime inpainting.
	return texture(lids_texture,silver_face_origin+p*silver_face_scale);
}

void fragment() {
	vec2 p = (UV - base_rect.xy) / base_rect.zw;
	vec4 base = texture(TEXTURE, UV);
	// Preserve one body, ears, paws and silhouette for every expression.
	// Only blend the painted facial oval, never dissolve whole cat sprites.
	vec2 face_uv = (p - vec2(0.43, 0.36)) / vec2(0.39, 0.265);
	float mask = 1.0 - smoothstep(0.70, 1.0, length(face_uv));
	vec3 result=base.rgb;
	// Neutral is the exact original portrait. Clean fur is used only inside moving
	// eyelids below; never repaint the forehead, eyebrows or whole face.
	if(!authored_lids && mask>.001 && (weights.z>.001 || weights.w>.001)) {
		vec4 face=base*(weights.x+weights.y);
		if(weights.z>.001) face+=texture(TEXTURE,happy_rect.xy+p*happy_rect.zw)*weights.z;
		if(weights.w>.001) face+=texture(TEXTURE,grumpy_rect.xy+p*grumpy_rect.zw)*weights.w;
		result=mix(base.rgb,face.rgb,mask*face.a);
	}
	if(authored_lids && weights.z>.001){
		// Register only the mouth. Neutral head, cheeks, ears, body and alpha never change.
		vec2 mouth_p=(p-mouth_target)*mouth_map_scale+mouth_source;
		vec3 mouth_paint=texture(TEXTURE,happy_rect.xy+mouth_p*happy_rect.zw).rgb;
		float mouth_mask=1.0-smoothstep(.78,1.0,length((p-mouth_mask_center)/mouth_mask_radius));
		result=mix(result,mouth_paint,mouth_mask*smoothstep(.10,.90,weights.z));
	}
	float closure = clamp(weights.y+weights.z+weights.w*.38,0.0,1.0);
	if(original_fur_fill){
		// A continuous fur band across both eyes prevents two coin-shaped
		// donor patches. Feather only into unchanged forehead and cheeks.
		float band=smoothstep(.265,.325,p.y)*(1.0-smoothstep(.435,.485,p.y));
		band*=smoothstep(.08,.19,p.x)*(1.0-smoothstep(.77,.86,p.x));
		band*=smoothstep(.055,.105,abs(p.x-.46));
		result=mix(result,silver_fur(p).rgb,band*smoothstep(0,.18,closure));
	}
	for(int eye=0;eye<2;eye++) {
		vec2 center = eye==0 ? eye_centers.xy : eye_centers.zw;
		vec2 q = (p-center)/eye_radius;
		float eye_patch = 1.0-smoothstep(1.03,1.17,length(q));
		if(eye_patch<=0.0) continue;
		if(authored_lids){
			if(closure<=.001){
				continue;
			}
			// Curved eyelids on one fixed eyeball, never a horizontal rectangular cut.
			q=(p-center)/eye_aperture_radius;
			float x2=clamp(q.x*q.x,0.0,1.0);
			float arc=sqrt(max(0.0,1.0-x2));
			float cheer=smoothstep(.10,.90,weights.z);
			float seam=mix(.05+.18*(1.0-x2),.12-.38*(1.0-x2),cheer);
			float upper=mix(-arc,seam,closure);
			upper+=weights.w*(eye==0?.32*q.x:-.32*q.x);
			float lower=mix(arc,seam,pow(closure,2.8));
			float side=1.0-smoothstep(.90,1.06,abs(q.x));
			float aperture=smoothstep(upper-.035,upper+.035,q.y)*(1.0-smoothstep(lower-.035,lower+.035,q.y))*side;
			aperture*=smoothstep(0.0,.10,lower-upper);
			vec2 lid_center=eye==0?lids_centers.xy:lids_centers.zw;
			// Retain painted fur coordinates; remove the baked lash before drawing the moving contour.
			vec2 skin_uv=lid_center+q*lids_sample_radius;
			vec3 skin=texture(lids_texture,skin_uv).rgb;
			// Inpaint the complete authored lash band continuously, including its anti-aliased fringe.
			// Pixel luminance thresholds left isolated dark flecks in that fringe.
			vec3 lash=eye==0?lash_left:lash_right;
			float old_lash=lash.x*q.x*q.x+lash.y*q.x+lash.z;
			vec3 upper_fur=texture(lids_texture,lid_center+vec2(q.x,old_lash-.52)*lids_sample_radius).rgb;
			vec3 lower_fur=texture(lids_texture,lid_center+vec2(q.x,old_lash+.52)*lids_sample_radius).rgb;
			vec3 clean_fur=mix(upper_fur,lower_fur,smoothstep(old_lash-.52,old_lash+.52,q.y));
			float lash_band=1.0-smoothstep(.28,.48,abs(q.y-old_lash));
			skin=mix(skin,clean_fur,lash_band);
			if(original_fur_fill){
				skin=silver_fur(p).rgb;

				side=1.0-smoothstep(.76,.94,abs(q.x));
			}
			vec3 eye_color=mix(skin,base.rgb,aperture);
			float rim=1.0-smoothstep(.025,.095,abs(q.y-upper));
			rim*=side*smoothstep(.02,.18,closure);
			eye_color=mix(eye_color,vec3(.09,.035,.02),rim);
			// Remove the complete original outer eyeliner, including its faded
			// corners. This wider horizontal cleanup must not enlarge the eyelid.
			// The donor's side stripes differ from the original portrait. Keep
			// every original fur pixel outside the actual eye socket untouched.
			float replace_eye=(1.0-smoothstep(original_fur_fill?1.02:1.08,original_fur_fill?1.22:1.24,length(q)))*smoothstep(0,.10,closure);
			if(original_fur_fill) replace_eye*=smoothstep(-1.30,-1.02,q.y);
			result=mix(result,eye_color,replace_eye);
			continue;
		}
		// A solid eyeball remains behind the moving lid opening; no frame dissolve.
		vec3 open_eye = base.rgb;
		result = mix(result,open_eye,eye_patch);
		if(closure<=.001) continue;
		float seam = .60-.45*(1.0-clamp(q.x*q.x,0.0,1.0));
		float top = mix(-1.30,seam,closure);
		float bottom = mix(1.30,seam,closure);
		float upper_cover = 1.0-smoothstep(top-.025,top+.025,q.y);
		float lower_cover = smoothstep(bottom-.025,bottom+.025,q.y);
		if(authored_lids){
			// Upper lid does most of the travel; the lower lid joins only near closure.
			seam=.08+.12*clamp(q.x*q.x,0.0,1.0);
			top=mix(-1.18,seam,closure);
			bottom=mix(1.18,seam,pow(closure,3.5));
			upper_cover=1.0-smoothstep(top-.035,top+.035,q.y);
			lower_cover=smoothstep(bottom-.035,bottom+.035,q.y);
		}
		// Preserve the original painted fur coordinates, including tabby stripes.
		vec3 fur = texture(TEXTURE,blink_rect.xy+p*blink_rect.zw).rgb;
		if(authored_lids){
			vec2 lid_center=eye==0?lids_centers.xy:lids_centers.zw;
			// Fixed fur coordinates preserve stripes; the moving aperture reveals the final lash only at closure.
			fur=texture(lids_texture,lid_center+q*lids_sample_radius).rgb;
		}
		float cover = clamp(upper_cover+lower_cover,0.0,1.0)*eye_patch;
		result = mix(result,fur,cover);
	}
	float mouth = 1.0-smoothstep(.7,1.0,length((p-vec2(.43,.49))/vec2(.026,.045)));
	result = mix(result,vec3(.32,.11,.17),mouth*story_meow);
	float alpha=base.a;
	if(ears_only) alpha *= (1.0-smoothstep(.22,.29,p.y))*smoothstep(.15,.23,abs(p.x-.47));
	COLOR = vec4(result, alpha) * item_tint;
}
