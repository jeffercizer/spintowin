shader_type spatial;//simple spiral shader

uniform int segments = 16;
uniform int shear = 1;

mat2 rotate2D(float r) {
    return mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}


void fragment( )
{
    
	vec2 cuv = (UV-.5)*2.0;
//	cuv /= TIME / 8.0;
	float ang = atan(cuv.y,cuv.x)*float(segments)/(2.*TAU);
	float lograd = log(length(cuv))-float(shear)*atan(cuv.y, cuv.x)/TAU;
	float u = ang;
	float v = 4.0*lograd;
	
	vec2 finalUv = vec2(u + TIME,v+TIME);
	
    vec2 uv = finalUv;
    vec3 col = vec3(0);
    float t = TIME;
    
    vec2 n = vec2(0),q;
    vec2 N = vec2(0);
    vec2 p = uv;
    float S = 10.0;
    mat2 m = rotate2D(1.0);

    for(float j=0.;j++<12.;){
      p*=m;
      n*=m ;
      q=p*S+j+n+t;
      n+=sin(q*1.1);
      N+=cos(q*0.90)/S;
      S*=1.1;
      
    }
    
    col = vec3(7, 4,1) * pow((N.x + N.y + 0.2)+.005/length(N), 2.1);
	
	col *= clamp(distance(UV, vec2(0.5)) * 10.0 - 0.85, 0.0, 1.0);
	
	ALBEDO = col;
}