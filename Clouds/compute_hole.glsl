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
    float radius;
} params;

void main() {
    ivec3 size = imageSize(output_image);
    ivec3 pixel = ivec3(gl_GlobalInvocationID.xyz);

    if (pixel.x >= size.x || pixel.y >= size.y || pixel.z >= size.z){
        return;
    }

    vec3 volume_position = (vec3(pixel) + vec3(0.5)) / vec3(size) - vec3(0.5);
    vec3 position = vec3(params.x_position, params.y_position, params.z_position);
    float dist = distance(volume_position, position);

    vec4 mask = dist <= params.radius ? vec4(0, 0, 0, 0) : vec4(1, 1, 1, 1);

    imageStore(output_image, pixel, mask);
}
