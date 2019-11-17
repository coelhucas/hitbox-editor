extends Control

export var hitbox_color: Color
export var hurtbox_color: Color

onready var box_background_texture: Texture = preload("res://Sprites/hitbox-background.png")
onready var selected_box_background_texture: Texture = preload("res://Sprites/hitbox-selected-background.png")

var vertical_resizing: bool = false
var horizontal_resizing: bool = false

var first_drag: bool = false
var start_position: Vector2
var prev_mouse_pos: Vector2

var first_box_click: bool = false

var offset_x
var offset_y

var is_hovered: bool = false
var is_focused: bool = false
var dragging_box: bool = false

enum HIT_TYPE { Hitbox = 0, Hurtbox = 1 }
var hit_type = HIT_TYPE.Hitbox

func _ready():
	
	var collision_shape: RectangleShape2D = RectangleShape2D.new()
	collision_shape.extents.x = 10
	collision_shape.extents.y = 10
	$Collider.shape = collision_shape
	change_hit_type()
	update_selection(box_background_texture, 0.2)
	
	# Mouse enter/Mouse exit
	$Guide.connect("mouse_entered", self, "_drag_area_mouse_entered")
	$Guide.connect("mouse_exited", self, "_drag_area_mouse_exited")
	
	# Button down signals
	$Left.connect("button_down", self, "_left_scaler_down")
	$Up.connect("button_down", self, "_up_scaler_down")
	$Right.connect("button_down", self, "_right_scaler_down")
	$Down.connect("button_down", self, "_down_scaler_down")
	
	# Button up signals
	$Left.connect("button_up", self, "_left_scaler_up")
	$Up.connect("button_up", self, "_up_scaler_up")
	$Right.connect("button_up", self, "_right_scaler_up")
	$Down.connect("button_up", self, "_down_scaler_up")

func _process(delta):
	
	if is_hovered and Input.is_action_pressed("mouse_left"):
		is_focused = true
		update_selection(selected_box_background_texture, 0.5)
		get_parent().move_child(self, get_parent().get_child_count() - 1)
		
		if not first_box_click:
			offset_x = get_global_mouse_position().x - rect_global_position.x
			offset_y = get_global_mouse_position().y - rect_global_position.y
				
			first_box_click = true
			dragging_box = true
		
		for child in get_parent().get_children():
			if child.name != name:
				child.update_selection(box_background_texture, 0.2)
	
	if is_focused and Input.is_action_just_released("mouse_left"):
		is_focused = false
		dragging_box = false
		first_box_click = false
	
	if not is_hovered and Input.is_action_just_pressed("mouse_left"):
		is_focused = false
	
	if is_hovered and Input.is_action_just_pressed("mouse_right"):
		if hit_type == HIT_TYPE.Hitbox:
			change_hit_type(HIT_TYPE.Hurtbox)
		else:
			change_hit_type(HIT_TYPE.Hitbox)
	
	if prev_mouse_pos != get_global_mouse_position():
		handle_update(delta)
	
func handle_update(delta):
	prev_mouse_pos = get_global_mouse_position()
	
	$Guide.rect_global_position.x = int($Collider.global_position.x) - $Collider.shape.extents.x
	$Guide.rect_global_position.y = int($Collider.global_position.y) - $Collider.shape.extents.y
	$Guide.rect_size.y = int(abs($Collider.shape.extents.y) * 2)
	$Guide.rect_size.x = int(abs($Collider.shape.extents.x) * 2)
	
	$Up.rect_position = Vector2(-0.5, $Collider.position.y - int(abs($Collider.shape.extents.y) + 1))
	$Down.rect_position = Vector2(-0.5, $Collider.position.y + int(abs($Collider.shape.extents.y) - 1))
	
	$Left.rect_position = Vector2($Collider.position.x - int(abs($Collider.shape.extents.x) + 1), 0)
	$Right.rect_position = Vector2($Collider.position.x + int(abs($Collider.shape.extents.x) - 1), 0)
	
		
	if dragging_box:
		rect_global_position = Vector2(int(get_global_mouse_position().x - offset_x), int(get_global_mouse_position().y - offset_y))
	
	if vertical_resizing:
		update_collision_shape("vertical")
	
	if horizontal_resizing:
		update_collision_shape("horizontal")

func update_selection(texture: Texture, alpha: float):
	$Guide.texture = texture
	$Guide.modulate.a = alpha
		
func change_hit_type(which = HIT_TYPE.Hurtbox) -> void:
	hit_type = which
	
	if hit_type == HIT_TYPE.Hitbox:
		$Guide.modulate = hurtbox_color
	else:
		$Guide.modulate = hitbox_color
	
	update_selection($Guide.texture, $Guide.modulate.a)
	
func update_collision_shape(axis: String) -> void:
	var obj_shape: ConvexPolygonShape2D = $Collider.shape
	
	if axis == "vertical":
		obj_shape.extents.y = int(abs(get_global_mouse_position().y - $Collider.global_position.y))
		print(obj_shape.extents.y)
	elif axis == "horizontal":
		obj_shape.extents.x = abs(int(get_global_mouse_position().x) - $Collider.global_position.x)

func _up_scaler_down():
	if not first_drag:
		start_position = $Up.rect_global_position
		first_drag = true
	vertical_resizing = true


func _up_scaler_up():
	vertical_resizing = false
	first_drag = false


func _down_scaler_down():
	if not first_drag:
		start_position = $Down.rect_global_position
		first_drag = true
	vertical_resizing = true


func _down_scaler_up():
	vertical_resizing = false

func _left_scaler_down():
	horizontal_resizing = true

func _left_scaler_up():
	horizontal_resizing = false

func _right_scaler_down():
	horizontal_resizing = true

func _right_scaler_up():
	horizontal_resizing = false

func _drag_area_mouse_entered():
	is_hovered = true
	
func _drag_area_mouse_exited():
	is_hovered = false
	first_box_click = false
	dragging_box = false
	offset_x = 0
	offset_y = 0