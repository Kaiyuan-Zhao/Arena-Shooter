extends "res://Enemies/EnemyBody.gd"

export(int) var min_health_limit = 25
export(int) var max_health_limit = 125
export(int) var min_speed_limit = 50
export(int) var max_speed_limit = 150
export(int) var min_damage_limit = 5
export(int) var max_damage_limit = 25
export(int) var speedCap = -1
export(int) var damageCap = -1
export(int) var healthCap = -1

onready var outerSprite = $Sprite/OuterSprite
onready var innerSprite = $Sprite/InnerSprite

func _ready():
	yield(get_parent(), "ready")
	if speedCap == -1:
		speedCap = 3*(max_speed_limit + min_speed_limit)/2
	if damageCap == -1:
		damageCap = 3*(max_damage_limit + min_damage_limit)/2
	if healthCap == -1:
		healthCap = 12*(max_health_limit + min_health_limit)/2
	randomizeStats()
	stat_visuals()
	keepOriginalScales(detectionZone)
	print(stats.max_health," ", stats.MAX_SPEED," ", stats.damage)
	initalizeVariables()
	levelModifers()
	
	state = pick_random_state([IDLE, WANDER])
	stats._ready()
	
	
func _physics_process(delta):
	updateMotion(delta)

func levelModifers():
	var modifier = (1+(level*level-1)/25.0)
	stats.max_health = min(round(stats.max_health * modifier), healthCap)
	stats.MAX_SPEED = min(round(stats.MAX_SPEED * modifier), speedCap)
	stats.damage = min(round(stats.damage * modifier), damageCap)

func stat_visuals():
	
	var scale = range_lerp(stats.max_health, min_health_limit, max_health_limit, 0.5, 1.5)
	var g
	var r
	if float(stats.damage-min_damage_limit)/(max_damage_limit-min_damage_limit) < 0.5:
		g = 255
		r = range_lerp(stats.damage, min_damage_limit, max_damage_limit/2, 0, 1)
	else:
		g = range_lerp(stats.damage, min_damage_limit+max_damage_limit/2, max_damage_limit, 1, 0)
		r = 255
	
	outerSprite.modulate.r = r
	outerSprite.modulate.g = g
	
	var b = range_lerp(stats.MAX_SPEED, min_speed_limit, max_speed_limit, 0, 1)
	innerSprite.modulate.r = b
	innerSprite.modulate.g = b
	innerSprite.modulate.b = b
	
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
