@tool
extends VBoxContainer

var selected_file_path: String = ""
var file_path_label: Label
var file_dialog: FileDialog

const volume_width: int = 64
const volume_height: int = 64
const volume_depth: int = 64
const atlas_columns: int = 8
const atlas_rows: int = 8
const output_path := "res://assets/cloud_volume.tres"

func converter(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Texture3DConverter: Could not open file: %s (error %d)" \
				% [path, FileAccess.get_open_error()])
		return
	
	var atlas_texture: Image = Image.new()
	atlas_texture.load(path)
	
	var slice_width: int = volume_width
	var slice_height: int = volume_height
	
	var slice_images: Array[Image] = []
	
	for z in range(volume_depth):
		var col := z % atlas_columns
		var row := z / atlas_columns
		
		var src_x := col * slice_width
		var src_y := row * slice_height
		
		var slice_image := atlas_texture.get_region(
			Rect2i(src_x, src_y, slice_width, slice_height)
		)
		
		slice_images.append(slice_image)
	
	var tex_3d: ImageTexture3D = ImageTexture3D.new()
	tex_3d.create(
		Image.FORMAT_RGBA8,
		volume_width,
		volume_height,
		volume_depth,
		false,
		slice_images
	)
	
	var save_err := ResourceSaver.save(tex_3d, output_path)
	if save_err != OK:
		print("Failed to save Texture3D to: ", output_path)
		return
	print("Successfully created Texture3D at: ", output_path)

func _ready() -> void:
	var title := Label.new()
	title.text = "Texture3DConverter"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	var choose_btn := Button.new()
	choose_btn.text = "Choose File..."
	choose_btn.pressed.connect(on_choose_file_button_pressed)
	add_child(choose_btn)
	
	file_path_label = Label.new()
	file_path_label.text = "No file selected"
	file_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(file_path_label)
	
	add_child(HSeparator.new())
	
	var run_btn := Button.new()
	run_btn.text = "Convert"
	run_btn.pressed.connect(on_convert_button_pressed)
	add_child(run_btn)
	
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_selected.connect(on_file_dialog_file_selected)
	add_child(file_dialog)


func on_choose_file_button_pressed() -> void:
	file_dialog.popup_centered_ratio(0.7)
	
func on_file_dialog_file_selected(path: String) -> void:
	selected_file_path = path
	file_path_label.text = "File: %s" % path
	
func on_convert_button_pressed() -> void:
	if selected_file_path.is_empty():
		push_warning("Texture3DConverter: No file selected.")
		return
	converter(selected_file_path)
