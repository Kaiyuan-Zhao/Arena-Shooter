extends KinematicBody2D

export var ACCELERATION = 750
export var FRICTION = 400
export var SPRINT_FORCE = 100
var abilityStats = {
	0 : {"name" : "dash", "cooldown" : 1, "duration" : 0, "interval" : 0},
	1 : {"name" : "regen", "cooldown" : 30, "duration" : 10, "interval" : 0.1},
	2 : {"name" : "weapon enlarge", "cooldown" : 30, "duration" : 10, "interval" : 0.1},
}
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var abilityReady = true
var weapon = null setget set_weapon
var stats = PlayerStats
var layer = 2
var input_vector = Vector2.ZERO
var usingAbility = false
var world
onready var glowLayer = null
onready var MAX_SPEED = PlayerStats.MAX_SPEED
onready var abilityCoolDown = $AbilityCoolDown
onready var abilityTimer = $AbilityTimer
onready var abilityTicker = $AbilityTicker
onready var hurtbox = $Hurtbox
onready var itemDetectionZone = $itemDetectionZone
onready var autoCollectDetectionZone = $AutoCollectDetectionZone

func _ready():
	world = get_tree().get_root().get_node("World")
	stats.restoreHealth()
	stats.coins = 0
	stats.connect("no_health", self, "restart")
	stats.connect("speed_changed", self, "updateSpeed")

func restart():
	stats.restoreHealth()
	world.camera.shake(1000)
	get_tree().reload_current_scene()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION *delta)
	move(knockback)
	move_state(delta)
	point_to_mouse()
		
	if itemDetectionZone.can_see_bodies() && Input.is_action_just_pressed("pick_up"):
		var item = itemDetectionZone.bodies.pop_front()
		swap_weapons(item)
		set_itemUI(item)
		item.queue_free()
		
	if Input.is_action_pressed("attack") and weapon != null:
		weapon.using = true
		
	if Input.is_action_just_released("attack") and weapon != null:
		weapon.using = false
		
	if Input.is_action_just_pressed("drop"):
		drop_weapons()
		
	if abilityReady and Input.is_action_just_pressed("ability"):
		world.camera.shake(50)
		start_ability()
		
	if usingAbility:
		var time = abilityStats[stats.ability]["duration"] * (1.0 + (stats.abilityLevel-1)/20.0)
		stats.ability_time_left = abilityTimer.time_left/time
		if abilityTicker.is_stopped():
			var interval = abilityStats[stats.ability]["interval"]
			if interval > 0:
				abilityTicker.start(interval)
	else:
		if not abilityCoolDown.is_stopped():
			var time = abilityStats[stats.ability]["cooldown"] * (1.0 - (stats.abilityLevel-1)/20.0)
			stats.ability_cooldown = abilityCoolDown.time_left/time
		
func use_ability():
	if abilityStats[stats.ability]["name"] == "dash":
		velocity += input_vector*SPRINT_FORCE*sqrt(MAX_SPEED)/3
		if velocity.length() > (input_vector*SPRINT_FORCE*MAX_SPEED/24).length():
			velocity = input_vector*SPRINT_FORCE*MAX_SPEED/24
	
	if abilityStats[stats.ability]["name"] == "regen":
		stats.health += floor(0.01*stats.max_health)
		
	if abilityStats[stats.ability]["name"] == "weapon enlarge":
		if weapon != null:
			weapon.scale = Vector2(2.5,2.5)

func resetChanges():
	if weapon != null:
		weapon.scale = Vector2(1,1)

func start_ability():
	abilityReady = false
	var time = abilityStats[stats.ability]["duration"] * (1.0 + (stats.abilityLevel-1)/20.0)
	if time > 0:
		usingAbility = true
		abilityTimer.start(time)
	else:
		_on_AbilityTimer_timeout()
		
	use_ability()
		
func updateSpeed(value):
	MAX_SPEED = value
	FRICTION = 4*value
	ACCELERATION = 7.5*value
	
func set_weapon(droppedItem):
	if droppedItem != null:
		weapon = droppedItem.pickedUpWeapon.instance()
		call_deferred("add_child",weapon)
		var list = weapon.get_signal_list()
		weapon.friendlyMask = layer
		for signal_entry in list:
			if signal_entry["name"] == "knockback":
				weapon.connect("knockback", self, "setKnockback")
			if signal_entry["name"] == "level_changed":
				weapon.connect("level_changed", self, "set_itemUI_level")
		yield(weapon, "ready")
		weapon.level = droppedItem.level

func set_itemUI_level(value):
	glowLayer.itemUI.level = value
	
func set_itemUI(item):
	var itemUI = glowLayer.itemUI
	if glowLayer != null:
		if item != null:
			itemUI.itemTextureRect.texture = item.texture
			set_itemUI_level(item.level)
		else:
			itemUI.itemTextureRect.texture = null
			set_itemUI_level(0)

func swap_weapons(swapped_weapon):
	if weapon == null:
		self.weapon = swapped_weapon
	else:
		drop_weapons()
		self.weapon = swapped_weapon

func drop_weapons():
	if weapon != null:
		weapon.drop()
		set_itemUI(null)
		weapon = null
		

func move_state(delta):
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	knockback.move_toward(Vector2.ZERO, FRICTION*delta)
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
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

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	world.camera.shake(range_lerp(area.damage, 0, stats.health, 0, 100))
	var direction = -(area.global_position- global_position).normalized()
	setKnockback(area.knockback, direction)
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()

func _on_AbilityCoolDown_timeout():
	stats.ability_cooldown = 0
	abilityReady = true

func _on_AbilityTimer_timeout():
	abilityTicker.stop()
	usingAbility = false
	resetChanges()
	stats.ability_time_left = 0
	var levelModifer = 1.0 - (stats.abilityLevel-1)/20.0
	if levelModifer >= 0:
		abilityCoolDown.start(abilityStats[stats.ability]["cooldown"] * (1.0 - (stats.abilityLevel-1)/20.0))
	else:
		abilityCoolDown.start(0)
		
func _on_AbilityTicker_timeout():
	use_ability()
