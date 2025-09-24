extends DirectionalLight3D

@export var y_rot_speed: float = 40

func _process(delta: float) -> void:
	rotation_degrees.y += y_rot_speed * delta
