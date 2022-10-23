extends Control

var health = 100 setget set_health
var max_health = 100 setget set_max_health

onready var healthBar = $HealthBar
onready var label = $Label
	
func set_health(value):
	health = clamp(value, 0, max_health)
	healthBar.value = health
	label.text = str(health,"/",max_health)
	if healthBar.value/healthBar.max_value > 0.5:
		healthBar.tint_progress.r = range_lerp(health, max_health/2, max_health, 1, 0)
		healthBar.tint_progress.g = 1.0
	else:
		healthBar.tint_progress.r = 1.0
		healthBar.tint_progress.g = range_lerp(health, 0, max_health/2, 0, 1)

func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)
	healthBar.max_value = max_health
	

func _ready():
	self.max_health = PlayerStats.max_health
	self.health = PlayerStats.health
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_health")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_health")
