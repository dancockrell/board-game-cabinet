shader_type spatial;
render_mode cull_back;
uniform vec4 deep_color : source_color = vec4(0.012,0.048,0.064,1.0);
uniform vec4 shallow_color : source_color = vec4(0.035,0.13,0.14,1.0);
uniform float caustic_strength = 0.08;
varying vec3 world_position;
void vertex() { world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec2 p) { p=fract(p*vec2(123.34,456.21)); p+=dot(p,p+45.32); return fract(p.x*p.y); }
float noise(vec2 p) { vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y); }
float ripples(vec2 p) { return noise(p*2.4+vec2(TIME*0.075,-TIME*0.05))*0.55+noise(p*6.7+vec2(-TIME*0.04,TIME*0.08))*0.30+noise(p*11.1+vec2(TIME*0.03,TIME*0.05))*0.15; }
void fragment() {
    vec2 p=world_position.xz;
    float swell=noise(p*0.36+vec2(TIME*0.022,0));
    float r=ripples(p);
    float dx=ripples(p+vec2(0.04,0))-r;
    float dy=ripples(p+vec2(0,0.04))-r;
    float caustic=pow(smoothstep(0.48,0.85,r),4.0);
    ALBEDO=mix(deep_color.rgb,shallow_color.rgb,0.18+swell*0.25)+caustic*caustic_strength*vec3(0.045,0.055,0.05);
    ROUGHNESS=0.39;
    METALLIC=0.0;
    SPECULAR=0.30;
    NORMAL_MAP=vec3(0.5+dx*0.40,0.5+dy*0.40,1.0);
    NORMAL_MAP_DEPTH=0.35;
}
