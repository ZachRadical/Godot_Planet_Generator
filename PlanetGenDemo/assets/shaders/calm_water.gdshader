shader_type spatial;
#include "include/Math.gdshaderinc"
#include "include/Triplanar.gdshaderinc"
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec3 albedo : source_color;
uniform vec3 albedo_fresnel : source_color;
uniform float fresnel_range : hint_range(0.0,5.0);
uniform vec3 wave_direction1 = vec3(2.0,0.0,0.0);
uniform vec3 wave_direction2 = vec3(0.0,1.0,0.0);
uniform float time_scale : hint_range(0.0,0.2,0.005);
uniform float metallic;
uniform float roughness;

uniform sampler2D normal_map1;
uniform sampler2D normal_map2;


varying vec4 n1;
varying vec4 n2;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}




vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float depth_distance(sampler2D tex, vec2 uv, mat4 inv_projection_matrix) {
	// Get depth value from DEPTH_TEXTURE
	float depth = texture(tex, uv).r;

	// Normalized Device Coordinates needs to be 0 to 1 in Z axis for Vulkan
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	
	// Convert between NDC and view space to get distance to camera
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;

	//return view.xyz; 
	return -view.z;
}
void fragment() {

	vec3 time1 = (TIME * wave_direction1) * time_scale/2.0;
	vec3 time2 = (TIME * wave_direction2) * time_scale/2.0;
	
	vec4 normal_map = triplanar_texture(normal_map1,uv1_power_normal,uv1_triplanar_pos + time1);
	vec4 other_normal_map = triplanar_texture(normal_map2,uv1_power_normal,uv1_triplanar_pos + time2);
	vec3 final_normal = mix(normal_map, other_normal_map, 0.5).xyz;
	
	float fresnel = fresnel(fresnel_range, NORMAL, VIEW);
	
	vec3 fresnel_color = mix(albedo, albedo_fresnel, fresnel);
	//vec3 foam_color = mix(edge_color, color, step(edge_scale, z_dif));
	//vec3 final_color = clamp(fresnel_color + foam_color, vec3(0.0), vec3(1.0));
	ALBEDO = fresnel_color; //final_color
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = final_normal;
}