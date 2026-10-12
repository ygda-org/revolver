extends Resource
class_name MusicSettings

## plays once on start, leave empty to skip
@export var intro_stream: AudioStream
## loops, leave empty to not loop
@export var loop_stream: AudioStream
## volume adjustment, in decibels
@export var volume: float
