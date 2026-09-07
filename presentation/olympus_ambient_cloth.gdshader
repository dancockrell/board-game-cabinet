shader_type spatial;
render_mode cull_disabled;
uniform vec4 cloth_color : source_color = vec4(1.0);
uniform float motion_clock = 0.0;
uniform float phase = 0.0;
uniform float width = 0.43;
void vertex() {
	// Fixed mast edge, increasingly loose fabric toward the free edge.
	float loose = clamp(abs(VERTEX.x) / width, 0.0, 1.0);
	VERTEX.z += loose * (sin(motion_clock * 3.1 - loose * 4.0 + phase) * 0.075
		+ sin(motion_clock * 5.4 + loose * 7.0 + phase) * 0.018);
}
void fragment() {
	ALBEDO = cloth_color.rgb;
	ROUGHNESS = 0.9;
}
