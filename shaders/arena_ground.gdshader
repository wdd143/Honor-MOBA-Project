shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 grass_dark : source_color = vec3(0.035, 0.12, 0.075);
uniform vec3 grass_light : source_color = vec3(0.16, 0.29, 0.13);
uniform float texture_scale = 95.0;
uniform float roughness_value = 0.92;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float noise2(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	float broad = noise2(UV * 17.0);
	float fine = noise2(UV * texture_scale);
	float flecks = step(0.83, fine) * 0.08;
	float blend_value = clamp(broad * 0.62 + fine * 0.38 + flecks, 0.0, 1.0);
	ALBEDO = mix(grass_dark, grass_light, blend_value);
	ROUGHNESS = roughness_value;
}
