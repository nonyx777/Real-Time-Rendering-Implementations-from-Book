extends HSlider
@onready var oren_nayar = $"../Planet"

func _ready() -> void:
	pass

func _on_value_changed(value: float) -> void:
	oren_nayar.roughness_squared = value;
