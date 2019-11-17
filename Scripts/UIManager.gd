extends CanvasLayer

onready var box: PackedScene = preload("res://Scenes/HitBox.tscn")

var animation_player: AnimationPlayer

var loaded_animations: bool = false
var h_boxes
var player

func _ready():
	$Header/SaveFile.add_filter("*.JSON ; JSON Files")
	$Header/SaveFile.connect("confirmed", self, "_save_at_dir")
	var file_popup = $Header/Separator/File.get_popup()
	file_popup.connect("id_pressed", self, "_file_option_selected")
	file_popup.add_item("Open")
	file_popup.add_item("Save")
	
	$Header/Separator/NewBtn.connect("pressed", self, "_create_box")
	h_boxes = get_tree().get_root().get_node("Canvas/Boxes")
	player = get_tree().get_root().get_node("Canvas/CurrentSprite/Player")
	pass
	
func _process(delta):
	if not loaded_animations:
		animation_player = get_parent().animation_player
		for animation in animation_player.get_animation_list():
			$Header/Separator/AnimationSelector.add_item(animation)
		
		loaded_animations = true

func save_data(current_frame: int):
	print("Saved data from " + str(current_frame))
	var boxes_array: Array = []
	for box in h_boxes.get_children():
		var collider: CollisionShape2D = box.get_node("Collider")
		var type = box.hit_type
		var pos = collider.global_position - player.global_position
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
	#print(Utils.boxes_data)
		
func _file_option_selected(ID: int):
	match ID:
		1:
			$Header/SaveFile.visible = true

func _save_at_dir():
	var dir: String = $Header/SaveFile.get_current_path()
	var file = File.new()
	file.open(dir, File.WRITE)
	file.store_string(to_json(Utils.boxes_data))
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
	boxes_parent.add_child(box_instance)
	box_instance.rect_global_position = get_tree().get_root().get_node("Canvas/MiddlePoint").global_position