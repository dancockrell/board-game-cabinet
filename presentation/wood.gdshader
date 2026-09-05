shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 wood_color : source_color = vec4(0.6, 0.4, 0.2, 1.0);
uniform float grain_seed = 0.0;
uniform float grain_strength = 0.13;
varying vec3 local_pos;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1,0)), f.x), mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), f.x), f.y);
}
void vertex() { local_pos = VERTEX; }
void fragment() {
    vec2 p = local_pos.xz + vec2(grain_seed, grain_seed * 0.71);
    float bend = noise(p * vec2(1.7, 0.32));
    float grain = noise(vec2(p.x * 115.0 + bend * 9.0, p.y * 2.7));
    float broad = noise(p * vec2(10.0, 0.7));
    float pores = pow(noise(p * vec2(290.0, 30.0)), 5.0);
    float v = (grain - 0.5) * grain_strength + (broad - 0.5) * 0.11 - pores * 0.1;
    ALBEDO = wood_color.rgb * (0.9 + v);
    ROUGHNESS = 0.45 + grain * 0.21;
    SPECULAR = 0.27;
}
