shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;
uniform sampler2D art : source_color, filter_nearest;
uniform float animation_time = 0.0;
uniform bool sea_only = false;

void vertex() {
	vec3 s = vec3(length(MODEL_MATRIX[0].xyz),length(MODEL_MATRIX[1].xyz),length(MODEL_MATRIX[2].xyz));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*s.x,INV_VIEW_MATRIX[1]*s.y,INV_VIEW_MATRIX[2]*s.z,MODEL_MATRIX[3]);
}

bool sea(vec3 c) { return c.b > c.r*1.3 && c.g > c.r*1.3 && c.b > 0.14; }

void fragment() {
	vec2 pixels = vec2(textureSize(art,0));
	vec2 art_uv = sea_only ? vec2(fract(UV.x*24.0)*0.1,fract(UV.y*3.0)) : UV;
	vec4 original = texture(art,art_uv);
	vec2 sample_uv = art_uv;
	float clock = floor(animation_time*8.0)/8.0;
	if (sea(original.rgb)) {
		sample_uv.x += floor(sin(UV.y*pixels.y*0.065+clock*1.4)*2.0)/pixels.x;
		vec4 shifted = texture(art,sample_uv);
		if (sea(shifted.rgb)) original = shifted;
	} else if (original.g > original.r*1.12 && original.b < original.g*0.8) {
		// Leaf colors move by one image pixel; masonry, pots and paths stay fixed.
		sample_uv.x += floor(sin(clock*2.0+UV.y*41.0))/pixels.x;
		vec4 shifted = texture(art,sample_uv);
		if (shifted.g > shifted.r*1.12 && shifted.b < shifted.g*0.8) original = shifted;
	}
	ALBEDO = original.rgb;
	ALPHA = original.a;
}
