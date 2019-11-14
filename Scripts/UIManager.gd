extends CanvasLayer

var animation_player: AnimationPlayer

var loaded_animations: bool = false

func _process(delta):
	if not loaded_animations:
		animation_player = get_parent().animation_player
		for animation in animation_player.get_animation_list():
			$AnimationSelector.add_item(animation)
		
		loaded_animations = true
		

func _on_AnimationSelector_item_selected(ID):
	animation_player.stop()
	animation_player.current_animation = animation_player.get_animation_list()[ID]
	animation_player.play()


func _on_PlayBtn_pressed():
	animation_player.play()


func _on_StopBtn_pressed():
	animation_player.stop()
