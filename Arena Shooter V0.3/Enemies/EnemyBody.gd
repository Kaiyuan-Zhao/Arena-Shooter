extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	CHASE
}

export(Resource) var hearts
export(Resource) var coins

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var agro = false
var state = CHASE
var ACCELERATION = 300
var FRICTION = 200
var WANDER_TARGET_RANGE = 4
var level = 1
var dead = false
var rng = RandomNumberGenerator.new()

onready var player := get_tree().get_root().get_node("World").get_node("Player")
onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var label = get_node("../Position2D/Control/Level")
onready var hitbox = $Hitbox

func _ready():
	yield(get_parent(), "ready")
	rng.randomize()
	initalizeVariables()
	state = pick_random_state([IDLE, WANDER])

func initalizeVariables():
	label.text = str("LVL: ",level)
	hitbox.damage = stats.damage
	ACCELERATION = 3*stats.MAX_SPEED
	FRICTION = 2*stats.MAX_SPEED
	
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
		agro = false	
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

func accelerate_towards_point(point, delta):
	look_at(point)
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * stats.MAX_SPEED, ACCELERATION * delta)

func accelerate_away_from_point(point, delta):
	look_at(point)
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(-direction * stats.MAX_SPEED, ACCELERATION * delta)
	
func seek_player():
	if detectionZone.can_see_bodies():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func setKnockback(power, direction):
	knockback = power * direction * 20
	
func _on_Hurtbox_area_entered(area):
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
	dead = true
	get_parent().queue_free()

func dropLoot():
	generateLootNum(hearts, 0.75)
	generateLootNum(coins, 0.75)
	
func generateLootNum(loot, odds):
	var num = 0
	for i in level:
		rng.randomize()
		var random = rng.randf()
		if random <= odds:
			var l = loot.instance()
			get_tree().current_scene.get_node("Items").call_deferred("add_child",l)
			l.global_position = global_position + Vector2(rng.randi_range(-50, 50), rng.randi_range(-50, 50))
			num += 1
	print("Dropped ",num)
