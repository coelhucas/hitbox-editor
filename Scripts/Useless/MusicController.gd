extends AudioStreamPlayer

export(Array) var musics: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var sorted_music = musics[randi() & musics.size() - 1]
	stream = sorted_music
	musics = []
	play()
