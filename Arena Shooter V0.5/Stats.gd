extends Node

export(int) var base_max_health = 1
export(int) var BASE_MAX_SPEED = 100
export(int) var damage = 10

var max_health = 1 setget set_max_health
var health = 1 setget set_health # use function every time it gets set, "call down, signal up"
var MAX_SPEED = 10 setget updateSpeed

onready var _UNSAVABLE_PROPERTIES = []

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
	
func get_save_data() -> Dictionary:
	var d := {}
	for property in get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			if not property.name in _UNSAVABLE_PROPERTIES:
				if property.type != TYPE_OBJECT:
					# ConfigFile can handle any built-in data type
					d[property.name] = get(property.name)
				else:
					# implement get_save_data() in non-node objects.
					d["Object_" + property.name] = get(property.name).get_save_data()
	return d

func load_save_data(d: Dictionary): 
	for property_name in d:
		if property_name.count("Object_") > 0:
			get(property_name).load_save_data(d[property_name])
		elif property_name == "max_speed":
			self.MAX_SPEED = d[property_name]
		else:
			set(property_name, d[property_name])
	
