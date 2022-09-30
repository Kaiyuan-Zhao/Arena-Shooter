extends "res://Enemies/Enemy.gd"

export(int) var min_health_limit = 25
export(int) var max_health_limit = 125
export(int) var min_speed_limit = 50
export(int) var max_speed_limit = 100
export(int) var min_damage_limit = 5
export(int) var max_damage_limit = 25
export(int) var speedCap = -1

onready var outerSprite = $Sprite/OuterSprite
onready var innerSprite = $Sprite/InnerSprite

func _ready():
	var world = get_tree().get_root().get_node("World")
	if not world.ready:
		yield(get_tree().get_root().get_node("World"), "ready")
	player = get_tree().get_root().get_node("World").get_node("Player")
	rng.randomize()
	state = pick_random_state([IDLE, WANDER])
	stats.restoreHealth()
	if speedCap == -1:
		speedCap = 3*(max_speed_limit + min_speed_limit)/2
	randomizeStats()
	stat_visuals()
	keepOriginalScales(detectionZone)
	print(stats.max_health," ", stats.MAX_SPEED," ", stats.damage, " ", level)
	levelModifers()
	add_to_group("Enemies")
	
func _physics_process(delta):
	updateMotion(delta)

func levelModifers():
	var modifier = (1+(level*level-1)/5)
	stats.max_health = round(stats.max_health * modifier)
	stats.MAX_SPEED = min(round(stats.MAX_SPEED * modifier), speedCap)
	stats.damage = round(stats.damage * modifier)
	hitbox.damage = stats.damage

func stat_visuals():
	var scale = range_lerp(stats.max_health, min_health_limit, max_health_limit, 0.5, 1.5)
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
	transform = transform.scaled(Vector2(scale, scale))

func keepOriginalScales(child):
	var scale = range_lerp(stats.max_health, min_health_limit, max_health_limit, 0.5, 1.5)
	child.transform = detectionZone.transform.scaled(Vector2(1/scale,1/scale))


func randomizeStats():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	stats.max_health = rng.randi_range(min_health_limit, max_health_limit)
	stats.MAX_SPEED = rng.randi_range(min_speed_limit, max_speed_limit)
	stats.damage = rng.randi_range(min_damage_limit, max_damage_limit)
