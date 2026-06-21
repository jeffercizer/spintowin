shader_type spatial;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
    if (UV.x > progress) {
        discard;
    }
    ALBEDO = vec3(0.95, 0.855, 0.0);
}
