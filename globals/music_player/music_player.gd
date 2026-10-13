extends Node
## the length during which one song will fade out and another will fade in
const FADE_TIME = 1.0
## the current audio stream player
var current_player: AudioStreamPlayer

## fill this dictionary to map all the labels to respective settings
@export var label_to_settings: Dictionary[Labels, MusicSettings]

enum Labels {
	BATTLE_1,
	MENU,
	BATTLE_2,
	SHOP
}

## start track, fadeout is if the current song will decrease in volume before stopping
func start(label: Labels, fadeout:bool=true):
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	var settings: MusicSettings = label_to_settings[label]
	# set initial stream
	if settings.intro_stream:
		new_player.stream = settings.intro_stream
	elif settings.loop_stream:
		new_player.stream = settings.loop_stream
	else:
		print('bro what the heck are you doing')
	# check if can loop
	if settings.loop_stream:
		new_player.finished.connect(_loop_stream.bind(label))
	if fadeout:
		if current_player:
			var out_tween = get_tree().create_tween()
			out_tween.tween_property(current_player, "volume_db", -40.0, FADE_TIME)
			out_tween.tween_callback(current_player.queue_free)
		var in_tween = get_tree().create_tween()
		new_player.volume_db = -40.0
		in_tween.tween_property(new_player, "volume_db", settings.volume, FADE_TIME)
	current_player = new_player
	add_child(current_player)
	current_player.play()

func force_clear_music(with_fade: bool = true):
	for node in get_children():
		if node is AudioStreamPlayer:
			if with_fade:
				var death_tween = get_tree().create_tween()
				death_tween.tween_property(node, "volume_db", -40, FADE_TIME)
				death_tween.tween_callback(node.queue_free)
			else:
				node.queue_free()

func _loop_stream(label: Labels):
	var settings: MusicSettings = label_to_settings[label]
	current_player.stream = settings.loop_stream
	current_player.play()
