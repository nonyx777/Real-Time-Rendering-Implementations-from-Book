shader_type spatial;
render_mode unshaded;

uniform vec3 light_direction;
uniform vec3 diffuse_color;
uniform float A;
uniform float B;
uniform sampler2D angleTermTexture;

varying vec3 vertex_world_pos;
varying vec3 vertex_world_norm;

const vec3 ambient_light = vec3(0.006);

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertex_world_norm = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 vertex_to_eye = normalize(CAMERA_POSITION_WORLD - vertex_world_pos);
	float vdotn = dot(vertex_to_eye, vertex_world_norm);
	float ldotn = dot(normalize(light_direction), vertex_world_norm);
	float irradiance = max(0.0f, ldotn);
	
	float angle_difference = max(0.0f, 
		dot(normalize(vertex_to_eye - vertex_world_norm * vdotn), 
			normalize(light_direction - vertex_world_norm * ldotn))
	);
	
	float n_vdotn = 0.5f * vdotn + 0.5f;
	float n_ldotn = 0.5f * ldotn + 0.5f;
	float value = texture(angleTermTexture, vec2(n_vdotn, n_ldotn)).r;
	vec3 final_color = diffuse_color * (A + B * angle_difference * value) * irradiance;
	ALBEDO = final_color + ambient_light;
}