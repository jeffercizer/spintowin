shader_type spatial;

uniform vec3 tint_color : source_color = vec3(0.4, 0.4, 0.4);
uniform float noise_strength = 0.15;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Base dull color
    vec3 col = tint_color * 0.8;

    // Subtle static noise
    float n = hash(uv * 40.0);
    col += (n - 0.5) * noise_strength;

    ALBEDO = col;
}
