shader_type spatial;
render_mode unshaded, depth_test_disabled;

varying vec3 cam_position;

uniform float sphere_radius;
varying vec3 sphere_position;
uniform vec4 color : source_color;
uniform float color_multiplier;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform float softness = 0.5;
uniform vec3 light_direction;
uniform float light_intensity = 1.0;
uniform vec4 light_colour : source_color = vec4(1.0,1.0,0.9,1.0);
uniform float light_sharpness = 1.0;

vec3 raySphereIntersectBasic(vec3 ro, vec3 rd, vec3 so, float sr, vec3 sun, float max_depth) {
    // ro: ray origin
    // rd: normalized ray direction
    // so: origin of sphere
    // sr: radius of sphere
    float t = dot(so-ro, rd); // the distance along rd that we're closest to the centre of the sphere
	vec3 P = ro + rd*t; // 3d position of t
	float y = length(so - P); // distance between p and the sphere origin
	
	if (y > sr){ // if distance to centre is larger than radius then the ray doesn't hit the sphere at all
		return vec3(-1.0);
	}
	
	float x = sqrt(sr*sr - y*y); // distance between p and the first intersection with the sphere
	float t1 = max(t-x, 0.0); // distance of first intersection, prevent negative values when inside the sphere
	float t2 = min(t+x, max_depth); // distance of second intersection
	//float t2 = t+x;
	
	vec3 p0 = ro + rd*max(min(t, t2), 0.0); // t2 unles we miss the planet then use t, clamped to 0.0
	vec3 n0 = so - p0; // vector from centre of sphere to p2 (surface normal)
	float nd0 = (dot(sun, normalize(n0)) + 1.0) / 2.0; // dot (similarity) between light vector and n2, 0..1
	
	float nd4 = (dot(sun, rd) + 1.0) / 2.0;
	
	return vec3(t1, t2, nd0);
}


void fragment() {	
	vec3 cam = cam_position;
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float max_depth = length(view.xyz);
	vec3 sun = (vec4(normalize(light_direction.xyz), 1.0) * INV_VIEW_MATRIX).xyz;
	vec3 so = -(vec4(sphere_position, 1.0) * INV_VIEW_MATRIX).xyz;
	vec3 rsi = raySphereIntersectBasic(cam, normalize(VIEW), so, sphere_radius, sun, max_depth);
	float thickness = (rsi.y - rsi.x) / softness;
	ALPHA = clamp(thickness/sphere_radius, 0.0, 1.0) * pow(max(rsi.z, 0.0), 1.0);
	ALBEDO = color.xyz * color_multiplier + pow(rsi.z, light_sharpness)*light_intensity*light_colour.xyz;
}

void vertex(){
	cam_position = MODELVIEW_MATRIX[3].xyz;
}
