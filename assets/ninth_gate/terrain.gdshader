shader_type spatial;
uniform vec4 surface_color : source_color = vec4(0.4, 0.5, 0.3, 1.0);
varying vec3 world_position;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
 vec2 i = floor(p); vec2 f = fract(p); f = f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 float detail = noise(world_position.xz * 65.0);
 float patches = noise(world_position.xz * 3.0);
 ALBEDO = surface_color.rgb * (0.88 + patches * 0.17 + detail * 0.12);
 ROUGHNESS = 0.92;
 SPECULAR = 0.12;
}
