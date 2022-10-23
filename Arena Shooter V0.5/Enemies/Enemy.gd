extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	CHASE
}

export(int) var WANDER_TARGET_RANGE = 4
export(int) var level = 1 setget updateLevel
export(Resource) var weaponScene = null
export(int) var speedCap = -1
export(int) var min_speed_limit = 50
export(int) var max_speed_limit = 100

var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var agro = false
var state = CHASE
var ACCELERATION = 300
var FRICTION = 200
var dead = false
var rng = RandomNumberGenerator.new()
var threshold = 4
var world
var layer = 4

var UIscene = preload("res://Enemies/EnemyUI.tscn")
var hearts = preload("res://droppedItems/droppedHeart.tscn")
var hearts2 = preload("res://droppedItems/droppedHeart2.tscn")
var hearts3 = preload("res://droppedItems/droppedHeart3.tscn")
var coins = preload("res://droppedItems/droppedCoins.tscn")
var bars = preload("res://droppedItems/droppedGoldBar.tscn")
var piles = preload("res://droppedItems/droppedCoinPile.tscn")
var weapon : Object = null

onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
onready var player
onready var UI
onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var hitbox = $Hitbox
onready var path = get_filename()
onready var baseStats := {
	"max_health" : stats.max_health,
	"max_speed" : stats.MAX_SPEED,
	"damage" : stats.damage}

func _ready():
	world = get_tree().get_root().get_node("World")
	if not world.ready:
		yield(world, "ready")
	player = world.player
	if speedCap == -1:
		speedCap = 3*(max_speed_limit + min_speed_limit)/2
	rng.randomize()
	initalizeVariables()
	#levelModifers()
	state = WANDER
	stats.restoreHealth()

func updateLevel(value):
	level = value
	if UI != null:
		UI.level = level

func initalizeVariables():
	UI = UIscene.instance()
	get_parent().add_child(UI)
	updateLevel(level)
	hitbox.damage = stats.damage
	updateSpeed()
	UI.visible = true
	
func levelModifers():
	var modifier = (1+(level*level-1)/5)
	stats.max_health = round(stats.max_health * modifier)
	stats.MAX_SPEED = min(round(stats.MAX_SPEED * modifier), speedCap)
	stats.damage = round(stats.damage * modifier)
	hitbox.damage = stats.damage
	
func _physics_process(_delta):
	UI.global_position = global_position	
	checkHurtbox()

func updateSpeed():
	FRICTION = 4*stats.MAX_SPEED
	ACCELERATION = 7.5*stats.MAX_SPEED

func updateMotion(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()

		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()

			accelerate_towards_point(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()

		CHASE:
			chaseAlgorithm(delta)


	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

	knock_back(delta)
	move(velocity)

func chaseAlgorithm(delta):
	if detectionZone.can_see_bodies():
		accelerate_towards_point(player.global_position, delta)
	elif agro:
		accelerate_towards_point(player.global_position, delta)
	else:
		state = IDLE

func knock_back(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION *delta)
	if knockback.x > 0 or knockback.y > 0:
		agro = true
		state = CHASE
	move(knockback)

func move(vector):
	vector = move_and_slide(vector)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_time(rand_range(1,3))

func navigate(target: Vector2):
	nav_agent.set_target_location(target)
# warning-ignore:return_value_discarded
	nav_agent.get_next_location()

func accelerate_towards_point(point, delta):
	navigate(point)
	look_at(point)
	if not nav_agent.is_navigation_finished():
		var direction =  global_position.direction_to(nav_agent.get_next_location())
		velocity = velocity.move_toward(direction * stats.MAX_SPEED, ACCELERATION * delta)
		nav_agent.set_velocity(velocity)
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

func accelerate_away_from_point(point, delta):
	navigate(point)
	look_at(point)
	if not nav_agent.is_navigation_finished():
		var direction = -global_position.direction_to(nav_agent.get_next_location())
		velocity = velocity.move_toward(direction * stats.MAX_SPEED, ACCELERATION * delta)
		nav_agent.set_velocity(velocity)
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

func seek_player():
	if detectionZone.can_see_bodies():
		agro = true
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func setKnockback(power, direction):
	knockback = power * direction * 20

func _on_Hurtbox_area_entered(area):
	if not hurtbox.is_invincible_to(area):
		if area.damage/stats.max_health*1.0 > 0 and area.fromPlayer:
			world.camera.shake(20)
		stats.health -= area.damage
		if is_instance_valid(player):
			var direction = -(player.global_position - global_position).normalized()
			setKnockback(area.knockback, direction)
		if !detectionZone.can_see_bodies():
			state = CHASE
			agro = true
		hurtbox.create_hit_effect()
		hurtbox.set_invincibility(area, 0.3)

func checkHurtbox():
	var arr = hurtbox.get_overlapping_areas()
	if arr.size() > 0:
		for i in arr:
			_on_Hurtbox_area_entered(i)

func _on_Stats_no_health():
	if not dead:
		dropLoot()
	world.camera.shake(200)
	dead = true
	kill()

func kill():
	UI.queue_free()
	queue_free()

func dropLoot(times = 1):
	var totalHearts = generateNum(0.75)*times
	var heart3Num = floor(totalHearts/100)
	var heart2Num = floor((totalHearts-heart3Num*100)/10)
	var heartNum = totalHearts-heart3Num*100-heart2Num*10
	generateLoot(hearts3, heart3Num)
	generateLoot(hearts2, heart2Num)
	generateLoot(hearts, heartNum)
	
	var totalCoins = generateNum(0.75)*times
	var pilesNum = totalCoins/100
	var barsNum = (totalCoins-pilesNum*100)/10
	var coinsNum = totalCoins-pilesNum*100-barsNum*10
	generateLoot(piles, pilesNum)
	generateLoot(bars, barsNum)
	generateLoot(coins, coinsNum)
	
	if weaponScene != null:
		if generateNum(0.2, 1) > 0:
			weapon.drop()
		
func generateNum(odds, times = level*level):
	var num = 0
	for i in times:
		rng.randomize()
		var random = rng.randf()
		if random <= odds:
			num+=1
	return num

func generateLoot(loot, num):
	for _i in range(num):
		var l = loot.instance()
		get_tree().current_scene.get_node("Items").call_deferred("add_child",l)
		l.global_position = global_position + Vector2(rng.randi_range(-50, 50), rng.randi_range(-50, 50))
		

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	move(safe_velocity)

func _on_Hitbox2_body_entered(_body):
	velocity = Vector2.ZERO



func get_save_data() -> Dictionary:
	var d := {}
	if weapon == null:
		d["Object_weapon"] = null
	else:
		d["Object_weapon"] = get("weapon").get_save_data()
	d["knockback"] = knockback
	d["global_position"] = global_position
	d["velocity"] = velocity
	d["path"] = path
	d["level"] = level
	d["Object_stats"] = baseStats.duplicate()
	d["rotation"] = rotation
	return d
	
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
			stats.load_save_data(d[property_name])
		elif property_name == "level":
			self.level = d["level"]
		else:
			set(property_name, d[property_name])
