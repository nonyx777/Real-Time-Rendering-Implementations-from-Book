extends Node3D

@export var y_rotation_speed: float = 10.0

func _process(delta: float):
	rotation_degrees.y += y_rotation_speed * delta
