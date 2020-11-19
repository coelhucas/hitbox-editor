extends Node

enum States {
	NORMAL,
	DIALOG
}

onready var box_scene: PackedScene = preload("res://Scenes/HitBox.tscn")

onready var inspector = get_node("/root/Canvas/CanvasLayer/Inspector")
onready	var collision_boxes = get_node("/root/Canvas/Boxes")

const POPUP_GROUP: String = "popup"
const ANIMATION_PLAYER_PATH: String = "/root/Canvas/SpriteContainer/Sprite/AnimationPlayer"
const ANIMATION_END_OFFSET: float = 0.1
const JSON_SUFIX: String = ".json"
const BOX_TYPES: Dictionary = {
	0: "hitbox",
	1: "hurtbox",
	2: "taunt",
	3: "parry"
}

const BOX_IDS: Dictionary = {
	"hitbox": 0,
	"hurtbox": 1,
	"taunt": 2,
	"parry": 3
}

var state: int = States.NORMAL
var sprite: Sprite
var animation_player: AnimationPlayer
var boxes_data: Dictionary = {}
var selected_box: Dictionary = {}
var old_selection_data: Dictionary = {}

var animation_pos: float

var is_playing: bool = false


func _ready():
	var type_selector = inspector.get_node("Container/VerticalSeparator/TypeContainer/Type")
	type_selector.connect("item_selected", self, "_update_box_type")
	update_selected_box("UNSELECTED", Vector2(0, 0), Vector2(0, 0), "hitbox", 0, 0)
	fields_enable(false)
	
	var knockback_input = inspector.get_node("Container/VerticalSeparator/KnockbackValue")
	knockback_input.connect("text_changed", self, "_update_hitbox_knockback")

	var juggle_input = inspector.get_node("Container/VerticalSeparator/JuggleValue")
	juggle_input.connect("text_changed", self, "_update_hitbox_juggle")	
	
	var position_input = {}
	position_input["x"] = inspector.get_node("Container/VerticalSeparator/XAxisContainer/Value")
	position_input["y"] = inspector.get_node("Container/VerticalSeparator/YAxisContainer/Value")
	
	position_input.x.connect("text_changed", self, "_update_box_position_x")
	position_input.y.connect("text_changed", self, "_update_box_position_y")
	
	var extents_input = {}
	extents_input["x"] = inspector.get_node("Container/VerticalSeparator/XExtentsContainer/Value")
	extents_input["y"] = inspector.get_node("Container/VerticalSeparator/YExtentsContainer/Value")
	
	extents_input.x.connect("text_changed", self, "_update_box_extents_x")
	extents_input.y.connect("text_changed", self, "_update_box_extents_y")
	
	sprite = get_node_or_null("/root/Canvas/SpriteContainer/Sprite")
	animation_player = get_node_or_null("/root/Canvas/SpriteContainer/Sprite/AnimationPlayer")

func _process(_delta: float) -> void:
	if not is_instance_valid(sprite):
		sprite = get_node("/root/Canvas/SpriteContainer/Sprite") 
	
	if not is_instance_valid(animation_player):
		animation_player = get_node("/root/Canvas/SpriteContainer/Sprite/AnimationPlayer")


func update_selected_box(name: String, position: Vector2, extents: Vector2, type: String, juggle: int = 0, knockback: int = 0) -> void:
	if name == "":
		selected_box = {}
		return
	
	selected_box["name"] = name
	selected_box["position"] = position
	selected_box["extents"] = extents
	selected_box["type"] = type
	selected_box["juggle"] = juggle
	selected_box["knockback"] = knockback
	
	_update_inspector()

func update_selected_box_type(type: String) -> void:
	selected_box.type = type
	_update_inspector()

func has_popup_open() -> bool:
	for node in get_tree().get_nodes_in_group(POPUP_GROUP):
		if node is Popup and (node as Popup).visible:
			return true
	return false

func clear_selected_box():
	update_selected_box("UNSELECTED", Vector2(0, 0), Vector2(0, 0), "hitbox", 0, 0)
	fields_enable(false)
	
func fields_enable(value: bool):
	inspector.get_node("Container/VerticalSeparator/TypeContainer/Type").disabled = !value
	inspector.get_node("Container/VerticalSeparator/XAxisContainer/Value").editable = value
	inspector.get_node("Container/VerticalSeparator/YAxisContainer/Value").editable = value
	inspector.get_node("Container/VerticalSeparator/XExtentsContainer/Value").editable = value
	inspector.get_node("Container/VerticalSeparator/YExtentsContainer/Value").editable = value
	inspector.get_node("Container/VerticalSeparator/KnockbackValue").editable = value
	inspector.get_node("Container/VerticalSeparator/JuggleValue").editable = value
	
func _update_inspector():
	if selected_box.has("name") and selected_box.name != "UNSELECTED":
		fields_enable(true)
		
	inspector.get_node("Container/VerticalSeparator/Name").text = selected_box.name if selected_box.has("name") else "UNSELECTED"
	inspector.get_node("Container/VerticalSeparator/XAxisContainer/Value").text = str(selected_box.position.x) if selected_box.has("position") else "0"
	inspector.get_node("Container/VerticalSeparator/YAxisContainer/Value").text = str(selected_box.position.y) if selected_box.has("position") else "0"
	inspector.get_node("Container/VerticalSeparator/XExtentsContainer/Value").text = str(selected_box.extents.x) if selected_box.has("extents") else "0"
	inspector.get_node("Container/VerticalSeparator/YExtentsContainer/Value").text = str(selected_box.extents.y) if selected_box.has("extents") else "0"
	
	if inspector.get_node("Container/VerticalSeparator/TypeContainer/Type").get_item_count() > 0:
		inspector.get_node("Container/VerticalSeparator/TypeContainer/Type").select(BOX_IDS[selected_box.type] if selected_box.has("type") else 0)
	inspector.get_node("Container/VerticalSeparator/KnockbackValue").text = str(selected_box.knockback)
	inspector.get_node("Container/VerticalSeparator/JuggleValue").text = str(selected_box.juggle)
	
	old_selection_data = selected_box

func save_data(current_frame: int):
	animation_player = Utils.animation_player
	
	if Utils.is_playing:
		return
	
	if not is_instance_valid(sprite):
		push_error("Invalid sprite node.")
		return
	
	var boxes_array: Array = []
	for box in collision_boxes.get_children():
		if "ANIMATED" in box.name:
			box.queue_free()
			continue
			
		var collider: CollisionShape2D = box.get_node("Collider")
		var type = box.hit_type
		var knockback = int(box.knockback)
		var juggle = int(box.juggle)
		var pos = collider.global_position - sprite.global_position
		var dimensions: Dictionary = {
			"x": collider.shape.extents.x * 2,
			"y": collider.shape.extents.y * 2
		}
		boxes_array.append({
			"type": type,
			"juggle": juggle,
			"knockback": knockback,
			"position": {
				"x": pos.x,
				"y": pos.y,
			},
			"dimensions": dimensions
		})
	if Utils.boxes_data.has(animation_player.assigned_animation):
		boxes_data[animation_player.assigned_animation][str(current_frame)] = boxes_array
	else:
		Utils.boxes_data[animation_player.assigned_animation] = {
			str(current_frame): boxes_array	
		}

func wipe_data() -> void:
	clear_current_boxes()
	Utils.boxes_data = {}

func clear_current_boxes():
	for child in collision_boxes.get_children():
		child.free()

func seek_frame(frame: float):
	if not is_instance_valid(animation_player):
		animation_player = get_node("/root/Canvas/SpriteContainer/Sprite/AnimationPlayer")
	
	var anim_length: float = animation_player.get_animation(animation_player.assigned_animation).length
	
	if frame > anim_length - ANIMATION_END_OFFSET:
		animation_player.seek(0, true)
		frame = 0
	elif frame < 0:
		animation_player.seek(anim_length - ANIMATION_END_OFFSET, true)
		frame = anim_length - ANIMATION_END_OFFSET
	else:
		animation_player.seek(frame, true)
	
	animation_pos = clamp(frame, 0, anim_length)
	get_node("/root/Canvas/CanvasLayer/Header/Separator/CurrentFrameLabel").text = "Frame: " + str(int(animation_pos * 10))
	
	create_stored_boxes()

func get_animation_frame() -> int:
	return int(Utils.animation_pos * 10)

func create_stored_boxes():
	clear_current_boxes()
	sprite = Utils.sprite
	
	if not is_instance_valid(animation_player):
		push_error("AnimationPlayer node not valid.")
		return
		
	var current_frame = str(int(Utils.animation_pos * 10))
	
	if boxes_data.has(animation_player.assigned_animation):
		if boxes_data[animation_player.assigned_animation].has(current_frame):
			var current_frame_data = boxes_data[animation_player.assigned_animation][current_frame]
			
			for box in current_frame_data:
				var new_box = box_scene.instance()
				var new_box_collider = new_box.get_node("Collider")
				new_box.hit_type = box.type
				new_box.knockback = box.knockback
				new_box.juggle = box.juggle
				collision_boxes.add_child(new_box)
				if is_playing:
					new_box.name = "ANIMATED-HBOX" + str(collision_boxes.get_child_count())
				else:
					new_box.name = "LOADED-HBOX" + str(collision_boxes.get_child_count())
				new_box_collider.shape.extents = Vector2(box.dimensions.x / 2, box.dimensions.y / 2)
				new_box.rect_global_position = Vector2(box.position.x, box.position.y) + sprite.global_position
			
	if collision_boxes.get_children().size() > 0:
		var children = collision_boxes.get_children()
		children[children.size() - 1].focus()

# Saved after update inside Hitbox
func _update_box_type(ID: int):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.use_custom_type(BOX_TYPES[ID])

# Saved here for now
func _update_hitbox_knockback(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.knockback = int(new_value)
		save_data(int(animation_pos * 10))

# Saved here for now
func _update_hitbox_juggle(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.juggle = int(new_value)
		save_data(int(animation_pos * 10))

# Below properties need to be saved manually here
func _update_box_position_x(new_value: String):
	if not is_instance_valid(sprite):
		sprite = get_node("/root/Canvas/Sprite")
		
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.rect_global_position.x = int(new_value) + int(sprite.global_position.x)
		save_data(int(animation_pos * 10))
			
func _update_box_position_y(new_value: String):
	if not is_instance_valid(sprite):
		sprite = get_node("/root/Canvas/Sprite")
		
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.rect_global_position.y = int(new_value) + int(sprite.global_position.y)
		save_data(int(animation_pos * 10))
			
func _update_box_extents_x(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.get_node("Collider").shape.extents.x = int(new_value)
		save_data(int(animation_pos * 10))
		
func _update_box_extents_y(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.get_node("Collider").shape.extents.y = int(new_value) if new_value != "0" else 1
		save_data(int(animation_pos * 10))
