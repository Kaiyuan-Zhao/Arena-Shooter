extends KinematicBody2D

export var ACCELERATION = 750
export var FRICTION = 400
export var SPRINT_FORCE = 100

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var canSprint = true
var weapon = null setget set_weapon
var stats = PlayerStats
var layer = 2

onready var MAX_SPEED = PlayerStats.MAX_SPEED
onready var sprintTimer = $SprintTimer
onready var hurtbox = $Hurtbox
onready var itemDetectionZone = $itemDetectionZone
onready var autoCollectDetectionZone = $AutoCollectDetectionZone

func _ready():
	stats.connect("no_health", self, "restart")
	stats.connect("speed_changed", self, "updateSpeed")

func restart():
	stats.restoreHealth()
	get_tree().reload_current_scene()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION *delta)
	move(knockback)
	move_state(delta)
	point_to_mouse()
	
	if autoCollectDetectionZone.can_see_bodies():
		var item = autoCollectDetectionZone.bodies.pop_front()
		item.picked_up(self)
		
	if itemDetectionZone.can_see_bodies() && Input.is_action_just_pressed("pick_up"):
		var item = itemDetectionZone.bodies.pop_front()
		swap_weapons(item.pickedUpWeapon)
		item.queue_free()
		
	if Input.is_action_pressed("attack") and weapon != null:
		weapon.using = true
	elif weapon != null:
		weapon.using = false
		
	if Input.is_action_just_pressed("drop"):
		drop_weapons()
	
func updateSpeed(value):
	MAX_SPEED = value
	FRICTION = 4*value
	ACCELERATION = 7.5*value
	
func set_weapon(value):
	if value != null:
		weapon = value.instance()
		call_deferred("add_child",weapon)
		var list = weapon.get_signal_list()
		weapon.friendlyMask = layer
		for signal_entry in list:
			if signal_entry["name"] == "knockback":
				weapon.connect("knockback", self, "setKnockback")
		
func swap_weapons(swapped_weapon):
	if weapon == null:
		self.weapon = swapped_weapon
	else:
		drop_weapons()
		self.weapon = swapped_weapon

func drop_weapons():
	if weapon != null:
		weapon.drop()
		weapon = null

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	knockback.move_toward(Vector2.ZERO, FRICTION*delta)
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		if canSprint and Input.is_action_just_pressed("sprint"):
			canSprint = false
			sprintTimer.start()
			velocity += input_vector*SPRINT_FORCE*sqrt(MAX_SPEED)/3
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move(velocity)
	move(knockback)

func point_to_mouse():
	look_at(get_global_mouse_position())
	
func move(vector):
	vector = move_and_slide(vector)

func setKnockback(power, direction):
	knockback = power * direction * 20

func _on_SprintTimer_timeout():
	canSprint = true

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	var direction = -(area.global_position- global_position).normalized()
	setKnockback(area.knockback, direction)
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
