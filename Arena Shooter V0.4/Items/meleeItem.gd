extends "res://Items/Item.gd"

onready var hitbox = $Hitbox

func _ready():
	hitbox.set_collision_mask_bit(friendlyMask, false)
	emit_signal("ready")
	
func update_level(value):
	level = value
	emit_signal("level_changed", value)
	hitbox.damage = hitbox.base_damage*level
	
