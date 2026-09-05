shader_type spatial;
uniform vec4 stone_color : source_color = vec4(0.64,0.62,0.55,1.0);
uniform float block_size = 0.8;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float noise(vec2 p) { vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y); }
void fragment() {
    vec2 p=world_position.xz/block_size;
    p.x += mod(floor(p.y),2.0)*0.5;
    vec2 cell=floor(p), f=fract(p);
    float edge=min(min(f.x,1.0-f.x),min(f.y,1.0-f.y));
    float wear=noise(world_position.xz*12.0);
    float joint=smoothstep(0.012,0.034+wear*0.012,edge);
    float bevel=smoothstep(0.024,0.065,edge);
    float variation=hash(cell);
    float mineral=noise(world_position.xz*3.2)*0.6+noise(world_position.xz*23.0)*0.4;
    vec3 stone=stone_color.rgb*(0.91+variation*0.17+(mineral-0.5)*0.12);
    vec3 mortar=stone_color.rgb*vec3(0.54,0.55,0.52);
    ALBEDO=mix(mortar,stone*(0.91+bevel*0.09),joint);
    ROUGHNESS=mix(0.98,0.84+mineral*0.1,joint);
    // Small bevel normal is readable without exaggerated black cartoon outlines.
    vec2 slope=vec2(step(f.x,0.5)*2.0-1.0,step(f.y,0.5)*2.0-1.0);
    NORMAL_MAP=vec3(0.5+slope.x*(1.0-bevel)*0.08,0.5+slope.y*(1.0-bevel)*0.08,1.0);
    NORMAL_MAP_DEPTH=0.35;
}
