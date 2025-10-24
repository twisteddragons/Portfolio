extends AudioStreamPlayer

const demo_tracks: Array[Resource] = [
	# King Gizzard
	preload("uid://mi21xf65fkdm"), # 05
	preload("uid://ddme2nd5c41up"),# 07
	preload("uid://bg8qtfyeylml4") # 09
]

var all_tracks: Array[Resource] = [
	preload("res://music/KingGizzard/10 The Fourth Colour.wav"),# 0
	preload("res://music/KingGizzard/KingGlizzyEdits/yeehaw_riff.mp3") # 01
	]

var ambience: Array[Resource] = [
	# wind 1
	preload("uid://h7v82nm7xt3v"), # 00
	# wind 2
	preload("uid://c7kwckqjfrvyu") # 02
]

@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer
var playing_track:int

##Saves AudioStreamPlayer node and connects signals
func init(_new_player:AudioStreamPlayer) -> void:
	self.connect("finished", Callable(self, "next_track"))

func set_volume(new_vol:float) -> void:
	volume_db = new_vol

##Chooses an available track randomly
func random_track() -> void:
	play_track(randi_range(0, demo_tracks.size()-1))

##Plays the next track in the list; wraps to top.
func next_track() -> void:
	play_track(playing_track%demo_tracks.size()-1)

##Plays the specified track number if available
func play_track(number:int) -> void:
	if number > demo_tracks.size()-1:
		print("Tried to play non-existant track: " + str(number))
		return
	playing_track = number%demo_tracks.size()
	stream = demo_tracks[playing_track]
	play()

func stop_track():
	stop()


func force_play_track(song_index: int) -> void:
	if song_index < -1 or song_index >= all_tracks.size():
		push_error("Invalid song index: %d" % song_index)
		return
	
	stop_track()
	stream = all_tracks[song_index]
	play()


func play_ambience(amb_index: int):
	if amb_index < -1 or amb_index >= all_tracks.size():
		push_error("Invalid amb index: %d" % amb_index)
		return
	
	print("playing amb")
	ambience_player.stop()
	ambience_player.stream = ambience[amb_index]
	ambience_player.play()
