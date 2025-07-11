extends MeshInstance3D

var material: Material
@onready var directional_light: DirectionalLight3D = $"../DirectionalLight3D"
@export var diffuse_color: Color = Color.WHITE
@export var roughness_squared: float = 0;
var A: float
var B: float
@onready var hslider: HSlider = $"../HSlider"

func _ready() -> void:
	material = get_active_material(0)
	A = 1.0 - (0.5 * roughness_squared) / (roughness_squared + 0.33)
	B = (0.45 * roughness_squared) / (roughness_squared + 0.09)
	
	material.set_shader_parameter("light_direction", directional_light.global_transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("A", A)
	material.set_shader_parameter("B", B)
	
	print("Light Direction: ", directional_light.global_transform.basis.z)
	print("Color: ", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))

func _process(delta: float) -> void:
	A = 1.0 - (0.5 * roughness_squared) / (roughness_squared + 0.33)
	B = (0.45 * roughness_squared) / (roughness_squared + 0.09)
	material.set_shader_parameter("light_direction", directional_light.global_transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("A", A)
	material.set_shader_parameter("B", B)
