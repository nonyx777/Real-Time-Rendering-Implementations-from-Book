#[compute]

#version 450

// 8 * 8 * 8 = 512 invocations, below Vulkan's commonly supported
// maxComputeWorkGroupInvocations limit of 1024.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;
layout(set = 0, binding = 0, rgba8) uniform restrict writeonly image3D output_image;
layout(set = 0, binding = 1) uniform Params {
    float x_position;
    float y_position;
    float z_position;
    float init_gpu_tex_once;
} params;

void main() {
    ivec3 size = imageSize(output_image);
    ivec3 pixel = ivec3(gl_GlobalInvocationID.xyz);

    if (any(greaterThanEqual(pixel, size))){
        return;
    }

    vec3 volume_position = (vec3(pixel) + vec3(0.5)) / vec3(size) - vec3(0.5);
    vec3 sphere_position = vec3(params.x_position, params.y_position, params.z_position);

    if (params.init_gpu_tex_once < 0.5){
        imageStore(output_image, pixel, vec4(1.0));
    }

    if (distance(volume_position, sphere_position) <= 0.4){
        imageStore(output_image, pixel, vec4(0.0));
    }
}
