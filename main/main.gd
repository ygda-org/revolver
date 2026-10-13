extends Node2D

func _ready() -> void:
	if randi_range(0, 1):
		MusicPlayer.start(MusicPlayer.Labels.BATTLE_1)
	else:
		MusicPlayer.start(MusicPlayer.Labels.BATTLE_2)
