shader_type spatial;
render_mode unshaded;

uniform float radiant_flux;
uniform vec3 kd;
uniform vec3 ks;
uniform float ns;
uniform vec3 light_position;

varying vec3 vertex_world_pos;
varying vec3 vertex_world_norm;

vec3 brdf(vec3 k_d, vec3 k_s, float n_s, vec3 cam_pos, vec3 light_pos, vec3 vertex_pos, vec3 vertex_norm){
	vec3 light_dir = light_pos - vertex_pos;
	vec3 view_dir = cam_pos - vertex_pos;
	vec3 half_dir = normalize(light_dir + view_dir);
	return k_d + k_s * pow(max(dot(half_dir, vertex_norm), 0.0), n_s);
}

float irradiance(vec3 light_pos, vec3 vertex_pos, vec3 vertex_norm, float flux){
	vec3 light_dir = light_pos - vertex_pos;
	float c = max(dot(normalize(light_dir), vertex_norm), 0.0);
	float light_dist = length(light_dir);
	return c * (flux / (4.0 * PI * pow(0.5, 2)));
}

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertex_world_norm = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	ALBEDO = vec3(1.0, 1.0, 1.0) * brdf(kd, ks, ns, CAMERA_POSITION_WORLD, light_position, vertex_world_pos, vertex_world_norm) * irradiance(light_position, vertex_world_pos, vertex_world_norm, radiant_flux);
}