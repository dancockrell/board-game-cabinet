shader_type spatial;
uniform vec4 stone_color : source_color = vec4(0.73, 0.78, 0.64, 1.0);
uniform float block_size = 0.8;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void fragment() {
    vec2 p = world_position.xz / block_size;
    p.x += mod(floor(p.y), 2.0) * 0.5;
    vec2 cell = floor(p);
    vec2 f = fract(p);
    float edge = min(min(f.x, 1.0-f.x), min(f.y, 1.0-f.y));
    float grout = smoothstep(0.012, 0.045, edge);
    float n = hash(cell);
    float grain = hash(floor(world_position.xz * 85.0));
    ALBEDO = stone_color.rgb * (0.90 + n * 0.15 + grain * 0.025) * mix(0.73, 1.0, grout);
    ROUGHNESS = 0.89;
}
