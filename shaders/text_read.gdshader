shader_type spatial;

uniform sampler2D albedo_tex : source_color;

void fragment() {
    ALBEDO = texture(albedo_tex, UV).rgb;
}
