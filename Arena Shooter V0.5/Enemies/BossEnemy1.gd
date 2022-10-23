extends "res://Enemies/Enemy.gd"

var shieldThreshold = 2
var shields = preload("res://Enemies/Shields.tscn")
var shieldProjectile = preload("res://Items/ShieldProjectile.tscn")
var s
var shieldsRemaining = []
var phase2 = false
var canFire = true

onready var timer = $Timer
onready var sprite = $Sprite

func _ready():
	world = get_tree().get_root().get_node("World")
	if not world.ready:
		yield(world, "ready")
	s = shields.instance()
	get_parent().add_child(s)
	shieldsRemaining = s.get_children()
	
func _physics_process(delta):
	s.global_position = global_position
	updateMotion(delta)
	var additionRotation = range_lerp(stats.health, stats.max_health, 0, 1, 10)
	stats.MAX_SPEED = range_lerp(stats.health, stats.max_health, 0, 100, 400)
	stats.damage = ceil(range_lerp(stats.health, stats.max_health, 0, 250, 750))
	if (stats.health*1.0)/stats.max_health <= 0.5:
		phase2 = true
	
	hitbox.damage = stats.damage
	if detectionZone.can_see_bodies():
		for i in s.get_children():
			if i.shot:
				shieldsRemaining.erase(i)
			elif not shieldsRemaining.has(i):
				shieldsRemaining.append(i)
				
		for i in s.get_children():
			i.rotation_degrees += additionRotation
			if i.rotation_degrees >= 360:
				i.rotation_degrees -= 360
			if phase2:
				sprite.self_modulate.g = 0
				sprite.self_modulate.b = 0
				var aim_direction = i.position2d.global_position.direction_to(i.position2d2.global_position)
				var direction_to_player = i.position2d.global_position.direction_to(player.global_position)
				if i.visible:
					if abs(rad2deg(aim_direction.angle_to(direction_to_player))-shieldThreshold) <= shieldThreshold and not i.shot and shieldsRemaining.size() >= 2 and canFire:
						i.set_shot()
						fire(i)
						canFire = false
						timer.start(0.25)

func kill():
	UI.queue_free()
	s.queue_free()
	queue_free()
	
func _on_Stats_no_health():
	if not dead:
		dropLoot(30)
	world.camera.shake(200)
	dead = true
	UI.queue_free()
	s.queue_free()
	queue_free()
	
func fire(node):
	var aim_direction = node.position2d.global_position.direction_to(node.position2d2.global_position)
	for i in get_child_count():
		var p = shieldProjectile.instance()
		p.global_transform = node.position2d.global_transform
		p.direction = aim_direction
		p.piercing = true
		get_tree().current_scene.add_child(p)
		p.hitbox.damage = p.hitbox.base_damage
		p.hitbox.set_collision_mask_bit(layer, false)


func _on_Timer_timeout():
	canFire = true
