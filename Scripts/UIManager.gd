extends CanvasLayer

onready var box: PackedScene = preload("res://Scenes/HitBox.tscn")

var animation_player: AnimationPlayer

var loaded_animations: bool = false
var h_boxes
var sprite

func _ready():
	$Header/SaveFile.add_filter("*.JSON ; JSON Files")
	$Header/SaveFile.connect("confirmed", self, "_save_at_dir")
	$Header/OpenFile.add_filter("*.JSON ; JSON Files")
	$Header/OpenFile.connect("file_selected", self, "_open_file")
	
	var file_popup = $Header/Separator/File.get_popup()
	file_popup.connect("id_pressed", self, "_file_option_selected")
	file_popup.add_item("Open")
	file_popup.add_item("Save")
	
	var box_popup = $Header/Separator/Box.get_popup()
	box_popup.connect("id_pressed", self, "_box_option_selected")
	box_popup.add_item("New (A)")
	box_popup.add_item("Delete (Z)")
	box_popup.add_item("Import from another frame (I)")
	
	$Header/ImportFrame.connect("confirmed", self, "_import_frame_data")
	$Header/ImportFrame.register_text_enter($Header/ImportFrame/Separator/From)
	
	h_boxes = get_tree().get_root().get_node("Canvas/Boxes")
	sprite = get_tree().get_root().get_node("Canvas/CurrentSprite")
	
func _process(delta):
	if not loaded_animations:
		animation_player = get_parent().animation_player
		for animation in animation_player.get_animation_list():
			$Header/Separator/AnimationSelector.add_item(animation)
		
		loaded_animations = true
	
	if Input.is_action_just_pressed("add_new"):
		_create_box()
	
	if Input.is_action_just_pressed("delete_selected"):
		_delete_selected_box()
	
func save_data(current_frame: int):
	var boxes_array: Array = []
	for box in h_boxes.get_children():
		var collider: CollisionShape2D = box.get_node("Collider")
		var type = box.hit_type
		var pos = collider.global_position - sprite.global_position
		var dimensions: Dictionary = {
			"x": collider.shape.extents.x,
			"y": collider.shape.extents.y
		}
		boxes_array.append({
			"type": type,
			"position": {
				"x": pos.x,
				"y": pos.y,
			},
			"dimensions": dimensions
		})
	if	Utils.boxes_data.has(animation_player.assigned_animation):
		Utils.boxes_data[animation_player.assigned_animation][str(current_frame)] = boxes_array
	else:
		Utils.boxes_data[animation_player.assigned_animation] = {
			str(current_frame): boxes_array	
		}
		
func _file_option_selected(ID: int):
	match ID:
		0:
			$Header/OpenFile.visible = true
			$Header/OpenFile.invalidate()
			if $Header/SaveFile.visible:
				$Header/SaveFile.visible = false
		1:
			$Header/SaveFile.visible = true
			$Header/SaveFile.invalidate()
			if $Header/OpenFile.visible:
				$Header/OpenFile.visible = false
				
func _box_option_selected(ID: int):
	match ID:
		0: _create_box()
		1: _delete_selected_box()
		2: _open_import_popup()

func _save_at_dir():
	var dir: String = $Header/SaveFile.get_current_path()
	var file = File.new()
	file.open(dir, File.WRITE)
	file.store_string(to_json(Utils.boxes_data))
	file.close()

func _open_file(dir: String):
	var file = File.new()
	if not file.file_exists(dir):
		return
	
	file.open(dir, File.READ)
	Utils.boxes_data = parse_json(file.get_as_text())
	get_parent().display_updated_data()
	file.close()

func _on_AnimationSelector_item_selected(ID):
	animation_player.stop()
	animation_player.current_animation = animation_player.get_animation_list()[ID]
	animation_player.play()


func _on_PlayBtn_pressed():
	animation_player.play()


func _on_StopBtn_pressed():
	animation_player.stop()

func _create_box():
	var box_instance = box.instance()
	var boxes_parent = get_tree().get_root().get_node("Canvas/Boxes")
	box_instance.name = "HBOX" + str(boxes_parent.get_child_count())
	box_instance.created_manually = true
	boxes_parent.add_child(box_instance)
	box_instance.rect_global_position = get_tree().get_root().get_node("Canvas/MiddlePoint").global_position

func _delete_selected_box():
	var boxes_parent = get_tree().get_root().get_node("Canvas/Boxes")
	for child in boxes_parent.get_children():
		if child.is_focused:
			boxes_parent.remove_child(child)
			child.queue_free()
	
	# Focus the previous box
	var prev_box_id = boxes_parent.get_child_count() - 1
	if prev_box_id != -1:
		boxes_parent.get_child(prev_box_id).focus()
	
	# Save updated data
	save_data(int(animation_player.current_animation_position * 10))

func _open_import_popup():
	$Header/ImportFrame.popup()

func _import_frame_data() -> void:
	var selected_frame: String = str(int($Header/ImportFrame/Separator/From.text))
	if Utils.boxes_data.has(animation_player.assigned_animation):
		if Utils.boxes_data[animation_player.assigned_animation].has(selected_frame):
			print("Tengo")
		else:
			print("No tengo")