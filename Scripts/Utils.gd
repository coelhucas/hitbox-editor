extends Node

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

var boxes_data: Dictionary = {}
var selected_box: Dictionary = {}
var old_selection_data: Dictionary = {}

onready var sprite = get_node("/root/Canvas/CurrentSprite")

onready var inspector = get_node("/root/Canvas/CanvasLayer/Inspector")

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

func clear_selected_box():
	update_selected_box("UNSELECTED", Vector2(0, 0), Vector2(0, 0), "hitbox", 0, 0)
	fields_enable(false)
	
func fields_enable(value: bool):
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
	inspector.get_node("Container/VerticalSeparator/TypeContainer/Type").select(BOX_IDS[selected_box.type] if selected_box.has("type") else 0)
	inspector.get_node("Container/VerticalSeparator/KnockbackValue").text = str(selected_box.knockback)
	inspector.get_node("Container/VerticalSeparator/JuggleValue").text = str(selected_box.juggle)
	
	old_selection_data = selected_box

func _update_box_type(ID: int):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.use_custom_type(BOX_TYPES[ID])

func _update_hitbox_knockback(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.knockback = int(new_value)

func _update_hitbox_juggle(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.juggle = int(new_value)

func _update_box_position_x(new_value: String):
	if not is_instance_valid(sprite):
		sprite = get_node("/root/Canvas/CurrentSprite")
		
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.rect_global_position.x = int(new_value) + int(sprite.global_position.x)
			
func _update_box_position_y(new_value: String):
	if not is_instance_valid(sprite):
		sprite = get_node("/root/Canvas/CurrentSprite")
		
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.rect_global_position.y = int(new_value) + int(sprite.global_position.y)
			
func _update_box_extents_x(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		print(int(new_value if new_value != "0" else 1))
		box.get_node("Collider").shape.extents.x = int(new_value)
		
func _update_box_extents_y(new_value: String):
	var box = get_node("/root/Canvas/Boxes/" + selected_box.name)
	if is_instance_valid(box):
		box.get_node("Collider").shape.extents.y = int(new_value if new_value != "0" else 1)