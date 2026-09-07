shader_type spatial;
uniform sampler2D paving : source_color, filter_nearest_mipmap, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0);
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    // One complete authored patch per half-field; no unverified texture seams.
    vec2 patch = vec2((world_position.x + 5.125) / 10.25, (abs(world_position.z) - 0.8) / 7.5);
    vec3 stone = texture(paving, clamp(patch, vec2(0.001), vec2(0.999))).rgb;
    ALBEDO = stone * tint.rgb;
    ROUGHNESS = 1.0;
}
