extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_stream(audio_stream: AudioStream):
	stream = audio_stream
	play()

func play_package(music_package: MusicPackage):
	if music_package == null or music_package.stream == null:
		printerr("ERROR: NO AUDIO STREAM IN MUSIC PACKAGE")
		return
	
	stop()
	#volume_db = music_package.volume_db
	pitch_scale = music_package.pitch
	stream = music_package.stream
	play(music_package.start_position)
