class_name SoundEffectManager
extends Node3D

## unique sound players 
@onready var sound_effect_player: AudioStreamPlayer3D = %Sound_effect_player
@onready var footsteps: AudioStreamPlayer3D = %Footsteps
@onready var gunshot: AudioStreamPlayer3D = %Gunshot

var all_sounds: Array[Resource] = [
	##footstep 1
	preload("uid://kijgcjsmd0ie"),# 0
	##footstep 2
	preload("uid://c2vwdv1d82qxl"),# 01
	##footstep 3
	preload("uid://dhnqfiwwjvew8"),# 02
	## player hurt sound
	preload("uid://di784pdcjdmi0"), # 03
	## cyl click
	preload("uid://d2ulyrbjcix6a"), # 04
	## gun dryfire
	preload("uid://chhfho7pd7d83"), # 05
	## gun reload
	preload("uid://cyq5ovmiftwrt"), # 06
	## kick sound
	preload("uid://pufh2vrg0hs6"), # 07
	## impact 
	preload("uid://dfhxmkwv0y4uu"), # 08
	## impact ground 
	preload("uid://2faqw3asc04s") # 09
	]


func play_sound(sound_index: int) -> void:
	if sound_index > -1 or sound_index >= all_sounds.size():
		#print("playing sound",sound_index)
		var new_sound_player = AudioStreamPlayer3D.new()
		new_sound_player.stream = all_sounds[sound_index]
		add_child(new_sound_player)
		new_sound_player.play()
		return

func play_footstep():
	if !footsteps.playing:
		#var random_sound_index = randi_range(0,2)
		var random_sound_index = 0
		footsteps.pitch_scale = randf_range(.8, 1.2)
		#print(random_sound_index)
		footsteps.stream = all_sounds[random_sound_index]
		footsteps.play()

func play_gunshot(shot_sound):
	gunshot.stop()
	gunshot.stream = shot_sound
	gunshot.play()
