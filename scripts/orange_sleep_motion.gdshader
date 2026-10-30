shader_type canvas_item;
uniform vec4 artwork_region;
uniform float clock=0.0;
uniform float amount=1.0;
uniform float yawning=0.0;
void vertex(){
	vec2 p=(UV-artwork_region.xy)/artwork_region.zw;
	float h=artwork_region.w/TEXTURE_PIXEL_SIZE.y;
	float w=artwork_region.z/TEXTURE_PIXEL_SIZE.x;
	float breath=sin(clock*1.45);
	float torso=smoothstep(.50,.68,p.y)*(1.0-smoothstep(.84,.95,p.y));
	VERTEX.x+=(p.x-.46)*w*.018*breath*torso*amount;
	VERTEX.y-=h*.008*breath*torso*amount;
	float head=1.0-smoothstep(.48,.65,p.y);
	vec2 v=(p-vec2(.46,.64))*vec2(w,h);
	float angle=.018*sin(clock*.65)*head*amount;
	VERTEX+=vec2(-v.y,v.x)*angle;
	VERTEX.y+=h*.010*(.5+.5*sin(clock*.65))*head*amount;
	for(int side=0;side<2;side++){
		float ear=(1.0-smoothstep(.13,.27,p.y))*(side==0 ? 1.0-smoothstep(.27,.40,p.x) : smoothstep(.61,.73,p.x));
		float t=mod(clock+(side==0?0.0:2.7),7.6);
		float flick=t<1.2?sin(t*6.283185/1.2)*pow(sin(t*3.14159265/1.2),2.0):0.0;
		VERTEX.x+=h*.012*flick*ear*amount;
		VERTEX.y+=h*.008*flick*ear*amount;
	}
	float tail=smoothstep(.75,.87,p.x)*smoothstep(.47,.68,p.y)*(1.0-smoothstep(.93,1.0,p.y));
	VERTEX.x+=h*.022*sin(clock*.85)*tail*amount;
	VERTEX.y+=h*.009*(cos(clock*.85)-1.0)*tail*amount;
	float jaw=exp(-pow((p.x-.46)/.11,2.0))*smoothstep(.43,.50,p.y)*(1.0-smoothstep(.60,.67,p.y));
	VERTEX.y+=h*.018*sin(clock*2.0)*jaw*yawning*amount;
}
