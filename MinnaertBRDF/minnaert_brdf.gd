extends MeshInstance3D

var material: Material
var power: float = 0.8
@onready var directionalLight: DirectionalLight3D = $"../../DirectionalLight3D"
@export var diffuseColor: Color

func _ready() -> void:
	material = get_active_material(0)
	material.set_shader_parameter("power", power)
	material.set_shader_parameter("lightDirection", directionalLight.global_transform.basis.z)
	material.set_shader_parameter("diffuseColor", Vector3(diffuseColor.r, diffuseColor.g, diffuseColor.b))

func _process(delta: float) -> void:
	material.set_shader_parameter("power", power)
	material.set_shader_parameter("lightDirection", directionalLight.global_transform.basis.z)
	material.set_shader_parameter("diffuseColor", Vector3(diffuseColor.r, diffuseColor.g, diffuseColor.b))

func _on_h_slider_value_changed(value: float) -> void:
	power = value
