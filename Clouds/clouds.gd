@tool
extends Node3D

@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var volume_container: MeshInstance3D = $volume_container
var material: ShaderMaterial
var prev_light_direction: Vector3

# Compute shader related variables
const TEXTURE_WIDTH := 64
const TEXTURE_HEIGHT := 64
const TEXTURE_DEPTH := 64
const WORKGROUP_SIZE := 8

var rd: RenderingDevice
var output_texture_rid: RID
var output_texture: Texture3DRD
var compute_shader: RID
var compute_pipeline: RID
var uniform_set: RID
var params_buffer: RID

var init_gpu_tex_once: int = 0

func create_texture() -> void:
	var format := RDTextureFormat.new()
	format.width = TEXTURE_WIDTH
	format.height = TEXTURE_HEIGHT
	format.depth = TEXTURE_DEPTH
	format.array_layers = 1
	format.mipmaps = 1
	format.texture_type = RenderingDevice.TEXTURE_TYPE_3D
	format.samples = RenderingDevice.TEXTURE_SAMPLES_1
	format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
		| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
		| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	)
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM

	var view := RDTextureView.new()

	# Created on the global RenderingDevice, so rendering shaders can use it.
	output_texture_rid = rd.texture_create(format, view, [])

func create_compute_resources() -> void:
	var shader_file: RDShaderFile = load("res://Clouds/compute_hole.glsl")
	compute_shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	compute_pipeline = rd.compute_pipeline_create(compute_shader)

	# Small uniform buffer containing the sphere position.
	params_buffer = rd.uniform_buffer_create(16, PackedFloat32Array([0.0, 0.0, 0.0, 0.0]).to_byte_array())

	var output_uniform := RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_uniform.binding = 0
	output_uniform.add_id(output_texture_rid)

	var params_uniform := RDUniform.new()
	params_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	params_uniform.binding = 1
	params_uniform.add_id(params_buffer)

	uniform_set = rd.uniform_set_create(
		[output_uniform, params_uniform],
		compute_shader,
		0
	)

func assign_texture_to_material() -> void:
	# Keep the wrapper alive for as long as the material can sample the RID.
	output_texture = Texture3DRD.new()
	output_texture.texture_rd_rid = output_texture_rid

	material.set_shader_parameter("hole_texture", output_texture)

func _ready() -> void:
	material = volume_container.get_active_material(0)

	rd = RenderingServer.get_rendering_device()

	if rd == null:
		push_error("Compute shaders require the Forward+ or Mobile renderer.")
		return

	create_texture()
	create_compute_resources()
	assign_texture_to_material()

func _process(_delta: float) -> void:
	var light_direction: Vector3 = directional_light.transform.basis.z
	if light_direction != prev_light_direction:
		material.set_shader_parameter("light_direction", light_direction)
	prev_light_direction = light_direction

	if rd == null:
		return

	rd.buffer_update(
		params_buffer,
		0,
		16,
		PackedFloat32Array([0.0, 0.0, 0.0, init_gpu_tex_once]).to_byte_array()
	)

	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(
		compute_list,
		ceili(TEXTURE_WIDTH / float(WORKGROUP_SIZE)),
		ceili(TEXTURE_HEIGHT / float(WORKGROUP_SIZE)),
		ceili(TEXTURE_DEPTH / float(WORKGROUP_SIZE))
	)
	rd.compute_list_end()
	
	init_gpu_tex_once = 1

func _exit_tree() -> void:
	if rd == null:
		return

	# Detach the rendering-server wrapper before freeing its RenderingDevice RID.
	material.set_shader_parameter("hole_texture", null)
	output_texture.texture_rd_rid = RID()
	output_texture = null
	RenderingServer.force_sync()

	rd.free_rid(uniform_set)
	rd.free_rid(compute_pipeline)
	rd.free_rid(compute_shader)
	rd.free_rid(params_buffer)
	rd.free_rid(output_texture_rid)
