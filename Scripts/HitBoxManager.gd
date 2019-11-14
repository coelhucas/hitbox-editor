extends Node2D

var dragging_left_up: bool = false
var dragging_left_down: bool = false
var dragging_right_up: bool = false
var dragging_right_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging_left_up:
		$LeftUp.rect_global_position = get_global_mouse_position()
		var new_shape: ConvexPolygonShape2D = get_new_collision_shape($LeftUp.rect_position, 0)
		pass

func get_new_collision_shape(position: Vector2, index: int) -> ConvexPolygonShape2D:
	var polygon_shape: ConvexPolygonShape2D = $Collider.shape
	
	polygon_shape.points[index] = position
	
	return polygon_shape

func _on_LeftUp_button_down():
	dragging_left_up = true


func _on_LeftUp_button_up():
	dragging_left_up = false
