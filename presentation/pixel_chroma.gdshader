shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D source_atlas : source_color, filter_nearest, repeat_disable;
uniform vec4 cutout = vec4(0.0);
void vertex() {
    vec3 s = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * s.x, INV_VIEW_MATRIX[1] * s.y, INV_VIEW_MATRIX[2] * s.z, MODEL_MATRIX[3]);
}
vec4 keyed_sample(vec2 uv) {
    vec4 color = texture(source_atlas, uv);
    // Only strongly saturated magenta, never pale stone or neutral highlights.
    float key = step(0.35, min(color.r, color.b) - color.g);
    if (cutout.z > 0.0 && cutout.w > 0.0 && all(greaterThanEqual(uv,cutout.xy)) && all(lessThan(uv,cutout.xy+cutout.zw))) key=1.0;
    float alpha=color.a*(1.0-key);
    return vec4(color.rgb*alpha,alpha);
}
void fragment() {
    // Filter only after key removal. Ordinary source mipmaps blend magenta into
    // the silhouette; raw nearest sampling shimmers at normal arena distance.
    vec2 dx=dFdx(UV), dy=dFdy(UV);
    vec4 sum=vec4(0.0);
    for(int y=0;y<4;y++) {
        for(int x=0;x<4;x++) {
            sum+=keyed_sample(UV+dx*((float(x)+0.5)/4.0-0.5)+dy*((float(y)+0.5)/4.0-0.5));
        }
    }
    ALBEDO = sum.rgb/max(sum.a,0.0001);
    ALPHA = sum.a/16.0;
    ALPHA_SCISSOR_THRESHOLD = 0.5;
}
