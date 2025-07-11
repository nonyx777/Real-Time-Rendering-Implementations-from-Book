@tool
extends MeshInstance3D

@export var light_position: MeshInstance3D

var radiant_flux: float = 30.0 #Default 3.0
var ka: Vector3 = Vector3(0.15, 0.15, 0.15) # Default (0.1, 0.1, 0.1)
var kd: Vector3 = Vector3(0.25, 0.5, 0.2) # Default (0.25, 0.5, 0.2)
var ks: Vector3 = Vector3(0.25, 0.25, 0.25) # Default (1.0, 1.0, 1.0)
var ns: float = 400.0 # Default 32.0

var material: Material

func _ready() -> void:
	material = get_active_material(0)
	material.set_shader_parameter("radiant_flux", radiant_flux)
	material.set_shader_parameter("ka", ka)
	material.set_shader_parameter("kd", kd)
	material.set_shader_parameter("ks", ks)
	material.set_shader_parameter("ns", ns)
	material.set_shader_parameter("light_position", light_position.position)
func _process(delta: float) -> void:
	material.set_shader_parameter("light_position", light_position.position)
