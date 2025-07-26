extends MeshInstance3D

var material: Material

@export var ssao_samples_count: int = 64
@export var ssao_radius: float = 0.2
@export var ssao_strength: float = 1.0
@export var ssao_bias: float = 0.0001

var ssao_kernel: PackedVector3Array = []
var noise_texture: Texture2D

func generateSamples() -> void:
	randomize()
	for i in range(ssao_samples_count):
		var sample = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(0.0, 1.0))
		var scale = float(i) / float(ssao_samples_count)
		scale = lerp(0.1, 1.0, scale * scale)
		sample *= scale
		
		ssao_kernel.append(sample)

func generateNoiseTexture() -> void:
	randomize()
	var noise_image: Image = Image.create(4, 4, false, Image.FORMAT_RGBAF)
	for y in range(4):
		for x in range(4):
			var noise_vec = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0).normalized()
			noise_vec *= 0.5 + 0.5
			noise_image.set_pixel(x, y, Color(noise_vec.x, noise_vec.y, noise_vec.z))
	noise_texture = ImageTexture.create_from_image(noise_image)

func _ready() -> void:
	generateSamples()
	generateNoiseTexture()
	
	material = get_active_material(0)
	material.set_shader_parameter("ssao_radius", ssao_radius)
	material.set_shader_parameter("ssao_samples", ssao_samples_count)
	material.set_shader_parameter("ssao_strength", ssao_strength)
	material.set_shader_parameter("ssao_bias", ssao_bias)
	material.set_shader_parameter("samples", ssao_kernel)
	material.set_shader_parameter("rand_texture", noise_texture)
