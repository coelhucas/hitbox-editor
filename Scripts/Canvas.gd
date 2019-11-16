extends CanvasItem

onready var animation_player: AnimationPlayer = $CurrentSprite/Player/AnimationPlayer

const GRID_LINE_SIZE: int = 160
export var GRID_COLOR: Color
export var BACKGROUND_COLOR: Color

const ZOOM_AMOUNT: int = 2
const CAM_SPEED: float = 25.0
const MAX_ZOOM_OUT: Vector2 = Vector2(1, 1)

var tile_size: int = 1
var grid_ready: bool = false
var can_zoom: bool = true

var old_animation_position: float = 0.0

func _process(delta):
	
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
		$CurrentSprite/Player/AnimationPlayer.seek($CurrentSprite/Player/AnimationPlayer.current_animation_position + 0.1, true)
		
	elif Input.is_action_just_pressed("ui_left"):
		$CurrentSprite/Player/AnimationPlayer.seek($CurrentSprite/Player/AnimationPlayer.current_animation_position - 0.1, true)
	
	if old_animation_position != $CurrentSprite/Player/AnimationPlayer.current_animation_position:
		$CanvasLayer/Header/Separator/CurrentFrameLabel.text = "Frame: " + str(int($CurrentSprite/Player/AnimationPlayer.current_animation_position * 10))
		old_animation_position = $CurrentSprite/Player/AnimationPlayer.current_animation_position		

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(e):
	if (e is InputEventMouseButton):
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
		print(1 / $Camera2D.zoom.x)
	
func zoom_out():
	if $Camera2D.zoom.x < 0.25 and can_zoom:
		can_zoom = false
		$ZoomDelay.start()
		$Camera2D.global_position = get_global_mouse_position()
		$Camera2D.zoom = $Camera2D.zoom * ZOOM_AMOUNT
		print(1 / $Camera2D.zoom.x)

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
