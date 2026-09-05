shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.68,0.62,0.51,1.0);
uniform float metalness = 0.0;
uniform float surface_roughness = 0.88;
uniform float wear_strength = 0.16;
varying vec3 world_position;
varying vec3 object_normal;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; object_normal = NORMAL; }
float hash(vec3 p) { p = fract(p * 0.1031); p += dot(p,p.yzx + 33.33); return fract((p.x+p.y)*p.z); }
float noise(vec3 p) { vec3 i=floor(p); vec3 f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z); }
void fragment() {
    float weather = noise(world_position*2.1)*0.65 + noise(world_position*8.7)*0.35;
    float pores = noise(world_position*38.0);
    float deposit = smoothstep(0.48,0.8,weather);
    vec3 stone = base_color.rgb * (1.0 + (weather-0.5)*wear_strength*2.0);
    stone = mix(stone,stone*vec3(0.76,0.79,0.75),deposit*wear_strength);
    ALBEDO = stone * (0.89+pores*0.045);
    ROUGHNESS = clamp(surface_roughness+(pores-0.5)*0.12,0.2,1.0);
    METALLIC = metalness;
}
