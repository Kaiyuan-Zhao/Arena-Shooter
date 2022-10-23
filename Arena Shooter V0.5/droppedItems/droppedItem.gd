extends Node2D

export(Resource) var pickedUpWeapon
export(bool) var presetStats = false
export(int) var level = 1 setget set_level
export(int) var projectileCount = -1
export(bool) var canPierce = false
var stats = []
onready var path = get_filename()
var _UNSAVABLE_PROPERTIES = ["label", "texture"]
onready var label = $Label
onready var texture = $Sprite.texture

func _ready():
	if presetStats:
		stats.append(level)
		stats.append(projectileCount)
		stats.append(canPierce)
	if stats.size() > 0:
		level = stats[0]
	else:
		stats.append(level)
	label.text = str("LVL: ", level)

func set_level(value):
	level = value
	if label != null:
		label.text = str("LVL: ", level)

func get_save_data() -> Dictionary:
	var d := {}
	if stats.size() == 0:
		stats.append(level)
		stats.append(projectileCount)
		stats.append(canPierce)
	d["stats"] = stats
	d["path"] = path
	d["global_position"] = global_position
	return d

func load_save_data(d: Dictionary): 
	for property_name in d:
		if property_name.count("Object_") > 0:
			get(property_name).load_save_data(d[property_name])
		elif property_name == "global_position":
			var new_string: String = d[property_name]
			new_string.erase(0, 1)
			new_string.erase(new_string.length() - 1, 1)
			var array: Array = new_string.split(", ")
			global_position = Vector2(array[0], array[1])
		elif property_name == "stats":
			self.level = d[property_name][0]
			stats = d[property_name].duplicate()
		else:
			set(property_name, d[property_name])
