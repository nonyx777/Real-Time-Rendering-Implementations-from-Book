@tool
extends Node3D

@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var volume_container: MeshInstance3D = $volume_container
var material: ShaderMaterial
var prev_light_direction: Vector3

func _ready() -> void:
	material = volume_container.get_active_material(0)

func _process(_delta: float) -> void:
	var light_direction: Vector3 = directional_light.transform.basis.z
	if light_direction != prev_light_direction:
		material.set_shader_parameter("light_direction", light_direction)
	prev_light_direction = light_direction
