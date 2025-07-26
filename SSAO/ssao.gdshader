shader_type spatial;
render_mode unshaded, fog_disabled;
uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D depth_texture: hint_depth_texture;
uniform sampler2D normal_texture: hint_normal_roughness_texture;

uniform float ssao_radius = 0.5;
uniform int ssao_samples_count = 64;
uniform float ssao_strength = 1.0;
uniform float ssao_bias = 0.025;
uniform vec3 samples[64];
uniform sampler2D rand_texture;
//1152 x 648
const vec2 noise_scale = vec2(1152.0 / 4.0, 648.0 / 4.0);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	vec3 frag_pos = view.xyz; // view space frag position
	float linear_depth = -(view.xyz / view.w).z / 100.0;
	vec3 normal = texture(normal_texture, SCREEN_UV).xyz * 2.0 - 1.0; // normal here
	vec3 random_vec = texture(rand_texture, SCREEN_UV * noise_scale).rgb;
	
	//constructing the TBN matrix to transform any vector from tangent-space to view-space
	vec3 tangent = normalize(random_vec - normal * dot(random_vec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 TBN = mat3(tangent, bitangent, normal);
	
	// storing occlusion
	float occlusion = 0.0;
	for (int i = 0; i < ssao_samples_count; i++)
	{
		vec3 sample = TBN * samples[i];
		sample = frag_pos + sample * ssao_radius;
		vec4 offset = PROJECTION_MATRIX * vec4(sample, 1.0);
		offset.xyz /= offset.w;
		offset.xyz = offset.xyz * 0.5 + 0.5;
		float sample_depth = texture(depth_texture, offset.xy).r;
		vec3 ndc_ = vec3(offset.xy * 2.0 - 1.0, sample_depth);
		vec4 view_ = INV_PROJECTION_MATRIX * vec4(ndc_, 1.0);
		view_.xyz /= view_.w;
		occlusion += view_.z >= sample.z + ssao_bias ? 1.0 : 0.0;
	}
	occlusion = 1.0 - (occlusion / float(ssao_samples_count));
	
	//ALBEDO = vec3(fract(linear_depth));
	//ALBEDO = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO = vec3(occlusion);
}