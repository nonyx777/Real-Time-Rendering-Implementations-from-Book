extends MeshInstance3D

var material: Material

@export var roughness: float
@onready var light_direction: DirectionalLight3D = $"../DirectionalLight3D"
@export var diffuse_color: Color
@export var specular_color: Color

func _ready() -> void:
	material = get_active_material(0)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))

func _process(_delta: float) -> void:
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))
