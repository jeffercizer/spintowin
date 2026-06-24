shader_type spatial;

uniform float wheel_angle_deg;   
uniform float clockwise;
uniform float peg_step_deg;
uniform float snap_range_deg;
uniform float bend_amount;
uniform float tip_height;

void vertex() {
    float angle_in_seg = mod(wheel_angle_deg, peg_step_deg);
    float dist_to_peg = min(angle_in_seg, peg_step_deg - angle_in_seg);

    float t = clamp(dist_to_peg / snap_range_deg, 0.0, 1.0);

    float bend = (1.0 - t) * bend_amount;
    
    float curve_factor = clamp(VERTEX.y / tip_height, 0.0, 1.0);
    VERTEX.x += bend * curve_factor * curve_factor * clockwise;
}

void fragment(){
    ALBEDO = vec3(1.0,1.0,0.0);
}
