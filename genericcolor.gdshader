shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float strength : hint_range(-1.0, 1.0) = 0.0; // darken/lighten
uniform float noise_scale = 4.0;
uniform float noise_amount = 0.25;

// Simple 2D hash noise (Compatibility-safe)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

void fragment() {
    // Start with the parameter color
    vec3 col = base_color;

    // Noise based on UV
    float n = noise(UV * noise_scale);

    // Combine your parameter + noise
    float brightness = strength + (n - 0.5) * noise_amount;

    // Apply brightness
    col *= (1.0 + brightness);

    ALBEDO = col;
}
