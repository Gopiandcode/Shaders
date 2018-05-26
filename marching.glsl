#define MAX_MARCHING_DISTANCE_STEPS 266
#define EPSILON 0.0001
#define MAX_DISTANCE 100.0
#define MIN_DISTANCE 0.0

float sphereCDF(vec3 samplePoint) {
	return length(samplePoint) -  1.0;
}

float mainCDF(vec3 samplePoint) {
    return sphereCDF(samplePoint);
}

float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection,
                                float minDistance, float maxDistance) {
 	float depth = minDistance;
    
    for(int i = 0; i < MAX_MARCHING_DISTANCE_STEPS; i++) {
   		float dist = mainCDF(eye + marchingDirection * depth);
        if(dist < EPSILON) {
			return depth;
        }
        depth += dist;
        if(depth >= maxDistance) {
			return maxDistance;
        }
    }
    return depth;
    
}

vec3 rayDirection(float fov, vec2 size, vec2 fragCoord) {
	// centers fragCoord between -size/2 and size/2
    vec2 xy = fragCoord - size/2.0;
    
    float z = size.y / tan(radians(fov) / 2.0);
    return normalize(vec3(xy, -z));
}


// estimates the gradient of a function
// using a sampling of points on either side of
// the point
vec3 estimateNormal(vec3 p) {
	return normalize(vec3(
    	mainCDF(vec3(p.x + EPSILON, p.y, p.z)) -
        mainCDF(vec3(p.x - EPSILON, p.y, p.z)),
        
        mainCDF(vec3(p.x, p.y + EPSILON, p.z)) -
        mainCDF(vec3(p.x, p.y - EPSILON, p.z)),
        
        mainCDF(vec3(p.x, p.y, p.z + EPSILON)) -
        mainCDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	vec3 dir = rayDirection(45.0, iResolution.xy, fragCoord);
    vec3 eye = vec3(0.0, 0.0, 5.0);
    
    float dist = shortestDistanceToSurface(eye, dir, MIN_DISTANCE, MAX_DISTANCE);
  
    
    if(dist > MAX_DISTANCE - EPSILON) {
		fragColor = vec4(0.0,0.0,0.0,0.0);
        return;
    }
    
  
    vec3 position = eye + dir * dist;
    vec3 normal = estimateNormal(position);
    vec3 lightSource = vec3(iMouse.xy, 0.1);
    float specular_const = 0.3;
    float diffuse_const = 0.01;
    float ambient_const = 0.1;
    float alpha_const = 0.1;
    
    vec3 reflection = reflect(lightSource, normal);
    float diffuse = alpha_const * max(0.0f, dot(normal, -lightSource));
    float specular = pow(max(0.0, dot(reflection, -(eye + dir * dist))), specular_const);
    
                        
    
    fragColor = vec4(vec3(ambient_const) + specular *  vec3(0.5, 0.0, 0.0) + diffuse * vec3(0.8, 0.7, 0.6),1.0);
}
