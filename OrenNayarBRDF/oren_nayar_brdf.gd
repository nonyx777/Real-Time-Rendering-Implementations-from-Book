extends MeshInstance3D

var material: Material
@onready var directional_light: DirectionalLight3D = $"../DirectionalLight3D"
@export var diffuse_color: Color = Color.WHITE
@export var roughness_squared: float = 0;
var A: float
var B: float
@onready var hslider: HSlider = $"../HSlider"
var image: Image
var angle_term_texture:  Texture2D

func computeValue(r: float, c: float) -> float:
	var x: float = 2.0 * r - 1.0
	var y: float = 2.0 * c - 1.0
	
	var angle_view_normal: float = acos(x)
	var angle_light_normal: float = acos(y)
	
	var alpha: float = max(angle_view_normal, angle_light_normal)
	var beta: float = min(angle_view_normal, angle_light_normal)
	
	return sin(alpha) * tan(beta)

func populateImageTexture() -> void:
	var value: Color
	for row in range(256):
		for col in range(256):
			value = Color(computeValue(row / 256.0, col / 256.0), 0, 0, 1)
			image.set_pixel(row, col, value)
	angle_term_texture = ImageTexture.create_from_image(image)
	material.set_shader_parameter("angleTermTexture", angle_term_texture)

func _ready() -> void:
	image = Image.create(256, 256, false, Image.FORMAT_RGBAF)
	material = get_active_material(0)
	A = 1.0 - (0.5 * roughness_squared) / (roughness_squared + 0.33)
	B = (0.45 * roughness_squared) / (roughness_squared + 0.09)
	
	populateImageTexture()
	material.set_shader_parameter("light_direction", directional_light.global_transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("A", A)
	material.set_shader_parameter("B", B)
	
	print("Light Direction: ", directional_light.global_transform.basis.z)
	print("Color: ", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))

func _process(_delta: float) -> void:
	A = 1.0 - (0.5 * roughness_squared) / (roughness_squared + 0.33)
	B = (0.45 * roughness_squared) / (roughness_squared + 0.09)
	material.set_shader_parameter("light_direction", directional_light.global_transform.basis.z)
	material.set_shader_parameter("diffuse_color", Vector3(diffuse_color.r, diffuse_color.g, diffuse_color.b))
	material.set_shader_parameter("A", A)
	material.set_shader_parameter("B", B)


func _on_h_slider_value_changed(value: float) -> void:
	roughness_squared = value
