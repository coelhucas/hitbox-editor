extends CanvasLayer

onready var box: PackedScene = preload("res://Scenes/HitBox.tscn")

export var default_frame_color: Color
export var playing_frame_color: Color

const ANIMATED_SCENES_PATH: String = "./Animated/"

var animation_player: AnimationPlayer

var animated_entities_list: Array

var loaded_animations: bool = false
var h_boxes
var sprite

func _ready():
	$Inspector.visible = true
	
	$Header/SaveFile.add_filter("*.JSON ; JSON Files")
	$Header/SaveFile.connect("confirmed", self, "_save_at_dir")
	$Header/OpenFile.add_filter("*.JSON ; JSON Files")
	$Header/OpenFile.connect("file_selected", self, "_open_file")
	
	var file_popup = $Header/Separator/File.get_popup()
	file_popup.connect("id_pressed", self, "_file_option_selected")
	file_popup.add_item("Open (CTRL+O)")
	file_popup.add_item("Save (CTRL+S)")
	file_popup.add_item("Open Inspector (I)")
	
	var box_popup = $Header/Separator/Box.get_popup()
	box_popup.connect("id_pressed", self, "_box_option_selected")
	box_popup.add_item("New (A)")
	box_popup.add_item("Delete selected (Z)")
	box_popup.add_item("Import from another frame (CTRL+I)")
	
	
	$Header/ImportFrame.connect("confirmed", self, "_import_frame_data")
	$Header/ImportFrame.register_text_enter($Header/ImportFrame/Separator/From)
	
	$Inspector/Container/VerticalSeparator/TypeContainer/Type.add_item("HITBOX")
	$Inspector/Container/VerticalSeparator/TypeContainer/Type.add_item("HURTBOX")
	$Inspector/Container/VerticalSeparator/TypeContainer/Type.add_item("PARRY")
	$Inspector/Container/VerticalSeparator/TypeContainer/Type.add_item("TAUNT")
	
	$Header/Separator/SpriteSelector.connect("item_selected", self, "_change_sprite")
	load_animated_entities()
	
	h_boxes = get_tree().get_root().get_node("Canvas/Boxes")
	sprite = get_tree().get_root().get_node("Canvas/SpriteContainer/Sprite")
	
	if $Header/Separator/SpriteSelector.get_item_count() > 0:
		pass
		
func _process(delta):
	if not loaded_animations and is_instance_valid(sprite):
		animation_player = get_parent().animation_player
		
		if not Utils.is_playing and animation_player.is_playing():
			animation_player.stop()
		
		for animation in animation_player.get_animation_list():
			$Header/Separator/AnimationSelector.add_item(animation)
		
		loaded_animations = true
	
	if Utils.is_playing and $Header/Separator/CurrentFrameLabel.modulate != playing_frame_color:
		$Header/Separator/CurrentFrameLabel.modulate = playing_frame_color
	elif not Utils.is_playing and $Header/Separator/CurrentFrameLabel.modulate != default_frame_color:
		$Header/Separator/CurrentFrameLabel.modulate = default_frame_color
		
	# Application shortcuts
	# Box
	if Input.is_action_just_pressed("add_new"):
		_create_box()
	
	if Input.is_action_just_pressed("delete_selected"):
		_delete_selected_box()
		
	if Input.is_action_just_pressed("open_import_menu"):
		_open_import_popup()
		
	# Animation
	if Input.is_action_just_pressed("stop_animation") and Utils.is_playing:
		Utils.is_playing = false
		print("false")
	
	if Input.is_action_just_pressed("play_animation") and $Header/Separator/SpriteSelector.get_item_count() > 0:
		Utils.is_playing = true
	
	# File
	if Input.is_action_just_pressed("save_file"):
		$Header/SaveFile.visible = true
		$Header/SaveFile.invalidate()
	
	if Input.is_action_just_pressed("open_file"):
		$Header/OpenFile.visible = true
		$Header/OpenFile.invalidate()
	
	if Input.is_action_just_pressed("open_inspector"):
		_open_inspector()
	
func _setup_initial_sprite():
	var sprite_path: String = ANIMATED_SCENES_PATH + animated_entities_list[0]
	var new_sprite = load(sprite_path).instance()
	new_sprite.name = "Sprite"
	new_sprite.global_position = get_parent().get_node("MiddlePoint").global_position
	print(new_sprite.get_children())
	print(new_sprite.get_node("AnimationPlayer").is_playing())
	new_sprite.get_node("AnimationPlayer").stop()
	get_node("/root/Canvas/SpriteContainer").add_child(new_sprite, true)
#	_update_sprite_selector()

func load_animated_entities():
	var animated_entities: Array = []
	var animated_entities_dir: Directory = Directory.new()
	
	if not animated_entities_dir.dir_exists(ANIMATED_SCENES_PATH):
		return # TODO: Show a tooltip explaining the needing of a "Test" folder containing the .TSCN files
	
	animated_entities_dir.open(ANIMATED_SCENES_PATH)
	animated_entities_dir.list_dir_begin()
	
	while true:
		var file = animated_entities_dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			animated_entities.append(file)
	
	animated_entities_dir.list_dir_end()
	animated_entities_list = animated_entities
	
	for entity in animated_entities:
		$Header/Separator/SpriteSelector.add_item(entity)
	
	if $Header/Separator/SpriteSelector.get_item_count() > 0:
		_setup_initial_sprite()

func _change_sprite(ID: int):
	if is_instance_valid(get_parent().get_node("Sprite")):
		get_parent().get_node("Sprite").name = "Old"
		get_parent().get_node("Old").queue_free()
	var sprite_path: String = ANIMATED_SCENES_PATH + str(animated_entities_list[ID])
	var new_sprite = load(sprite_path).instance()
	new_sprite.name = "Sprite"
	get_parent().add_child(new_sprite)
	new_sprite.global_position = get_parent().get_node("MiddlePoint").global_position
	new_sprite.get_node("AnimationPlayer").stop()
	_update_sprite_selector()
	$Header/Separator/CurrentFrameLabel.text = "Frame: 0"
	
func _update_sprite_selector():
	animation_player = get_parent().get_node("SpriteContainer/Sprite/AnimationPlayer")
		
	var new_sprite_animations: Array = animation_player.get_animation_list()
	$Header/Separator/AnimationSelector.items = []
	
	for animation in new_sprite_animations:
		$Header/Separator/AnimationSelector.add_item(animation)
	$Header/Separator/AnimationSelector.select(0)
	pass
		
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
		2: _open_inspector()
				
func _box_option_selected(ID: int):
	match ID:
		0: _create_box()
		1: _delete_selected_box()
		2: _open_import_popup()

func _save_at_dir():
	var dir: String = $Header/SaveFile.get_current_path()
	var file = File.new()
	file.open(dir + Utils.JSON_SUFIX, File.WRITE)
	file.store_string(to_json(Utils.boxes_data))
	file.close()

func _open_file(dir: String):
	var file = File.new()
	if not file.file_exists(dir):
		return
	
	file.open(dir, File.READ)
	Utils.boxes_data = parse_json(file.get_as_text())
	_import_frame_data()
	file.close()

func _open_inspector():
	$Inspector.visible = true

func _on_AnimationSelector_item_selected(ID):
	for node in get_parent().get_node("SpriteContainer/Sprite").get_children():
		if node is AnimationPlayer:
			animation_player = node

	animation_player.current_animation = animation_player.get_animation_list()[ID]
	animation_player.seek(0, true)
	if animation_player.is_playing():
		animation_player.stop()
	Utils.is_playing = false


func _on_PlayBtn_pressed():
	if $Header/Separator/SpriteSelector.get_item_count() > 0:
		Utils.is_playing = true


func _on_StopBtn_pressed():
	if $Header/Separator/SpriteSelector.get_item_count() > 0:
		Utils.is_playing = false
		animation_player.seek(stepify(animation_player.current_animation_position, 0.1))

func _create_box():
	if not is_instance_valid(get_node("/root/Canvas/SpriteContainer/Sprite")):
		return
	
	var box_instance = box.instance()
	var boxes_parent = get_tree().get_root().get_node("Canvas/Boxes")
	box_instance.name = "HBOX" + str(boxes_parent.get_child_count())
	box_instance.created_manually = true
	boxes_parent.add_child(box_instance)
	box_instance.rect_global_position = get_tree().get_root().get_node("Canvas/MiddlePoint").global_position

func _delete_selected_box():
	var boxes_parent = get_tree().get_root().get_node("Canvas/Boxes")
	if boxes_parent.get_child_count() == 0:
		return
	
	for child in boxes_parent.get_children():
		if child.is_focused:
			boxes_parent.remove_child(child)
			child.queue_free()
	
	# Focus the previous box
	var prev_box_id = boxes_parent.get_child_count() - 1
	if prev_box_id != -1:
		boxes_parent.get_child(prev_box_id).focus()
	
	# If it was the last box, clears inspector
	if boxes_parent.get_child_count() == 0:
		Utils.clear_selected_box()
	
	# Save updated data
	Utils.save_data(int(animation_player.current_animation_position * 10))

func _open_import_popup():
	$Header/ImportFrame.popup()

func _import_frame_data() -> void:
	# Save selected frame	
	var selected_frame: String = str(int($Header/ImportFrame/Separator/From.text))
	
	# Clears the import frame text
	$Header/ImportFrame/Separator/From.text = ""
	
	#TO DO: Put this function at Utils to be used from anywhere
	if Utils.boxes_data.has(animation_player.assigned_animation):
		if Utils.boxes_data[animation_player.assigned_animation].has(selected_frame):
			for box_data in Utils.boxes_data[animation_player.assigned_animation][selected_frame]:
				var new_box = box.instance()
				var new_box_collider = new_box.get_node("Collider")
				new_box.hit_type = box_data.type
				new_box.name = "LOADED-HBOX" + str(h_boxes.get_child_count())
				h_boxes.add_child(new_box)
#				Dimensions here are divided by 2 because we save it as a raw size,
#				so it can be parsed in other engines/frameworks without generating any noise.
				new_box_collider.shape.extents = Vector2(box_data.dimensions.x / 2, box_data.dimensions.y / 2)
				new_box.rect_global_position = Vector2(box_data.position.x, box_data.position.y) + sprite.global_position
		else:
			pass
