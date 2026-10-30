shader_type canvas_item;
render_mode unshaded;
uniform vec4 ink:source_color=vec4(1.0,0.95,0.80,1.0);
void fragment(){COLOR=vec4(ink.rgb,texture(TEXTURE,UV).a*ink.a);}
