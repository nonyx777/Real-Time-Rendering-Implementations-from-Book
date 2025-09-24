shader_type spatial;
//render_mode unshaded;

uniform float roughness_1;
uniform float roughness_2;
uniform vec3 light_direction;
uniform vec3 diffuse_color;
uniform vec3 specular_color;
uniform sampler2D albedo_texture;

varying vec3 vert;
varying vec3 normal;
void vertex() {
	vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 vertex_to_eye = normalize(CAMERA_POSITION_WORLD - vert);
	vec3 half_vector = normalize(light_direction + vertex_to_eye);

	float costheta = dot(normal, light_direction);
	float cosdelta = dot(normal, vertex_to_eye);

	float first_term = 1.f / sqrt(costheta * cosdelta);
	float second_term = 1.f / (12.56 * roughness_1 * roughness_2);

	vec3 direction = vec3(0.f, 0.f, 1.f);
	vec3 tangent = normalize(cross(normal, direction));
	vec3 bitangent = normalize(cross(normal, tangent));

	float h_dot_tangent = dot(half_vector, tangent);
	float h_dot_bitangent = dot(half_vector, bitangent);
	float h_dot_normal = dot(half_vector, normal);

	float A = -2.f * (pow((h_dot_tangent / roughness_1), 2) + pow((h_dot_bitangent / roughness_2), 2));
	float B = 1.f + h_dot_normal;

	float third_term = exp(A / B);
	float irradiance = max(0.f, costheta);

	vec3 specular_term = specular_color * first_term * second_term * third_term;
	vec3 final_color = irradiance * (specular_term + texture(albedo_texture, UV).xyz);

	ALBEDO = final_color;
}
