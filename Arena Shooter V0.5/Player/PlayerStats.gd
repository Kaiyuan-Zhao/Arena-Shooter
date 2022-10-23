extends "res://Stats.gd"

var coins := 0 setget set_coins
var ability := -1 setget changeAbility
var abilityLevel := 1
var ability_sprite = null setget change_ability_sprite
var ability_time_left = 0 setget emit_time_left
var ability_cooldown := 0 setget emit_cooldown_left

signal coins_changed(value)
signal ability_time_left(value)
signal ability_cooldown_left(value)
signal ability_sprite_changed(value)
signal ability_changed(old, new)


func _ready():
	_UNSAVABLE_PROPERTIES = ["ability_sprite"]

func changeAbility(value):
	emit_signal("ability_changed", ability, value)
	ability = value
	

func change_ability_sprite(value):
	ability_sprite = value
	emit_signal("ability_sprite_changed", value)

func set_coins(value):
	coins = value
	emit_signal("coins_changed", value)

func emit_time_left(value):
	ability_time_left = value
	emit_signal("ability_time_left", value)
	
func emit_cooldown_left(value):
	ability_cooldown = value
	emit_signal("ability_cooldown_left", value)
	
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
		elif property_name == "ability_time_left":
			self.ability_time_left = d[property_name]
		elif property_name == "ability_cooldown_left":
			self.ability_cooldown_left = d[property_name]
		else:
			set(property_name, d[property_name])
	
