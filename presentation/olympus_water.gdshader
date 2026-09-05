shader_type spatial;
render_mode cull_back;
uniform vec4 deep_color : source_color = vec4(0.025, 0.31, 0.37, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.13, 0.77, 0.77, 1.0);
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    vec2 p = world_position.xz;
    float a = sin(p.x * 6.0 + p.y * 11.0 + sin(p.y * 4.0 + TIME)*1.8 + TIME * 1.5);
    float b = sin(p.x * 8.0 - p.y * 7.0 + cos(p.x*3.0-TIME)*2.0 - TIME * 1.1);
    float caustic = pow(clamp(1.0 - abs(a + b) * 0.9, 0.0, 1.0), 9.0);
    float wave = 0.5 + 0.5 * sin(p.x * 1.7 + p.y * 4.0 + TIME * 0.8);
    ALBEDO = mix(deep_color.rgb, shallow_color.rgb, 0.35 + wave * 0.30) + caustic * vec3(0.10, 0.17, 0.14);
    ROUGHNESS = 0.25;
    METALLIC = 0.25;
    NORMAL_MAP = vec3(0.5 + a * 0.035, 0.5 + b * 0.035, 1.0);
    NORMAL_MAP_DEPTH = 0.4;
}
