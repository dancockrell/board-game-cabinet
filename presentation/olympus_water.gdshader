shader_type spatial;
render_mode unshaded, cull_back;
uniform vec4 deep_color : source_color = vec4(0.027,0.10,0.14,1.0);
uniform vec4 shallow_color : source_color = vec4(0.078,0.21,0.23,1.0);
uniform vec4 foam_color : source_color = vec4(0.39,0.62,0.61,1.0);
uniform float animation_time = 0.0;
uniform float caustic_strength = 0.13;
uniform bool river = false;
uniform bool waterfall = false;
varying vec3 world_position;
void vertex() { world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec2 p) { p=fract(p*vec2(123.34,456.21)); p+=dot(p,p+45.32); return fract(p.x*p.y); }
float noise(vec2 p) { vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y); }
void fragment() {
    // Fixed world-sized pixel clusters; moving phases do not move the geometry.
    vec2 p = floor(world_position.xz * 18.0) / 18.0;
    float t = floor(animation_time * 18.0) / 18.0;
    float drift = river ? 0.65 : 0.25;
    vec2 flow = p + vec2(-t * drift, t * 0.07);
    float body = noise(flow * vec2(0.6, 1.6));
    float bands = sin(flow.y * 17.0 + sin(flow.x * 2.0) * 1.5);
    float broken = noise(flow * vec2(3.2, 8.0));
    float glints = step(0.80, bands) * step(0.53, broken);
    float foam = 0.0;
    if (river) {
        float bank = smoothstep(0.56, 0.74, abs(p.y));
        foam = bank * step(0.40, noise(flow * vec2(5.0, 2.0))) * 0.6;
    } else {
        // A restrained wash laps around the rectangular island foot.
        vec2 edge = abs(p) - vec2(6.0, 9.35);
        float shore = length(max(edge, vec2(0.0)));
        float wash = 0.12 + 0.18 * (0.5 + 0.5 * sin(t * 1.4 + p.x * 0.4));
        foam = (1.0 - smoothstep(wash, wash + 0.13, shore)) * step(0.40, broken) * 0.48;
    }
    if (waterfall) {
        // Falls use height, not the horizontal surface projection.
        vec2 fall_p = floor(vec2(world_position.z, world_position.y) * 22.0) / 22.0;
        float streak = noise(vec2(fall_p.x * 12.0, (fall_p.y + t * 1.7) * 5.0));
        body = floor(streak * 4.0) / 3.0;
        glints = step(0.66, streak);
        foam = (1.0 - smoothstep(-0.72, -0.54, world_position.y)) * 0.55;
    }
    vec3 water = mix(deep_color.rgb, shallow_color.rgb, 0.18 + floor(body * 4.0) * 0.22);
    water = mix(water, foam_color.rgb, glints * (waterfall ? 0.40 : caustic_strength));
    ALBEDO = mix(water, foam_color.rgb, foam);
    ROUGHNESS = 0.85;
}
