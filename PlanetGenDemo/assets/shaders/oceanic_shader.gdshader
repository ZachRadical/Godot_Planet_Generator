shader_type spatial;

uniform float animation_speed = 0.1;
uniform float height_multiplier = 0.5;
uniform float noise_scale = 0.1;
uniform sampler3D wave_noise1;
uniform sampler3D wave_noise2;
uniform vec2 wave_direction1 = vec2(1.0,-1.0);
uniform vec2 wave_direction2 = vec2(-1.0,1.0);
uniform sampler2D surface_colors;
varying float surface_height;
uniform float min_height = 0.2;
void vertex() {
	float height = texture(wave_noise1, VERTEX * noise_scale + vec3(TIME) * animation_speed).r;
	float height2 = texture(wave_noise2, VERTEX * noise_scale - vec3(TIME) * animation_speed).r;
	VERTEX += (VERTEX * max(min_height,height) * height_multiplier);

	//VERTEX += mix((VERTEX * max(min_height,height) * height_multiplier), (VERTEX * max(min_height,height2) * height_multiplier), 0.5);
	surface_height = length(VERTEX);
}

void fragment() {
	vec2 time = (TIME * wave_direction1) * animation_speed;
	vec2 time2 = (TIME * wave_direction2) * animation_speed;
	float t = surface_height;
	//vec3 normal_blend = mix(texture(wave_direction1, UV + time).rgb, texture(wave_direction2, UV + time2).rgb, 0.5);
	vec3 color = texture(surface_colors, vec2(t,0.0)).rgb;
	ALBEDO = color;
}
