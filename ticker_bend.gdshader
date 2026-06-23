shader_type spatial;

uniform float wheel_angle_deg;   
uniform float clockwise;
uniform float peg_step_deg = 6.0; 
uniform float snap_range_deg = 1.0;
uniform float bend_amount = 0.05;  
uniform float tip_height = 0.22; 

void vertex() {
    float rel = mod(wheel_angle_deg, peg_step_deg);
    float dist_to_peg = min(rel, peg_step_deg - rel);

    float t = clamp(dist_to_peg / snap_range_deg, 0.0, 1.0);

    float bend = (1.0 - t) * bend_amount;

    //assume y=0 at base, y_max at tip tbd
    float curve_factor = clamp(VERTEX.y / tip_height, 0.0, 1.0);
    VERTEX.x += bend * curve_factor * curve_factor * clockwise;
}
