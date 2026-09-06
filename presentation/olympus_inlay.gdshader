shader_type spatial;
render_mode cull_disabled;
uniform sampler2D inlay : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 stone_tint : source_color = vec4(0.78,0.75,0.67,1.0);
void fragment() {
    // Preserve original bitmap. Crop/mask only at rendering time.
    if (length(UV - vec2(0.5)) > 0.5) { discard; }
    vec3 source = texture(inlay, UV * 0.86 + vec2(0.07)).rgb;
    ALBEDO = source * stone_tint.rgb;
    ROUGHNESS = 0.92;
}
