shader_type spatial;
render_mode fog_disabled;

uniform float roughness;
uniform vec3 light_direction;
uniform vec3 diffuse_color;
uniform vec3 specular_color;
uniform sampler2D albedoTexture;

varying vec3 normal;
varying vec3 vert;
void vertex() {
	vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 vertex_to_eye = normalize(CAMERA_POSITION_WORLD - vert);
	vec3 half_vec = normalize(vertex_to_eye + light_direction);

	float tan2nh = -pow(tan(acos(dot(normal, half_vec))), 2);
	float rms2 = pow(roughness, 2);
	float den = 6.28 * rms2;

	float first_term = exp(tan2nh / rms2) / den;

	float costheta = dot(normal, light_direction);
	float cosdelta = dot(normal, vertex_to_eye);

	float second_term = 1.f / sqrt(costheta * cosdelta);

	vec3 irradiance = vec3(max(0.f, costheta));

	vec3 specular_term = specular_color * first_term * second_term;
	vec3 final_color = irradiance * (texture(albedoTexture, UV).xyz + specular_term);

	ALBEDO = final_color;
}