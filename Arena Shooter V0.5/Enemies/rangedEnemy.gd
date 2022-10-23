extends "res://Enemies/BasicEnemy.gd"

export(int) var comfortable_distance = 196

onready var detectionShape = $DetectionZone/CollisionShape2D

func _ready():
	weapon = weaponScene.instance()
	call_deferred("add_child",weapon)
	yield(weapon, "ready")
	weapon.friendlyMask = layer
	weapon.level = level
	var isPiercing = (generateNum(0.02) >= 1)
	rng.randomize()
	if weapon.initalized == false:
		weapon.initalizeStats([level, min(generateNum(0.3, level)+weapon.projectileCount, weapon.maxProjectileCount), (isPiercing or weapon.piercing) and weapon.maxPiercing])
		weapon.initalized = true

func chaseAlgorithm(delta):
	if detectionZone.can_see_bodies():
		detectionShape.scale = Vector2(2,2)
		weapon.using = true
		if global_position.distance_to(player.global_position) > comfortable_distance:
			accelerate_towards_point(player.global_position, delta)
		else:
			if (comfortable_distance - global_position.distance_to(player.global_position)) > threshold:
				accelerate_away_from_point(player.global_position, delta)
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			look_at(player.global_position)
		agro = false	
	elif agro:
		detectionShape.scale = Vector2(2,2)
		weapon.using = true 
		if global_position.distance_to(player.global_position) > comfortable_distance:
			accelerate_towards_point(player.global_position, delta)
			look_at(player.global_position)
	else:
		detectionShape.scale = Vector2(1,1)
		weapon.using = false
		state = IDLE
