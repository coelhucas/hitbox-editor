extends Node2D

export var hitbox_color: Color
export var hurtbox_color: Color

var vertical_resizing: bool = false
var horizontal_resizing: bool = false

var first_drag: bool = false
var start_position: Vector2
var prev_mouse_pos: Vector2

var first_box_click: bool = false

var offset_x
var offset_y

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
		if hit_type == HIT_TYPE.Hitbox:
			change_hit_type(HIT_TYPE.Hurtbox)
		else:
			change_hit_type(HIT_TYPE.Hitbox)
	
	if prev_mouse_pos != get_global_mouse_position():
		handle_update(delta)
	
	if first_box_click and Input.is_action_just_released("mouse_left"):
		first_box_click = false
		offset_x = 0
		offset_y = 0
	
	if is_hovered and Input.is_action_pressed("mouse_left"):
		if not first_box_click:
			offset_x = get_global_mouse_position().x - global_position.x
			offset_y = get_global_mouse_position().y - global_position.y
			first_box_click = true

func handle_update(delta):
	prev_mouse_pos = get_global_mouse_position()
	
	$Guide.rect_global_position.x = int($Collider.global_position.x) - $Collider.shape.extents.x
	$Guide.rect_global_position.y = int($Collider.global_position.y) - $Collider.shape.extents.y + 1
	$Guide.rect_size.y = int(abs($Collider.shape.extents.y) * 2)
	$Guide.rect_size.x = int(abs($Collider.shape.extents.x) * 2)
	
	$Up.rect_position = Vector2(-0.5, $Collider.position.y - int(abs($Collider.shape.extents.y)) - 1)
	$Down.rect_position = Vector2(-0.5, $Collider.position.y + int(abs($Collider.shape.extents.y)) - 1)
	
	$Left.rect_position = Vector2($Collider.position.x - int(abs($Collider.shape.extents.x)) - 1, -0.5)
	$Right.rect_position = Vector2($Collider.position.x + int(abs($Collider.shape.extents.x)) - 1, -0.5)
	
		
	if first_box_click:
		position = Vector2(int(get_global_mouse_position().x - offset_x), int(get_global_mouse_position().y - offset_y))
#		position = Vector2(int(get_global_mouse_position().x), int(get_global_mouse_position().y))
		
	
	if vertical_resizing:
		update_collision_shape("vertical")
	
	if horizontal_resizing:
		update_collision_shape("horizontal")

func change_hit_type(which = HIT_TYPE.Hurtbox) -> void:
	hit_type = which
	
	if hit_type == HIT_TYPE.Hitbox:
		$Guide.color = hurtbox_color
	else:
		$Guide.color = hitbox_color
	
func update_collision_shape(axis: String) -> void:
	var obj_shape: ConvexPolygonShape2D = $Collider.shape
	
	if axis == "vertical":
		obj_shape.extents.y = int(abs(get_global_mouse_position().y - $Collider.global_position.y))
		print(obj_shape.extents.y)
	elif axis == "horizontal":
		obj_shape.extents.x = abs(int(get_global_mouse_position().x) - $Collider.global_position.x)

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
