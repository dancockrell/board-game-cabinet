shader_type spatial;
uniform vec4 stone_color : source_color = vec4(0.64,0.62,0.55,1.0);
uniform float block_size = 0.8;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float noise(vec2 p) { vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y); }
void fragment() {
    vec2 p=world_position.xz/block_size;
    // Alternate broad and narrow courses, each with its own block length and offset.
    float pair=floor(p.y/1.7), local_y=p.y-pair*1.7;
    float upper=step(0.98,local_y), row=pair*2.0+upper;
    float row_height=mix(0.98,0.72,upper);
    float y=local_y-upper*0.98;
    float width=1.25+hash(vec2(row,4.2))*0.9;
    float x=p.x+hash(vec2(row,7.9))*3.0;
    vec2 cell=vec2(floor(x/width),row);
    float local_x=mod(x,width);
    float edge=min(min(local_x,width-local_x),min(y,row_height-y));
    // A few paired blocks avoid a mathematically perfect running-bond repeat.
    float split=step(0.77,hash(cell+17.0));
    edge=min(edge,mix(10.0,abs(local_x-width*0.43),split));
    float aa=max(fwidth(edge)*0.65,0.0015);
    float joint=smoothstep(0.004-aa,0.009+aa,edge);
    float variation=hash(cell);
    float mineral=noise(world_position.xz*3.2)*0.6+noise(world_position.xz*23.0)*0.4;
    vec3 stone=stone_color.rgb*(0.95+variation*0.09+(mineral-0.5)*0.10);
    vec3 mortar=stone_color.rgb*vec3(0.77,0.78,0.75);
    // Sparse, eroded hairlines: low contrast and broken by mineral deposits.
    float crack=abs(noise(world_position.xz*5.3+cell)-0.5);
    float wear=(1.0-smoothstep(0.002,0.009,crack))*step(0.88,variation)*0.045;
    ALBEDO=mix(mortar,stone,joint)*(1.0-wear);
    ROUGHNESS=mix(0.97,0.87+mineral*0.08,joint);
}
