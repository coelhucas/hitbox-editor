extends Node2D

export var hitbox_color: Color
export var hurtbox_color: Color

var vertical_resizing: bool = false
var horizontal_resizing: bool = false

var first_drag: bool = false
var start_position: Vector2
var prev_mouse_pos: Vector2

var is_hovered: bool = false
var dragging_box: bool = false

enum HIT_TYPE { Hitbox, Hurtbox }
var hit_type = HIT_TYPE.Hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	change_hit_type()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if is_hovered and Input.is_action_just_pressed("mouse_right"):
		change_hit_type()
	
	if prev_mouse_pos != get_global_mouse_position():
		handle_update(delta)

func handle_update(delta):
	prev_mouse_pos = get_global_mouse_position()
	
	$Guide.rect_global_position.x = int($Left.rect_global_position.x) + 1.5
	$Guide.rect_global_position.y = int($Up.rect_global_position.y) + 1.5
	$Guide.rect_size.y = int(abs($Collider.shape.extents.y)) * 2
	$Guide.rect_size.x = int(abs($Collider.shape.extents.x)) * 2
	
	$Up.rect_global_position = Vector2(global_position.x, $Collider.global_position.y - abs($Collider.shape.extents.y))
	$Down.rect_global_position = Vector2(global_position.x, global_position.y + int(abs($Collider.shape.extents.y)))
	
	$Left.rect_global_position = Vector2($Collider.global_position.x - abs($Collider.shape.extents.x), global_position.y)
	$Right.rect_global_position = Vector2($Collider.global_position.x + abs($Collider.shape.extents.x), global_position.y)
	
	
	if is_hovered and Input.is_action_pressed("mouse_left"):
		position = Vector2(int(get_global_mouse_position().x), int(get_global_mouse_position().y))
	
	if vertical_resizing:
		update_collision_shape("vertical")
	
	if horizontal_resizing:
		update_collision_shape("horizontal")

func change_hit_type() -> void:
	if hit_type == HIT_TYPE.Hitbox:
		hit_type = HIT_TYPE.Hurtbox
		$Guide.color = hurtbox_color
	else:
		hit_type = HIT_TYPE.Hitbox
		$Guide.color = hitbox_color
	
func update_collision_shape(axis: String) -> void:
	var obj_shape: ConvexPolygonShape2D = $Collider.shape
	
	if axis == "vertical":
		obj_shape.extents.y = int(get_global_mouse_position().y) - $Collider.global_position.y
	elif axis == "horizontal":
		obj_shape.extents.x = int(get_global_mouse_position().x) - $Collider.global_position.x

func on_up_button_down():
	if not first_drag:
		start_position = $Up.rect_global_position
		first_drag = true
	vertical_resizing = true


func _on_LeftUp_button_up():
	vertical_resizing = false
	first_drag = false


func _on_Down_button_down():
	if not first_drag:
		start_position = $Down.rect_global_position
		first_drag = true
	vertical_resizing = true


func _on_Down_button_up():
	vertical_resizing = false


func _on_Guide_mouse_entered():
	is_hovered = true

func _on_Guide_mouse_exited():
	is_hovered = false


func _on_Left_button_down():
	horizontal_resizing = true


func _on_Left_button_up():
	horizontal_resizing = false


func _on_Right_button_down():
	horizontal_resizing = true


func _on_Right_button_up():
	horizontal_resizing = false
