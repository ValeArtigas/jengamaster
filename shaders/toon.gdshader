shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_back;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3 emission_color : source_color = vec3(0.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 0.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.85;
uniform float rim_amount : hint_range(0.0, 2.0) = 0.35;

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness_value;
	METALLIC = 0.0;
	EMISSION = emission_color * emission_strength;
	float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.5);
	EMISSION += albedo.rgb * rim * rim_amount;
}
