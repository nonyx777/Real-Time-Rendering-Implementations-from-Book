@tool
extends MeshInstance3D

var material1: Material
var material2: Material

@export var roughness: float
@onready var light_direction: DirectionalLight3D = $"../DirectionalLight3D"
@export var diffuse_color: Color
@export var specular_color: Color
 
func _ready() -> void:
	material1 = get_active_material(0)
	material1.set_shader_parameter("roughness", roughness)
	material1.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material1.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material1.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))
	
	material2 = get_active_material(1)
	material2.set_shader_parameter("roughness", roughness)
	material2.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material2.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material2.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))

func _process(_delta: float) -> void:
	material1.set_shader_parameter("roughness", roughness)
	material1.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material1.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material1.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))
	
	material2.set_shader_parameter("roughness", roughness)
	material2.set_shader_parameter("light_direction", light_direction.transform.basis.z)
	material2.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material2.set_shader_parameter("specular_color", Vector3(specular_color.r, specular_color.g, specular_color.b))
