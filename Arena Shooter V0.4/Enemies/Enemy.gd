extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	CHASE
}

export(int) var WANDER_TARGET_RANGE = 4
export(int) var level = 1
export(Resource) var weaponScene = null

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var agro = false
var state = CHASE
var ACCELERATION = 300
var FRICTION = 200
var dead = false
var rng = RandomNumberGenerator.new()
var threshold = 4
var hearts = preload("res://droppedItems/droppedHeart.tscn")
var coins = preload("res://droppedItems/droppedCoins.tscn")
var UIscene = preload("res://Enemies/EnemyUI.tscn")
var world

onready var line : Line2D = get_node("../Line2D")
onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
onready var player
onready var UI
onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var hitbox = $Hitbox

func _ready():
	world = get_tree().get_root().get_node("World")
	if not world.ready:
		yield(world, "ready")
	player = world.player
	rng.randomize()
	initalizeVariables()
	state = pick_random_state([IDLE, WANDER])
	stats.restoreHealth()

func initalizeVariables():
	UI = UIscene.instance()
	get_parent().add_child(UI)
	UI.level = level
	hitbox.damage = stats.damage
	updateSpeed()

func _physics_process(delta):
	UI.global_position = global_position	

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
	nav_agent.get_next_location()
	line.points = nav_agent.get_nav_path()

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
	hurtbox.start_invincibility(0.2)

func _on_Stats_no_health():
	if not dead:
		dropLoot()
	world.camera.shake(200)
	dead = true
	UI.queue_free()
	queue_free()

func dropLoot():
	generateLootNum(hearts, 0.75)
	generateLootNum(coins, 0.75)

func generateLootNum(loot, odds):
	var num = 0
	for i in level*level:
		rng.randomize()
		var random = rng.randf()
		if random <= odds:
			var l = loot.instance()
			get_tree().current_scene.get_node("Items").call_deferred("add_child",l)
			l.global_position = global_position + Vector2(rng.randi_range(-50, 50), rng.randi_range(-50, 50))
			num += 1
	print("Dropped ",num)


func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	move(safe_velocity)

func _on_NavigationAgent2D_target_reached() -> void:
	line.points = nav_agent.get_nav_path()


func _on_NavigationAgent2D_navigation_finished() -> void:
	line.points = []
