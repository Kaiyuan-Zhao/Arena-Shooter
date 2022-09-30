extends "res://Items/Item.gd"

export(Resource) var projectile
export(int) var spray = 5
export(int) var projectileCount = 1
export(int) var pushBack = 5
export(float) var damageMultiplier = 1.0

onready var projectileSpawn = $ProjectileSpawn
onready var tip = $Tip
var aim_direction = Vector2.RIGHT
var rng = RandomNumberGenerator.new()

signal knockback(power, direction)

func fire():
	aim_direction = projectileSpawn.global_position.direction_to(tip.global_position)
	for i in projectileCount:
		var p = projectile.instance()
		p.direction = aim_direction.rotated(deg2rad(rng.randf_range(-spray, spray)))
		p.global_transform = projectileSpawn.global_transform
		get_tree().current_scene.add_child(p)
		p.hitbox.damage = p.hitbox.base_damage * level* damageMultiplier
		p.hitbox.set_collision_mask_bit(friendlyMask, false)
		emit_signal("knockback", pushBack, -aim_direction)
