shader_type spatial;
render_mode unshaded, fog_disabled;
uniform sampler2D screen_texture: hint_screen_texture, source_color, repeat_disable;
uniform sampler2D depth_texture: hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture: hint_normal_roughness_texture, source_color, repeat_disable, filter_nearest;

uniform float ssao_radius = 0.175;
uniform int ssao_samples_count = 32;
uniform float ssao_strength = 1.0;
uniform float ssao_bias = 0.0;
uniform vec3 samples[32];
uniform sampler2D rand_texture;

vec3 getPosition(vec2 uv, mat4 inv_proj_mat)
{
	float depth = texture(depth_texture, uv).x;
	vec3 clip_space = vec3(uv * 2.0 - 1.0, depth);
	vec4 view = inv_proj_mat * vec4(clip_space, 1.0);
	view.xyz /= view.w;
	return view.xyz;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 noise_scale = VIEWPORT_SIZE / 8.0;
	vec3 frag_pos = getPosition(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec3 normal = texture(normal_texture, SCREEN_UV).xyz;
	vec3 random_vec = texture(rand_texture, SCREEN_UV * noise_scale).rgb * 2.0 - 1.0;

	//constructing the TBN matrix to transform any vector from tangent-space to view-space
	vec3 tangent = normalize(random_vec - normal * dot(random_vec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 TBN = mat3(tangent, bitangent, normal);

	// storing occlusion
	float occlusion = 0.0;
	for (int i = 0; i <= ssao_samples_count; i++)
	{
		vec3 sample = TBN * samples[i];
		sample = frag_pos + sample * ssao_radius;
		vec4 offset = PROJECTION_MATRIX * vec4(sample, 1.0);
		offset.xyz /= offset.w;
		offset.xyz = offset.xyz * 0.5 + 0.5;
		float sample_depth = getPosition(offset.xy, INV_PROJECTION_MATRIX).z;
		float range_check = smoothstep(0.0, 1.0, ssao_radius / abs(frag_pos.z - sample_depth));
		occlusion += (sample_depth >= frag_pos.z + ssao_bias ? 1.0 : 0.0) * range_check;
	}
	occlusion = 1.0 - (occlusion / float(ssao_samples_count));
	occlusion = pow(occlusion, ssao_strength);

	//ALBEDO = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO = vec3(occlusion);
}
