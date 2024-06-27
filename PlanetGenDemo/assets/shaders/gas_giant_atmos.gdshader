shader_type spatial;
render_mode cull_disabled;
uniform sampler2D texture : source_color;
uniform sampler2D flowmap;
uniform float speed = 0.1;
uniform float magnitude = 0.1;
void fragment() {
	
	vec2 flow = texture(flowmap, UV).xy;
	flow = (flow - 0.5) * 2.0;
	float time1 = fract(TIME *speed);
	float time2 = fract(time1 + 0.5);
	float flow_mix = abs((time1 - 0.5) * 2.0);
	
	vec3 tex1 = texture(texture, UV + (flow * time1 * magnitude)).xyz;
	vec3 tex2 = texture(texture, UV + (flow * time2 * magnitude)).xyz;
	
	vec3 final_tex = mix(tex1, tex2, flow_mix);
	
	ALBEDO = final_tex;
	// Place fragment code here.
}
