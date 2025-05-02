extends Node3D

@onready var sphereMaterial: Material = $Sphere.mesh.surface_get_material(0)
@export var light_position: MeshInstance3D

var radiant_flux: float = 3.0 #Default 3.0
var kd: Vector3 = Vector3(0.6, 0.3, 0.8) # Default (0.6, 0.3, 0.8)
var ks: Vector3 = Vector3(1.0, 1.0, 1.0) # Default (1.0, 1.0, 1.0)
var ns: float = 32.0 # Default 32.0


func _ready() -> void:
	sphereMaterial.set_shader_parameter("radiant_flux", radiant_flux)
	sphereMaterial.set_shader_parameter("kd", kd)
	sphereMaterial.set_shader_parameter("ks", ks)
	sphereMaterial.set_shader_parameter("ns", ns)
	sphereMaterial.set_shader_parameter("light_position", light_position.position)
