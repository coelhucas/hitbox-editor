extends CanvasItem

onready var animation_player: AnimationPlayer = $CurrentSprite/AnimationPlayer
onready var box_scene: PackedScene = preload("res://Scenes/HitBox.tscn")

const GRID_LINE_SIZE: int = 160
export var GRID_COLOR: Color
export var BACKGROUND_COLOR: Color

const ZOOM_AMOUNT: int = 2
const CAM_SPEED: float = 25.0
const MAX_ZOOM_OUT: Vector2 = Vector2(1, 1)


var sprite
var tile_size: int = 1
var grid_ready: bool = false
var can_zoom: bool = true
var first_camera_drag: bool = true

var camera_offset: Vector2

var prev_mouse_pos: Vector2

var boxes
var current_boxes: Array
var prev_boxes: Array

var old_animation_position: float = 0.0
var prev_frame: int = 0

func _ready():
	sprite = get_tree().get_root().get_node("Canvas/CurrentSprite")
	boxes = get_tree().get_root().get_node("Canvas/Boxes")
	current_boxes = boxes.get_children()

func _process(delta):
	
	if prev_mouse_pos != get_global_mouse_position():
		mouse_update()
		
	prev_mouse_pos = get_global_mouse_position()
	
	if $CurrentSprite/AnimationPlayer.is_playing() and int(round($CurrentSprite/AnimationPlayer.current_animation_position * 10)) != prev_frame:
		display_updated_data()
		prev_frame = int(round($CurrentSprite/AnimationPlayer.current_animation_position * 10))
	
	$Cursor.rect_position = get_global_mouse_position()

	if Input.is_action_just_pressed("ui_right"):
		update_frame($CurrentSprite/AnimationPlayer.current_animation_position + 0.1)
		
	elif Input.is_action_just_pressed("ui_left"):
		update_frame($CurrentSprite/AnimationPlayer.current_animation_position - 0.1)
	
	if Input.is_action_pressed("mouse_middle") and first_camera_drag:
		camera_offset = get_global_mouse_position() - $Camera2D.global_position
		first_camera_drag = false
	
	if Input.is_action_just_released("mouse_middle") and not first_camera_drag:
		camera_offset = Vector2(0, 0)
		first_camera_drag = true
	
	if old_animation_position != $CurrentSprite/AnimationPlayer.current_animation_position:
		$CanvasLayer/Header/Separator/CurrentFrameLabel.text = "Frame: " + str(int($CurrentSprite/AnimationPlayer.current_animation_position * 10))
		old_animation_position = $CurrentSprite/AnimationPlayer.current_animation_position		

func mouse_update():
	if not first_camera_drag:
		pass

func update_frame(next_position: float):
	$CanvasLayer.save_data($CurrentSprite/AnimationPlayer.current_animation_position * 10)
	
	for box in $Boxes.get_children():
		box.is_focused = false
	
	if next_position > $CurrentSprite/AnimationPlayer.current_animation_length:
		$CurrentSprite/AnimationPlayer.seek(0, true)
	elif next_position < 0:
		$CurrentSprite/AnimationPlayer.seek($CurrentSprite/AnimationPlayer.current_animation_length)
	else:
		$CurrentSprite/AnimationPlayer.seek(next_position, true)
	
	display_updated_data()
	
func display_updated_data():
	for box in boxes.get_children():
		box.queue_free()
	
	if Utils.boxes_data.has($CurrentSprite/AnimationPlayer.assigned_animation):
		if Utils.boxes_data[$CurrentSprite/AnimationPlayer.assigned_animation].has(str(round($CurrentSprite/AnimationPlayer.current_animation_position * 10))):
			var current_frame_data = Utils.boxes_data[$CurrentSprite/AnimationPlayer.assigned_animation][str(int(round($CurrentSprite/AnimationPlayer.current_animation_position * 10)))]
			for box in current_frame_data:
				var new_box = box_scene.instance()
				var new_box_collider = new_box.get_node("Collider")
				new_box.hit_type = box.type
				new_box.name = "LOADED-HBOX" + str(boxes.get_child_count())
				boxes.add_child(new_box)
				new_box_collider.shape.extents = Vector2(box.dimensions.x, box.dimensions.y)
				new_box.rect_global_position = Vector2(box.position.x, box.position.y) + sprite.global_position
	
	prev_boxes = boxes.get_children()
	current_boxes = boxes.get_children()

func _input(e):
	if (e is InputEventMouseButton and not $CanvasLayer/Header/SaveFile.visible) and not $CanvasLayer/Header/OpenFile.visible:
		if e.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		
		if e.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
	elif e is InputEventMouseMotion and not first_camera_drag:
		$Camera2D.global_position -= e.relative * $Camera2D.zoom.y * 2
		pass

func zoom_in():
	if $Camera2D.zoom.x > 0.0625 and can_zoom:
		can_zoom = false
		$ZoomDelay.start()
		$Camera2D.global_position = get_global_mouse_position()
		$Camera2D.zoom = $Camera2D.zoom / ZOOM_AMOUNT
	
func zoom_out():
	if $Camera2D.zoom.x < 0.25 and can_zoom:
		can_zoom = false
		$ZoomDelay.start()
		$Camera2D.global_position = get_global_mouse_position()
		$Camera2D.zoom = $Camera2D.zoom * ZOOM_AMOUNT

func _draw():
	if not grid_ready:
		var rect: Rect2 = Rect2(Vector2(0, 0), Vector2(300, 200))
		draw_rect(rect, BACKGROUND_COLOR)
		for i in range(GRID_LINE_SIZE):
			if i % tile_size == 0:
				draw_line(Vector2(i, 0), Vector2(i, GRID_LINE_SIZE), GRID_COLOR)
		for i in range(GRID_LINE_SIZE):
			if i % tile_size == 0:
				draw_line(Vector2(0, i), Vector2(GRID_LINE_SIZE, i), GRID_COLOR)
		
		grid_ready = true

func _on_ZoomDelay_timeout():
	can_zoom = true


func _on_Sccreen_resized():
	grid_ready = false


func _on_Area2D_body_entered(body):
	print("PINTO")
