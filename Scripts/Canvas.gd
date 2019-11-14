extends CanvasItem

onready var animation_player: AnimationPlayer = $CurrentSprite/Alala_walk/AnimationPlayer

const GRID_LINE_SIZE: int = 500
export var GRID_COLOR: Color

const ZOOM_AMOUNT: int = 2
const CAM_SPEED: float = 10.0
const MAX_ZOOM_OUT: Vector2 = Vector2(1, 1)

var tile_size: int = 1
var grid_ready: bool = false
var can_zoom: bool = true

func _process(delta):
	
	$Cursor.rect_position = get_global_mouse_position()
	
	if Input.is_action_pressed("cam_down"):
		$Camera2D.position.y += CAM_SPEED
	if Input.is_action_pressed("cam_up"):
		$Camera2D.position.y -= CAM_SPEED
	if Input.is_action_pressed("cam_right"):
		$Camera2D.position.x += CAM_SPEED
	if Input.is_action_pressed("cam_left"):
		$Camera2D.position.x -= CAM_SPEED
	
	if Input.is_action_just_pressed("ui_right"):
		$CurrentSprite/Alala_walk.frame += 1
		
		if $CurrentSprite/Alala_walk.frame + 1 > $CurrentSprite/Alala_walk.hframes - 1:
			$CurrentSprite/Alala_walk.frame = 0
	elif Input.is_action_just_pressed("ui_left"):
		$CurrentSprite/Alala_walk.frame -= 1

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
		$Camera2D.global_position = $MiddlePoint.global_position
		$Camera2D.zoom = $Camera2D.zoom / ZOOM_AMOUNT
		print(1 / $Camera2D.zoom.x)
	
func zoom_out():
	if $Camera2D.zoom.x < 0.25 and can_zoom:
		can_zoom = false
		$ZoomDelay.start()
		$Camera2D.global_position = $MiddlePoint.global_position
		$Camera2D.zoom = $Camera2D.zoom * ZOOM_AMOUNT
		print(1 / $Camera2D.zoom.x)

func _draw():
	if not grid_ready:
		for i in range(GRID_LINE_SIZE):
			if i % tile_size == 0:
				draw_line(Vector2(i, 0), Vector2(i, GRID_LINE_SIZE), GRID_COLOR)
		for i in range(GRID_LINE_SIZE):
			if i % tile_size == 0:
				draw_line(Vector2(0, i), Vector2(GRID_LINE_SIZE, i), GRID_COLOR)
		
		grid_ready = true

func _on_ZoomDelay_timeout():
	can_zoom = true
