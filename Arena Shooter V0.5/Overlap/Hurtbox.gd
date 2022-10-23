extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

onready var collisionShape2D = $CollisionShape2D

var invincibilityList = []

func is_invincible_to(area):
	return invincibilityList.has(area)

func set_invincibility(area, duration):
	var timer := Timer.new()
	add_child(timer)
	invincibilityList.append(area)
	timer.start(duration)
	yield(timer, "timeout")
	invincibilityList.erase(area)
	
	
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position
