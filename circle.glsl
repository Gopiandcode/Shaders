float sphereCDF(vec2 samplePoint) {
	return length(samplePoint) -  1.0;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    if(sphereCDF(uv) > 0.0) {

		col = vec3(0.0, 0.0, 0.0);
    }
    
    // Output to screen
    fragColor = vec4(col,1.0);
}
