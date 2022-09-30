extends Node

export(int) var base_max_health = 1
export(int) var BASE_MAX_SPEED = 100
export(int) var damage = 10

var max_health = 1 setget set_max_health
var health = 1 setget set_health # use function every time it gets set, "call down, signal up"
var MAX_SPEED = 10setget updateSpeed

signal no_health
signal speed_changed(value)
signal health_changed(value)
signal max_health_changed(value)
	
func set_max_health(value):
	var dif = value - max_health
	max_health = value
	self.health = min(health+dif, max_health)
	emit_signal("max_health_changed", max_health)

func updateSpeed(value):
	MAX_SPEED = value
	emit_signal("speed_changed", MAX_SPEED)

func set_health(value): # only runs when stats.health is set 
	pass
	if value <= max_health:
		health = value
	else:
		health = max_health
	emit_signal("health_changed", health)

	if health <= 0:	
		emit_signal("no_health")

func restoreHealth():
	self.health = max_health
	
func _ready():
	self.max_health = base_max_health
	self.MAX_SPEED = BASE_MAX_SPEED
	restoreHealth()
