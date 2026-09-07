shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D source_atlas : source_color, filter_nearest, repeat_disable;
uniform float animation_time = 0.0;
uniform float phase = 0.0;
uniform float foliage_top = 0.04;
uniform float foliage_bottom = 0.65;
uniform float sway = 0.006;
void vertex() {
    vec3 s = vec3(length(MODEL_MATRIX[0].xyz),length(MODEL_MATRIX[1].xyz),length(MODEL_MATRIX[2].xyz));
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*s.x,INV_VIEW_MATRIX[1]*s.y,INV_VIEW_MATRIX[2]*s.z,MODEL_MATRIX[3]);
}
vec4 sample_foliage(vec2 uv) {
    // Bend leaves only. The planter and foot anchor remain completely still.
    float weight = smoothstep(0.0,1.0,clamp((foliage_bottom-uv.y)/(foliage_bottom-foliage_top),0.0,1.0));
    uv.x += weight*sway*(sin(animation_time*1.3+phase)+0.22*sin(animation_time*2.7+phase+uv.y*18.0));
    vec4 c = texture(source_atlas,uv);
    float backing = smoothstep(0.06,0.22,min(c.r,c.b)-c.g);
    // Remove residual magenta spill from fine leaf-edge antialiasing.
    if(min(c.r,c.b)>c.g+0.015) c.rgb=vec3(min(c.r,c.g),c.g,min(c.b,c.g));
    float a = c.a*(1.0-backing);
    return vec4(c.rgb*a,a);
}
void fragment() {
    vec2 dx=dFdx(UV),dy=dFdy(UV);
    vec4 sum=vec4(0.0);
    for(int y=0;y<4;y++) {
        for(int x=0;x<4;x++) {
            sum+=sample_foliage(UV+dx*((float(x)+0.5)/4.0-0.5)+dy*((float(y)+0.5)/4.0-0.5));
        }
    }
    ALBEDO=sum.rgb/max(sum.a,0.0001);
    ALPHA=sum.a/16.0;
    ALPHA_SCISSOR_THRESHOLD=0.5;
}
