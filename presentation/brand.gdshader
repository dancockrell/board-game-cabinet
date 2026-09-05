shader_type spatial;
render_mode blend_mix, depth_prepass_alpha;
uniform sampler2D symbol_texture : source_color, filter_linear_mipmap;
uniform vec4 char_color : source_color = vec4(0.16, 0.08, 0.035, 1.0);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void fragment() {
    float mark = texture(symbol_texture, UV).a;
    float edge = max(max(texture(symbol_texture, UV + vec2(0.005, 0.0)).a,
                         texture(symbol_texture, UV - vec2(0.005, 0.0)).a),
                     max(texture(symbol_texture, UV + vec2(0.0, 0.005)).a,
                         texture(symbol_texture, UV - vec2(0.0, 0.005)).a));
    float grain = hash(floor(UV * vec2(190.0, 56.0)));
    ALBEDO = char_color.rgb * (0.82 + grain * 0.30);
    ALPHA = clamp(mark * (0.94 + grain * 0.06) + (edge - mark) * 0.25, 0.0, 1.0);
    ROUGHNESS = 0.96;
    SPECULAR = 0.08;
}
