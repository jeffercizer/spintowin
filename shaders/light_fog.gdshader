shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, unshaded;

uniform vec4 fog_color : source_color = vec4(1.0, 1.0, 1.0, 0.4);
uniform float density = 1.0;
uniform float edge_softness = 2.0;
uniform float noise_strength = 0.2;
uniform sampler2D noise_tex;

void fragment() {
        // Distance from light along cone (0 at light, 1 at tip if UV mapped that way)
    float t = UV.y;

    // Radial falloff (assuming UV.x is radial from center)
    float r = abs(UV.x - 0.5) * 2.0;
    float radial_falloff = pow(1.0 - clamp(r, 0.0, 1.0), edge_softness);
    
    // Depth-based fade (closer to camera = stronger, farther = weaker)
    float depth = length(VERTEX);
    float depth_fade = exp(-density * depth);

    // Simple noise modulation
    float n = texture(noise_tex, UV * 4.0).r;
    float noise = mix(1.0, n, noise_strength);

    float alpha = radial_falloff * noise * fog_color.a; 
    
    if (alpha <= 0.01) {
        discard;
    }

    ALBEDO = fog_color.rgb;
    ALPHA = alpha;
}
