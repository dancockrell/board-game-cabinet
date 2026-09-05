shader_type spatial;
render_mode blend_mix, depth_prepass_alpha;
uniform sampler2D symbol_texture : source_color, filter_linear_mipmap;
uniform vec4 char_color : source_color = vec4(0.16, 0.08, 0.035, 1.0);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float grain_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
void fragment() {
    float mark = texture(symbol_texture, UV).a;
    // A narrow heat halo keeps the silhouette crisp at normal playing distance.
    float left = texture(symbol_texture, UV - vec2(0.006, 0.0)).a;
    float right = texture(symbol_texture, UV + vec2(0.006, 0.0)).a;
    float above = texture(symbol_texture, UV - vec2(0.0, 0.006)).a;
    float below = texture(symbol_texture, UV + vec2(0.0, 0.006)).a;
    float edge = max(max(left, right), max(above, below));
    float grain = grain_noise(UV * vec2(92.0, 17.0));
    // The burned floor is rough; its boundary darkens as wood chars under the iron.
    float boundary = clamp(edge - min(min(left, right), min(above, below)), 0.0, 1.0);
    ALBEDO = char_color.rgb * (0.88 + grain * 0.24 - boundary * 0.14);
    ALPHA = clamp(mark * (0.96 + grain * 0.04) + (edge - mark) * (0.22 + grain * 0.12), 0.0, 1.0);
    // A recessed height field perturbs the normal only: no mesh engraving is implied.
    // The normal points into the shallow cavity at each silhouette boundary.
    vec2 slope = vec2(right - left, below - above) * 0.32;
    NORMAL_MAP = normalize(vec3(slope, 1.0)) * 0.5 + 0.5;
    ROUGHNESS = 0.96;
    SPECULAR = 0.08;
}
