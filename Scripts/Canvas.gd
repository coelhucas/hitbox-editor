extends CanvasItem

onready var animation_player: AnimationPlayer = $CurrentSprite/AnimationPlayer
onready var box_scene: PackedScene = preload("res://Scenes/HitBox.tscn")

const ANIMATION_SPEED: float = 0.08
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
	get_tree().get_root().connect("size_changed", self, "_on_screen_resized")
	$ContinueAnimation.wait_time = ANIMATION_SPEED
	$ContinueAnimation.connect("timeout", self, "_continue_animation_timeout")
	
	sprite.global_position = $MiddlePoint.global_position

func _process(delta):
	
	if Utils.is_playing and $ContinueAnimation.is_stopped():
		$ContinueAnimation.start()
	elif not Utils.is_playing and not $ContinueAnimation.is_stopped():
		$ContinueAnimation.stop()
		Utils.create_stored_boxes()
	
	if prev_mouse_pos != get_global_mouse_position():
		mouse_update()
		
	prev_mouse_pos = get_global_mouse_position()
	$Cursor.rect_position = get_global_mouse_position()
	
	if $CurrentSprite:
		if Utils.is_playing and int(round($CurrentSprite/AnimationPlayer.current_animation_position * 10)) != prev_frame:
			Utils.create_stored_boxes()
			prev_frame = int(round($CurrentSprite/AnimationPlayer.current_animation_position * 10))
			
		
			if old_animation_position != $CurrentSprite/AnimationPlayer.current_animation_position:
				$CanvasLayer/Header/Separator/CurrentFrameLabel.text = "Frame: " + str(int($CurrentSprite/AnimationPlayer.current_animation_position * 10))
				old_animation_position = $CurrentSprite/AnimationPlayer.current_animation_position		
				
		if Input.is_action_just_pressed("ui_right"):
			Utils.seek_frame($CurrentSprite/AnimationPlayer.current_animation_position + 0.1)
				
		elif Input.is_action_just_pressed("ui_left"):
			Utils.seek_frame($CurrentSprite/AnimationPlayer.current_animation_position - 0.1)
			
	if Input.is_action_pressed("mouse_middle") and first_camera_drag:
		camera_offset = get_global_mouse_position() - $Camera2D.global_position
		first_camera_drag = false
			
	if Input.is_action_just_released("mouse_middle") and not first_camera_drag:
		camera_offset = Vector2(0, 0)
		first_camera_drag = true
			

func mouse_update():
	if not first_camera_drag:
		pass

func _input(e):
	if (e is InputEventMouseButton and not $CanvasLayer/Header/SaveFile.visible) and not $CanvasLayer/Header/OpenFile.visible:
		if e.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		
		if e.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
	
	if e is InputEventMouseMotion and not first_camera_drag:
		$Camera2D.global_position -= e.relative * $Camera2D.zoom.y * 2

func zoom_in():
	if $Camera2D.zoom.x > 0.0625 and can_zoom:
		can_zoom = false
		$ZoomDelay.start()
		$Camera2D.global_position = get_global_mouse_position()
		$Camera2D.zoom = $Camera2D.zoom / ZOOM_AMOUNT
	
func zoom_out():
	if $Camera2D.zoom.x < 0.125 and can_zoom:
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


func _on_screen_resized():
	grid_ready = false

func _continue_animation_timeout():
	if not Utils.is_playing:
		return

	Utils.seek_frame($CurrentSprite/AnimationPlayer.current_animation_position + 0.1)