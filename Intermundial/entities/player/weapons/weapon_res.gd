class_name WeaponResource
extends Resource
## outdated

#@export_category("weapon stats")
#@export var name : StringName
#@export var damage = 10
#
#@export var current_ammo := INF
#@export var mag_ammo := INF
#@export var reserve_ammo := INF
#@export var max_reserve_ammo := INF
#
#@export var autofire : bool = true
#@export var max_fire_rate : float = 50
#
#@export_category("visuals")
#@export var view_model: PackedScene
#@export var view_model_pos : Vector3
#@export var view_model_rot : Vector3
#@export var view_model_scale := Vector3(1,1,1)
#
#@export var idle_anim : String
#@export var equip_anim : String
#@export var shoot_anim : String
#@export var reload_anim : String
#
#@export_category("sounds")
#@export var shoot_sound : AudioStream
#@export var reload_sound : AudioStream
#@export var unequip_sound : AudioStream
#
#
#
##logic
#
#const RAYCAST_DIS : float = 9999
#
#var weapon_manager : WeaponManager
#var last_fire = -9999
#
#var trigger_down := false:
	#set(v):
		#if trigger_down != v:
			#trigger_down = v
			#if trigger_down:
				#on_trigger_down()
			#else:
				#on_trigger_up()
#
#var is_equipped := false:
	#set(v):
		#if is_equipped != v:
			#is_equipped = v
			#if is_equipped:
				#on_equip()
			#else:
				#unequip()
#
#
#func on_trigger_down():
	#if Time.get_ticks_msec() - last_fire > max_fire_rate and current_ammo > 0:
		#fire_shot()
#
#func on_trigger_up():
	#pass
#
#func on_process(_delta):
	#if trigger_down and autofire and Time.get_ticks_msec() - last_fire >= max_fire_rate and current_ammo > 0:
		#fire_shot()
#
#func get_reload() ->int:
	#var attempt_reload = mag_ammo - current_ammo
	#var can_reload = min(attempt_reload,reserve_ammo)
	#return can_reload
#
#
#func on_reload():
	#if reload_anim and weapon_manager.get_anim() == reload_anim:
		#return
	#if get_reload() <= 0:
		#return
	#
	#var cancel_cb = (func():
		#weapon_manager.stop_sound())
	#weapon_manager.play_anim(reload_anim, reload, cancel_cb)
	#weapon_manager.queue_anim(idle_anim)
	#weapon_manager.play_sound(reload_sound)
	#
#
#func reload():
	#var can_reload = get_reload()
	#if can_reload <0:
		#return
	#elif mag_ammo == INF or current_ammo == INF:
		#current_ammo = mag_ammo
	#else:
		#current_ammo += can_reload
		#reserve_ammo -=  can_reload
#
#
#
#
#func on_equip():
	#pass
#
#func unequip():
	#pass
#
#func fire_shot():
	#weapon_manager.play_anim(shoot_anim)
	#weapon_manager.play_sound(shoot_sound)
	#weapon_manager.queue_anim(idle_anim)
	#
	#var raycast = weapon_manager.bullet_raycast
	#raycast.target_position = Vector3(0,0, -abs(RAYCAST_DIS))
	#raycast.force_raycast_update()
	#var bullet_target = raycast.global_transform * raycast.target_position
	#if raycast.is_colliding():
		#var obj = raycast.get_collider()
		#var nrml = raycast.get_collision_normal()
		#var pt = raycast.get_collision_point()
		#bullet_target = pt
		#BulletDecalPool.spawn_bullet_decal(pt,nrml,obj)
		#
		#print(obj)
		#if obj is RigidBody3D:
			#obj.apply_impulse(- nrml * 5.0 / obj.mass, pt - obj.global_position)
		#if obj.has_method("take_damage"):
			#obj.take_damage(self.damage)
		#if obj.is_in_group("enemy_hitbox"):
			#print("hit enemy")
			#obj.hit(damage)
	#
	#weapon_manager.play_muzzle_flash()
	#weapon_manager.make_tracer(bullet_target)
	#
	#last_fire = Time.get_ticks_msec()
	#current_ammo -= 1
