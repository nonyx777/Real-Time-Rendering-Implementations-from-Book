shader_type spatial;
render_mode unshaded;

uniform float radiant_flux;
uniform vec3 kd;
uniform vec3 ks;
uniform float ns;
uniform vec3 light_position;

varying vec3 vertex_world_pos;
varying vec3 vertex_world_norm;

const float rgbgamma = 1.0/2.2;
const float lingamma = 2.2;

vec3 rgb2lin(vec3 rgb){
	return pow(rgb, vec3(lingamma, lingamma, lingamma));
}

vec3 lin2rgb(vec3 lin){
	return pow(lin, vec3(rgbgamma, rgbgamma, rgbgamma));
}

vec3 brdf(vec3 k_d, vec3 k_s, float n_s, vec3 cam_pos, vec3 light_pos, vec3 vertex_pos, vec3 vertex_norm){
	vec3 light_dir = normalize(light_pos - vertex_pos);
	vec3 view_dir = normalize(cam_pos - vertex_pos);
	vec3 half_dir = normalize(light_dir + view_dir);
	vec3 color = k_d/PI;
	float normalization = (n_s + 2.0) / (2.0 * PI);
	color += k_s * normalization * pow(max(dot(half_dir, vertex_norm), 0.0), n_s);
	return color;
}

float irradiance(vec3 light_pos, vec3 vertex_pos, vec3 vertex_norm, float flux){
	vec3 light_dir = light_pos - vertex_pos;
	float c = max(dot(normalize(light_dir), vertex_norm), 0.0);
	float light_dist = length(light_dir);
	return c * flux / (4.0 * PI * light_dist * light_dist);
}

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertex_world_norm = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 brdf = brdf(rgb2lin(kd), rgb2lin(ks), ns, CAMERA_POSITION_WORLD, light_position, vertex_world_pos, vertex_world_norm);
	float irradiance = irradiance(light_position, vertex_world_pos, vertex_world_norm, radiant_flux);
	vec3 radiance = brdf * irradiance;
	ALBEDO = radiance;
}