shader_type spatial;
render_mode unshaded;

#define STEP_SIZE 0.01
#define NUM_LIGHT_STEPS 6
#define LIGHT_STEP_SIZE 0.05

uniform sampler3D base_tex: source_color, repeat_disable;
uniform vec3 color_light: source_color;
uniform vec3 color_shadow: source_color;
uniform vec3 light_direction;

vec3 ray_marching(
	vec3 ray_origin,
	vec3 ray_direction,
	vec3 offset,
	vec3 light_dir,
	float darkness,
	float transmittance,
	float light_absorb
	)
{
	float density = 0.0;
	float transmission = 0.0;
	float light_accumulation = 0.0;
	float final_light = 0.0;
	
	//ray entry and exit..................................
	float x_min = -0.5;
	float y_min = -0.5;
	float z_min = -0.5;
	float x_max = 0.5; 
	float y_max = 0.5;
	float z_max = 0.5;
	
	float t_x1 = (x_min - ray_origin.x) / ray_direction.x;
	float t_x2 = (x_max - ray_origin.x) / ray_direction.x;
	
	float t_y1 = (y_min - ray_origin.y) / ray_direction.y;
	float t_y2 = (y_max - ray_origin.y) / ray_direction.y;
	
	float t_z1 = (z_min - ray_origin.z) / ray_direction.z;
	float t_z2 = (z_max - ray_origin.z) / ray_direction.z;
	
	float t_x_enter = min(t_x1, t_x2);
	float t_x_exit = max(t_x1, t_x2);
	
	float t_y_enter = min(t_y1, t_y2);
	float t_y_exit = max(t_y1, t_y2);
	
	float t_z_enter = min(t_z1, t_z2);
	float t_z_exit = max(t_z1, t_z2);
	
	float t_enter = max(t_x_enter, max(t_y_enter, t_z_enter));
	float t_exit = min(t_x_exit, min(t_y_exit, t_z_exit));
	
	//.......................................................
	
	float t_current = t_enter;
	for (int i = 0; t_current < t_exit; i++)
	{
		ray_origin += (ray_direction * STEP_SIZE);
		vec3 sampled_position = ray_origin + offset;
		float sample_density = texture(base_tex, sampled_position).r;
		density += sample_density;

		vec3 light_ray_origin = sampled_position;
		light_accumulation = 0.0;
		for (int j = 0; j < NUM_LIGHT_STEPS; j++)
		{
			light_ray_origin += (light_dir * LIGHT_STEP_SIZE);
			float light_density = texture(base_tex, light_ray_origin).r;
			light_accumulation += light_density;
		}

		float light_transmission = exp(-light_accumulation);
		float shadow = darkness * light_transmission * (1.0 - darkness);
		final_light += density * transmittance * shadow;
		transmittance *= exp(-density * light_absorb);
		
		t_current += STEP_SIZE;
	}

	transmission = exp(-density);

	return vec3(final_light, transmission, transmittance);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 ray_origin_ws = (INV_VIEW_MATRIX * vec4(VERTEX.xyz, 1.0)).xyz;
	vec3 ray_direction = normalize(ray_origin_ws - CAMERA_POSITION_WORLD);
	vec4 transform = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0));
	vec3 offset = (vec4(0.5, 0.5, 0.5, 0.0) - transform).xyz;

	const float darkness = 0.19;
	const float transmittance = 1.0;
	const float light_absorb = 0.3;

	vec3 render = ray_marching(
		ray_origin_ws,
		ray_direction,
		offset,
		light_direction,
		darkness,
		transmittance,
		light_absorb
	);

	float gradient = clamp(render.x, 0.0, 1.0);
	vec3 albedo = mix(color_shadow, color_light, gradient);
	float alpha = (1.0 - render.y);

	ALBEDO = albedo;
	ALPHA = alpha;
}