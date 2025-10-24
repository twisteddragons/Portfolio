class_name YeehawManager
extends Node3D

#func yeehaw_mode():
	#if !yeehaw :
		#walk_speed = 2 * walk_speed
		#yeehaw = true
		#GlobalMusicController.force_play_track(-1)
		#print("entered yeehaw mode")
	#else:
		#pass
