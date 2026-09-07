shader_type canvas_item;
// Preview only: reject saturated magenta, preserve ivory/skin/bronze.
void fragment() {
 vec4 c = texture(TEXTURE, UV);
 float excess = min(c.r,c.b)-c.g;
 if (excess > 0.32 && min(c.r,c.b)>0.5) c.a=0.0;
 COLOR=c;
}
