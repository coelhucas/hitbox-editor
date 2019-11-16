extends CanvasLayer

onready var box: PackedScene = preload("res://Scenes/HitBox.tscn")

var animation_player: AnimationPlayer

var loaded_animations: bool = false

func _ready():
	$Header/Separator/NewBtn.connect("pressed", self, "_create_box")
	pass
	
func _process(delta):
	if not loaded_animations:
		animation_player = get_parent().animation_player
		for animation in animation_player.get_animation_list():
			$Header/Separator/AnimationSelector.add_item(animation)
		
		loaded_animations = true
		

func _on_AnimationSelector_item_selected(ID):
	animation_player.stop()
	animation_player.current_animation = animation_player.get_animation_list()[ID]
	animation_player.play()


func _on_PlayBtn_pressed():
	animation_player.play()


func _on_StopBtn_pressed():
	animation_player.stop()

func _create_box():
	var box_instance = box.instance()
	var boxes_parent = get_tree().get_root().get_node("Canvas/Boxes")
	box_instance.name = "HBOX" + str(boxes_parent.get_child_count())
	boxes_parent.add_child(box_instance)
	box_instance.global_position = get_tree().get_root().get_node("Canvas/MiddlePoint").global_position