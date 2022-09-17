extends "res://Enemies/BasicEnemyBody.gd"

export(int) var comfortable_distance = 196

var threshold = 32

onready var detectionShape = $DetectionZone/CollisionShape2D

signal attack

func chaseAlgorithm(delta):
	if detectionZone.can_see_bodies():
		detectionShape.scale = Vector2(2,2)
		emit_signal("attack")
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
		emit_signal("attack")
		if global_position.distance_to(player.global_position) > comfortable_distance:
			accelerate_towards_point(player.global_position, delta)
			look_at(player.global_position)
	else:
		detectionShape.scale = Vector2(1,1)
		state = IDLE
