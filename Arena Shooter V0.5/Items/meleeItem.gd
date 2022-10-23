extends "res://Items/Item.gd"

onready var hitbox = $Hitbox

func set_friendlyMask(value):
	if not ready:
		yield(self, "ready")
	friendlyMask = value
	hitbox.set_collision_mask_bit(2, true)
	hitbox.set_collision_mask_bit(4, true)
	hitbox.set_collision_mask_bit(friendlyMask, false)
	
func update_level(value):
	if not ready:
		yield(self, "ready")
	level = value
	emit_signal("level_changed", value)
	hitbox.damage = hitbox.base_damage*level
	
