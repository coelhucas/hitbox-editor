extends CanvasItem

onready var animation_player: AnimationPlayer = $CurrentSprite/Player/AnimationPlayer
onready var box_scene: PackedScene = preload("res://Scenes/HitBox.tscn")

const GRID_LINE_SIZE: int = 160
export var GRID_COLOR: Color
export var BACKGROUND_COLOR: Color

const ZOOM_AMOUNT: int = 2
const CAM_SPEED: float = 25.0
const MAX_ZOOM_OUT: Vector2 = Vector2(1, 1)


var player
var tile_size: int = 1
var grid_ready: bool = false
var can_zoom: bool = true

var boxes
var current_boxes: Array

var old_animation_position: float = 0.0
var prev_frame: int = 0

func _ready():
	player = get_tree().get_root().get_node("Canvas/CurrentSprite/Player")
	boxes = get_tree().get_root().get_node("Canvas/Boxes")
	current_boxes = boxes.get_children()

func _process(delta):
	
	if $CurrentSprite/Player/AnimationPlayer.is_playing() and int(round($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10)) != prev_frame:
		display_updated_data()
		prev_frame = int(round($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10))
	
	$Cursor.rect_position = get_global_mouse_position()
	
	if Input.is_action_pressed("cam_down"):
		$Camera2D.position.y += CAM_SPEED * $Camera2D.zoom.x
	if Input.is_action_pressed("cam_up"):
		$Camera2D.position.y -= CAM_SPEED * $Camera2D.zoom.x
	if Input.is_action_pressed("cam_right"):
		$Camera2D.position.x += CAM_SPEED * $Camera2D.zoom.x
	if Input.is_action_pressed("cam_left"):
		$Camera2D.position.x -= CAM_SPEED * $Camera2D.zoom.x
	
	if Input.is_action_just_pressed("ui_right"):
		update_frame($CurrentSprite/Player/AnimationPlayer.current_animation_position + 0.1)
		
	elif Input.is_action_just_pressed("ui_left"):
		update_frame($CurrentSprite/Player/AnimationPlayer.current_animation_position - 0.1)
	
	if old_animation_position != $CurrentSprite/Player/AnimationPlayer.current_animation_position:
		$CanvasLayer/Header/Separator/CurrentFrameLabel.text = "Frame: " + str(int($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10))
		old_animation_position = $CurrentSprite/Player/AnimationPlayer.current_animation_position		


func update_frame(next_position: float):
	var tmp_current_boxes = boxes.get_children()
	
	if current_boxes != tmp_current_boxes:
		$CanvasLayer.save_data($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10)
	
	if next_position > $CurrentSprite/Player/AnimationPlayer.current_animation_length:
		$CurrentSprite/Player/AnimationPlayer.seek(0, true)
	elif next_position < 0:
		$CurrentSprite/Player/AnimationPlayer.seek($CurrentSprite/Player/AnimationPlayer.current_animation_length)
	else:
		$CurrentSprite/Player/AnimationPlayer.seek(next_position, true)
	
	display_updated_data()
	
func display_updated_data():
	for box in boxes.get_children():
		box.queue_free()
	
	current_boxes = boxes.get_children()
	
	
	if Utils.boxes_data.has($CurrentSprite/Player/AnimationPlayer.assigned_animation):
		if Utils.boxes_data[$CurrentSprite/Player/AnimationPlayer.assigned_animation].has(str(round($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10))):
			var current_frame_data = Utils.boxes_data[$CurrentSprite/Player/AnimationPlayer.assigned_animation][str(int(round($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10)))]
			for box in current_frame_data:
				var new_box = box_scene.instance()
				var new_box_collider = new_box.get_node("Collider")
				new_box.hit_type = box.type
				boxes.add_child(new_box)
				new_box_collider.shape.extents = Vector2(box.dimensions.x, box.dimensions.y)
				new_box.rect_global_position = Vector2(box.position.x, box.position.y) + player.global_position

func _input(e):
	if (e is InputEventMouseButton and not $CanvasLayer/Header/SaveFile.visible) and not $CanvasLayer/Header/OpenFile.visible:
		if e.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		
		if e.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()

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
