shader_type spatial;

//hsv to rgb converter
vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0,4,2), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    //use hsv to make an easy rainbow
    float hue = fract(UV.x + TIME * 0.1);
    vec3 col = hsv2rgb(vec3(hue, 1.0, 1.0));
    ALBEDO = col;
}
