class_name ShopScreen
extends CanvasItem


@onready var reserve_container: HBoxContainer = %ReserveContainer
@onready var cyl_background: Panel = %cyl_background
@onready var bullet_shop_container: HBoxContainer = %bullet_shop_container
@onready var money_label: Label = %MoneyLabel
@onready var paralax_effect: Control = %ParalaxEffect


const SHOP_SLOT = preload("uid://vvad0xw4rnvu")
const SLOTSCENE = preload("res://scenes/UpgradeScreen/slot.tscn")


@export var Shop_size : int = 5

# paralax effect
@export var max_offset: Vector2
@export var smoothing: float = 2


var money : int = 5

func _ready() -> void:
	initilize_cyl()
	#initilize_reserve()
	initilize_shop()
	update_money()

func _process(delta):
	var center: Vector2 = get_viewport_rect().size / 2.0
	var dist: Vector2 = get_global_mouse_position() - center
	var offset : Vector2 = dist / center
	
	var new_pos: Vector2
	
	new_pos.x = lerp( max_offset.x , - max_offset.x , offset.x)
	new_pos.y = lerp( max_offset.y , - max_offset.y , offset.y)
	
	paralax_effect.position.x = lerp(paralax_effect.position.x , new_pos.x, smoothing * delta)
	paralax_effect.position.y = lerp(paralax_effect.position.y , new_pos.y, smoothing * delta)


func initilize_reserve():
	for b in Collections.full_bullet_reserve:
		if not b: continue
		var bullet_type = b
		b.bullet_resource = load(Collections.BULLET_RESOURCES[bullet_type])
		
		var new_bullet = SLOTSCENE.instantiate()
		new_bullet.bullet_data = b
		new_bullet.shop_screen = self
		reserve_container.add_child(new_bullet)

func initilize_cyl():
	var i : int = 0
	for b in Collections.stat_tracker.starting_cylinder_pattern:
		if not b: continue
		
		var bullet_type = b
		var type = load(Collections.BULLET_RESOURCES[bullet_type])
		
		var cyl = cyl_background.get_children()[i]
		i += 1
		
		cyl.shop_screen = self
		cyl.update_slot_data(type)

func initilize_shop():
	for n in Shop_size:
		add_bullet_to_shop()

func add_bullet_to_shop():
	var new_shop_item = SHOP_SLOT.instantiate()
	var all_bullets = Collections.BULLET_TYPES.size()
	var random_selection = randi_range(1, all_bullets )
	var bullet_selection = Collections.BULLET_RESOURCES[random_selection -1]
	var bullet_resource = load(bullet_selection)
	new_shop_item.shop_screen = self
	new_shop_item.bullet_data = bullet_resource
	bullet_shop_container.add_child(new_shop_item)


func add_bullet_to_res(data):
	var new_bullet_slot = SLOTSCENE.instantiate()
	new_bullet_slot.bullet_data = data
	new_bullet_slot.shop_screen = self
	reserve_container.add_child(new_bullet_slot)
	

func update_money():
	money_label.text = str("Funds: ", money)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_tab"):
		leave_shop()


func leave_shop():
	update_player_inventory()
	print(Collections.stat_tracker.starting_cylinder_pattern)


func update_player_inventory():
	Collections.stat_tracker.starting_cylinder_pattern = []
	
	for c in cyl_background.get_children():
		if not c.bullet_data :
			var basic_bullet = Collections.BULLET_TYPES.BASIC
			Collections.stat_tracker.starting_cylinder_pattern.append(basic_bullet)
			continue
		
		var cyl_bullet = c.bullet_data.bullet_type
		Collections.stat_tracker.starting_cylinder_pattern.append(cyl_bullet)
		
	


func _on_done_button_pressed() -> void:
	Global.game_controller.change_3d_scene("uid://d8txut18hr2s")
	Global.game_controller.remove_gui_scene()
