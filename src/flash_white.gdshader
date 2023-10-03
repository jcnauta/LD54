shader_type canvas_item;

uniform float saturation: hint_range(0, 1) = 0;
uniform vec3 tint = vec3(1, 1, 1);

vec3 interpolate_vec3(vec3 start, vec3 end, float delta){
    return start + (end - start) * delta;
}

void fragment(){
    vec4 origin = texture(TEXTURE, UV);
    COLOR.rgb = interpolate_vec3(origin.rgb, tint, saturation);
    COLOR.a = origin.a;
}