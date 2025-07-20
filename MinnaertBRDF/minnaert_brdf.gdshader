shader_type spatial;
render_mode unshaded;

uniform float power;
uniform vec3 lightDirection;
uniform vec3 diffuseColor;

varying vec3 vertex_world_pos;
varying vec3 normal_world_dir;

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal_world_dir = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 vertex_to_eye = normalize(CAMERA_POSITION_WORLD - vertex_world_pos);
	float v_dot_n = dot(vertex_to_eye, normal_world_dir);
	float l_dot_n = dot(normalize(lightDirection), normal_world_dir);
	float irradiance = max(0.0f, l_dot_n);

	ALBEDO = diffuseColor * pow(v_dot_n * l_dot_n, power) * irradiance;
}