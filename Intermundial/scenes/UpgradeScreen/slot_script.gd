class_name Slot
extends PanelContainer

@export var is_cylinder_slot: bool = false

var bullet_data : SpecialBullet
var shop_screen : ShopScreen

@onready var texture_rect: TextureRect = %TextureRect




func _ready() -> void:
	update_display()

func update_slot_data(new_data):
	bullet_data = new_data
	update_display()

func update_display() -> void:
	if bullet_data:
		if is_cylinder_slot:
			texture_rect.texture = bullet_data.back_sprite
		else:
			texture_rect.texture = bullet_data.side_sprite
		
		texture_rect.show()
	else:
		texture_rect.hide()

func _get_drag_data(_pos):
	if not bullet_data:
		return null
	
	var data = {
		"bullet_data": bullet_data,
		"orgin_slot": self
	}
	
	var drag_texture = TextureRect.new()
	drag_texture.texture = bullet_data.side_sprite
	drag_texture.size = Vector2( 150, 150)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
	set_drag_preview(control)
	
	return data

func _can_drop_data(_pos, data):
	return data.has("bullet_data")
	

func _drop_data(_pos , data):
	var orgin = data.orgin_slot
	var old_bullet_data = bullet_data
	if !bullet_data :
		if orgin.is_cylinder_slot:
			bullet_data = data.bullet_data
			orgin.bullet_data = null
			orgin.update_display()
			update_display()
			print("cyl")
		else:
			bullet_data = data.bullet_data
			orgin.queue_free()
			update_display()
			print("cleaning_slot")
	else :
		orgin.bullet_data = old_bullet_data
		bullet_data = data.bullet_data
		orgin.update_display()
		update_display()
		print("swap")



func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Right_click"):
		if is_cylinder_slot:
			if bullet_data:
				var data = bullet_data
				shop_screen.add_bullet_to_res(data)
				bullet_data = null
				update_display()
