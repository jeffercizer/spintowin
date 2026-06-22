shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_tex : source_color;
uniform vec3 noise_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float strength : hint_range(-1.0, 1.0) = 0.0;
uniform float noise_scale = 4.0;
uniform float noise_amount = 0.25;
uniform float blank_threshold = 0.05; // how "empty" the texture must be

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
    vec4 tex = texture(albedo_tex, UV);

    //detect transperancy
    bool is_blank = tex.a < blank_threshold || length(tex.rgb) < blank_threshold;

    if (is_blank) {
        float n = noise(UV * noise_scale);
        float brightness = strength + (n - 0.5) * noise_amount;

        vec3 col = noise_color * (1.0 + brightness);
        ALBEDO = col;
    } else {
        ALBEDO = tex.rgb;
    }
}
