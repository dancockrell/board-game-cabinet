shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D source_atlas : source_color, filter_nearest, repeat_disable;
uniform vec4 cutout = vec4(0.0);
void vertex() {
    vec3 s = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * s.x, INV_VIEW_MATRIX[1] * s.y, INV_VIEW_MATRIX[2] * s.z, MODEL_MATRIX[3]);
}
void fragment() {
    vec4 color = texture(source_atlas, UV);
    // Only strongly saturated magenta, never pale stone or neutral highlights.
    float key = step(0.35, min(color.r, color.b) - color.g);
    if (cutout.z > 0.0 && cutout.w > 0.0 && all(greaterThanEqual(UV,cutout.xy)) && all(lessThan(UV,cutout.xy+cutout.zw))) key=1.0;
    ALBEDO = color.rgb;
    ALPHA = color.a * (1.0 - key);
    ALPHA_SCISSOR_THRESHOLD = 0.5;
}
