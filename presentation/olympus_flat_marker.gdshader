shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;
uniform vec4 ink : source_color = vec4(0.3,0.6,0.8,1.0);
void fragment() {
	if (distance(UV,vec2(0.5))>0.5) discard;
	ALBEDO = ink.rgb;
	ALPHA = ink.a;
}
