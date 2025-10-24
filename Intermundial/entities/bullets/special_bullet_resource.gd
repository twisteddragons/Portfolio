extends Resource
class_name SpecialBullet

@export_group("Configuration")
## Bullet type
@export var bullet_type:Collections.BULLET_TYPES = Collections.BULLET_TYPES.BASIC
## Fire type
@export var fire_type:Collections.FIRE_TYPES = Collections.FIRE_TYPES.SINGLE_HITSCAN
## If projectile, how much gravity?
@export var projectile_gravity_scale:float = 0.0
## If projectile, how fast?
@export var projectile_speed:float = 70.0
## Damage to deal to enemies
@export var damage:int = 0
@export_subgroup("Effect Scripts")
## Effects that occur when the bullet hits an effectable target
@export var effect_script_queue:Array[Script]
## Effects that occur when the bullet lands
@export var regular_effect_script_queue:Array[Script]
## Effects that occur when the bullet is fired
@export var on_fire_effect_script_queue:Array[Script]
@export_group("Sprites and Sound")
## Side view
@export var side_sprite:Texture2D
## Back view
@export var back_sprite:Texture2D
## Custom fire sound (leave empty for default)
@export var fire_sound_uid:String
## Iterates through the Effect Script Queue, calling each effect. The original
## caller and `self` are passed into each effect. To call methods in the script,
## a child node is created and the script is attached, for each script in the
## queue.
## TODO: Combine these two functions?
func get_effect(caller:Node3D, calling_bullet:Bullet) -> void:
	for e in effect_script_queue:
		var e_child = Node.new()
		e_child.name = e.resource_name
		e_child.set_script(e)
		calling_bullet.add_child(e_child)
		assert(e_child.has_method("effect"),"Invalid script ["+
			str(e.resource_name)+
			"] passed into bullet resource ["+
			Collections.get_bullet_type(bullet_type)+
			"]")
		e_child.effect(caller, self)

## Does the same as above, but for regular effects (i.e. effects that trigger
## when the bullet hits anything)
func get_regular_effect(caller:Node3D, calling_bullet:Bullet) -> void:
	for i in range(regular_effect_script_queue.size()):
		var e = regular_effect_script_queue[i]
		var e_child = Node.new()
		e_child.set_script(e)
		calling_bullet.add_child(e_child)
		# I think theres an issue here where effect is being called before the child is being added to the tree,
		# and hence you cant locate a group within the effect
		assert(e_child.has_method("effect"),"Invalid script ["+
			str(e.resource_name)+
			"] passed into bullet resource ["+
			Collections.get_bullet_type(bullet_type)+
			"]")
		e_child.effect(caller, self)
		
func get_on_fire_effect(calling_bullet:Bullet) -> void:
	for i in range(on_fire_effect_script_queue.size()):
		var e = on_fire_effect_script_queue[i]
		var e_child = Node.new()
		e_child.set_script(e)
		calling_bullet.add_child(e_child)
		# I think theres an issue here where effect is being called before the child is being added to the tree,
		# and hence you cant locate a group within the effect
		assert(e_child.has_method("effect"),"Invalid script ["+
			str(e.resource_name)+
			"] passed into bullet resource ["+
			Collections.get_bullet_type(bullet_type)+
			"]")
		e_child.effect(null, self)
