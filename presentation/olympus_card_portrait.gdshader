shader_type canvas_item;
render_mode unshaded;
varying vec4 control_tint;

void vertex() {
    control_tint = COLOR;
}

void fragment() {
    vec4 sample_color = texture(TEXTURE, UV);
    float key = step(0.35, min(sample_color.r, sample_color.b) - sample_color.g);
    COLOR = vec4(sample_color.rgb, sample_color.a * (1.0-key)) * control_tint;
}
