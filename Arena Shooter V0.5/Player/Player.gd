extends KinematicBody2D

export var ACCELERATION = 750
export var FRICTION = 400
export var SPRINT_FORCE = 100
export var livesLeft = 3
var abilityStats = {
	0 : {"name" : "dash", "cooldown" : 1, "duration" : 0, "interval" : 0},
	1 : {"name" : "regen", "cooldown" : 30, "duration" : 10, "interval" : 0.1},
	2 : {"name" : "weapon enlarge", "cooldown" : 30, "duration" : 10, "interval" : 0.1},
}

var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var abilityReady = true
var weapon : Object = null setget set_weapon
var stats = PlayerStats
var layer = 2
var input_vector = Vector2.ZERO
var usingAbility = false
var world
var _UNSAVABLE_PROPERTIES = ["stats", "world", "glowLayer", "abilityCoolDown", "abilityTimer", "abilityTicker", "hurtbox", "itemDetectionZone", "autoCollectDetectionZone"]
var abilityTimeLeft := 0.0
var abilityCooldownLeft := 0.0
onready var pos = global_position
onready var glowLayer = null
onready var MAX_SPEED = PlayerStats.MAX_SPEED
onready var abilityCoolDown = $AbilityCoolDown
onready var abilityTimer = $AbilityTimer
onready var abilityTicker = $AbilityTicker
onready var hurtbox = $Hurtbox
onready var itemDetectionZone = $itemDetectionZone
onready var autoCollectDetectionZone = $AutoCollectDetectionZone
onready var sprite = $Sprite
func _ready():
	world = get_tree().get_root().get_node("World")
	stats.restoreHealth()
	stats.coins = 0
	stats.connect("no_health", self, "restart")
	stats.connect("ability_changed", self, "changeAbility")
	stats.connect("speed_changed", self, "updateSpeed")
	
func restart():
	livesLeft -= 1;
	stats.restoreHealth()
	if livesLeft == 0:
		world.camera.shake(1000)
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func changeAbility(old, new):
	_on_AbilityTimer_timeout()
	

func _physics_process(delta):
	print("timeLeft: ", abilityTimer.time_left)
	print("cooldownLeft: ", abilityCoolDown.time_left)
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
		
	
	if Input.is_action_just_pressed("delete") and weapon != null:
		deleteWeapon()
	
	if abilityReady and Input.is_action_just_pressed("ability"):
		world.camera.shake(50)
		start_ability()
		abilityCooldownLeft = abilityStats[stats.ability]["cooldown"] * (1.0 - (stats.abilityLevel-1)/20.0)
		
	if usingAbility:
		var time = abilityStats[stats.ability]["duration"] * (1.0 + (stats.abilityLevel-1)/20.0)
		if time != 0:
			stats.ability_time_left = abilityTimer.time_left/time
		else:
			stats.ability_time_left = 0.0
			abilityTimer.stop()
			_on_AbilityTimer_timeout()
			
		if abilityTicker.is_stopped():
			var interval = abilityStats[stats.ability]["interval"]
			if interval > 0:
				abilityTicker.start(interval)
	else:
		sprite.self_modulate.g = 1
		sprite.self_modulate.r = 1
		sprite.self_modulate.b = 1
		if not abilityCoolDown.is_stopped():
			abilityCooldownLeft = abilityStats[stats.ability]["cooldown"] * (1.0 - (stats.abilityLevel-1)/20.0)
			var time = abilityCooldownLeft
			stats.ability_cooldown = abilityCoolDown.time_left/time
			
	checkHurtbox()	
func use_ability():
	if abilityStats[stats.ability]["name"] == "dash":
		velocity += input_vector*SPRINT_FORCE*sqrt(MAX_SPEED)/3
		if velocity.length() > (input_vector*SPRINT_FORCE*MAX_SPEED/24).length():
			velocity = input_vector*SPRINT_FORCE*MAX_SPEED/24
	
	if abilityStats[stats.ability]["name"] == "regen":
		sprite.self_modulate.g = 1.15
		sprite.self_modulate.r = 0.45
		sprite.self_modulate.b = 0.45
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


func set_weapon(w):
	if w != null:
		if w.name.count("dropped") == 0:
			weapon = w
			var list = weapon.get_signal_list()
			call_deferred("add_child",weapon, true)
			for signal_entry in list:
				if signal_entry["name"] == "knockback":
# warning-ignore:return_value_discarded
					weapon.connect("knockback", self, "setKnockback")
				if signal_entry["name"] == "level_changed":
# warning-ignore:return_value_discarded
					weapon.connect("level_changed", self, "set_itemUI_level")
		else:
			weapon = w.pickedUpWeapon.instance()
			var arr = w.stats
			call_deferred("add_child",weapon, true)
			var list = weapon.get_signal_list()
			weapon.friendlyMask = layer
			for signal_entry in list:
				if signal_entry["name"] == "knockback":
# warning-ignore:return_value_discarded
					weapon.connect("knockback", self, "setKnockback")
				if signal_entry["name"] == "level_changed":
# warning-ignore:return_value_discarded
					weapon.connect("level_changed", self, "set_itemUI_level")
			yield(weapon, "ready")
			weapon.stats = arr
	else:
		if weapon != null:
			weapon.queue_free()
			set_itemUI(null)
			weapon = null
	
func set_itemUI_level(value):
	glowLayer.itemUI.level = value
	
func set_itemUI(item, texture = null):
	var itemUI = glowLayer.itemUI
	if glowLayer != null:
		if item != null:
			if texture != null:
				itemUI.itemTextureRect.texture = texture
			else:
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
	
func move(vector : Vector2):
	vector = move_and_slide(vector)

func setKnockback(power, direction):
	knockback = power * direction * 20

func checkHurtbox():
	var arr = hurtbox.get_overlapping_areas()
	if arr.size() > 0:
		for i in arr:
			_on_Hurtbox_area_entered(i)

func _on_Hurtbox_area_entered(area):
	if not hurtbox.is_invincible_to(area):
		if not area.percentageBased:
			stats.health -= area.damage
		else:
			stats.health -= ceil(stats.max_health * (area.percentage/100.0))
		world.camera.shake(range_lerp(area.damage, 0, stats.health, 0, 100))
		var direction = -(area.global_position- global_position).normalized()
		setKnockback(area.knockback, direction)
		hurtbox.set_invincibility(area, 0.3)
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
	if stats.ability != -1:
		abilityCooldownLeft = abilityStats[stats.ability]["cooldown"] * (1.0 - (stats.abilityLevel-1)/20.0)
		if levelModifer >= 0:
			abilityCoolDown.start(abilityCooldownLeft)
		else:
			abilityCoolDown.start(0)
		
func _on_AbilityTicker_timeout():
	use_ability()

func get_save_data() -> Dictionary:
	var d := {}
	if weapon == null:
		d["Object_weapon"] = null
	else:
		d["Object_weapon"] = get("weapon").get_save_data()
	d["knockback"] = knockback
	d["global_position"] = global_position
	d["velocity"] = velocity
	d["rotation"] = rotation
	d["ability"] = stats.ability
	d["abilityTimeLeft"] = abilityTimer.time_left
	d["usingAbility"] = usingAbility
	d["abilityCooldownLeft"] = abilityCoolDown.time_left
	return d
	
func deleteWeapon():
	if weapon != null:
		weapon.queue_free()
	set_itemUI(null)
	weapon = null
	
func load_save_data(d: Dictionary): 
	for property_name in d:
		if "weapon" in property_name:
			if d[property_name] != null:
				var w = load(d[property_name]["path"])
				deleteWeapon()
				self.weapon = w.instance()
				get(property_name.replace("Object_", "")).load_save_data(d[property_name])
				var droppedItem = load(d[property_name]["droppedItemPath"])
				var dropped = droppedItem.instance()
				set_itemUI(weapon, dropped.get_node("Sprite").texture)
				dropped.queue_free()
				weapon.using = false
			else:
				deleteWeapon()
		elif property_name == "global_position":
			var new_string: String = d[property_name]
			new_string.erase(0, 1)
			new_string.erase(new_string.length() - 1, 1)
			var array: Array = new_string.split(", ")
			global_position = Vector2(array[0], array[1])
		elif property_name == "ability":
			stats.ability = d[property_name]
		elif property_name == "abilityTimeLeft":
			if d[property_name] > 0:
				abilityTimeLeft = d[property_name]
				abilityTimer.start(d[property_name])
		elif property_name == "abilityCooldownLeft":
			if d[property_name] > 0:
				abilityTimeLeft = d[property_name]
				abilityCoolDown.start(d[property_name])
		elif property_name == "usingAbility":
			usingAbility = d[property_name]
		else:
			set(property_name, d[property_name])
