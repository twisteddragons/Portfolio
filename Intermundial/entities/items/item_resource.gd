class_name ItemResource
extends Resource

##Data surrounding item that may be needed in several places. (e.g. store, player, enemy maybe)

enum ITEM_RARITY {
	TRASH,
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	SHOP_EXCLUSIVE,
	ITEM_RARITY_SIZE
}

@export var effect_scene: PackedScene 

@export var rarity: ITEM_RARITY = ITEM_RARITY.COMMON
@export var shop_cost: int = 1

#TODO: export sprite data for shop if needed
