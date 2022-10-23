extends "res://Enemies/Enemy.gd"

export(int) var min_health_limit = 25
export(int) var max_health_limit = 125
export(int) var min_damage_limit = 5
export(int) var max_damage_limit = 25

onready var outerSprite = $Sprite/OuterSprite
onready var innerSprite = $Sprite/InnerSprite

func _ready():
	randomizeStats()
	stat_visuals()
	keepOriginalScales(detectionZone)
	levelModifers()
	
func _physics_process(delta):

	updateMotion(delta)

func stat_visuals():
	var factor = range_lerp(stats.max_health, min_health_limit, max_health_limit, 0.5, 1.5)
	scale = Vector2(factor, factor)
	var g
	var r
	if float(stats.damage-min_damage_limit)/(max_damage_limit-min_damage_limit) < 0.5:
		g = 1.0
		r = range_lerp(stats.damage, min_damage_limit, (min_damage_limit+max_damage_limit)/2, 0, 1)
	else:
		g = range_lerp(stats.damage, (min_damage_limit+max_damage_limit)/2, max_damage_limit, 1, 0)
		r = 1.0

	outerSprite.self_modulate.r = r
	outerSprite.self_modulate.g = g

	var b = range_lerp(stats.MAX_SPEED, min_speed_limit, max_speed_limit, 0, 1)
	innerSprite.self_modulate.r = b
	innerSprite.self_modulate.g = b
	innerSprite.self_modulate.b = b

func keepOriginalScales(child):
	var scale = range_lerp(stats.max_health, min_health_limit, max_health_limit, 0.5, 1.5)
	child.transform = detectionZone.transform.scaled(Vector2(1/scale,1/scale))


func randomizeStats():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	stats.max_health = rng.randi_range(min_health_limit, max_health_limit)
	stats.MAX_SPEED = rng.randi_range(min_speed_limit, max_speed_limit)
	stats.damage = rng.randi_range(min_damage_limit, max_damage_limit)
	baseStats = {
	"max_health" : stats.max_health,
	"max_speed" : stats.MAX_SPEED,
	"damage" : stats.damage}

func load_save_data(d: Dictionary): 
	for property_name in d:
		if "weapon" in property_name:
			if d[property_name] != null:
				weapon.load_save_data(d[property_name])
			else:
				weapon = null
		elif property_name == "global_position":
			var new_string: String = d[property_name]
			new_string.erase(0, 1)
			new_string.erase(new_string.length() - 1, 1)
			var array: Array = new_string.split(", ")
			global_position = Vector2(array[0], array[1])
		elif property_name == "Object_stats":
			if speedCap == -1:
				speedCap = 3*(max_speed_limit + min_speed_limit)/2
			stats.load_save_data(d[property_name])
			baseStats = {
			"max_health" : stats.max_health,
			"max_speed" : stats.MAX_SPEED,
			"damage" : stats.damage}
			stat_visuals()
			keepOriginalScales(detectionZone)
			levelModifers()
		elif property_name == "level":
			self.level = d["level"]
		else:
			set(property_name, d[property_name])
