extends "res://Items/Item.gd"

export(Resource) var projectile
export(int) var spray = 5
export(int) var projectileCount = 1
export(int) var maxProjectileCount = 10
export(int) var pushBack = 5
export(float) var damageMultiplier = 1.0
export(bool) var piercing = false
export(bool) var maxPiercing = true
export(float) var maxSpread = 30.0
onready var projectileSpawn = $ProjectileSpawn
onready var tip = $Tip

var aim_direction = Vector2.RIGHT
var rng = RandomNumberGenerator.new()

signal knockback(power, direction)

func _ready():
	_UNSAVABLE_PROPERTIES = ["droppedItem", "animationPlayer", "rng", "projectileSpawn", "tip"]
	ranged = true



func initalizeStats(arr):
	if arr.size() > 1:
		self.level = arr[0]
		projectileCount = arr[1]
		piercing = arr[2]
	else:
		if arr.size() > 0:
			self.level = arr[0]
	stats = [level, projectileCount, piercing]
	
func drop():
	var d = droppedItem.instance()
	d.global_position = global_position
	d.level = level
	d.stats = [level, projectileCount, piercing]
	get_node("/root/World/Items").call_deferred("add_child",d)
	queue_free()

func fire():
	for i in range(projectileCount):
		aim_direction = projectileSpawn.global_position.direction_to(tip.global_position)
		
		if projectileCount == 2:
			aim_direction = aim_direction.rotated(deg2rad(range_lerp(i, 0, projectileCount-1, -maxSpread/2, maxSpread/2)))
		elif projectileCount > 2:
			aim_direction = aim_direction.rotated(deg2rad(range_lerp(i, 0, projectileCount-1, -maxSpread, maxSpread)))
		var p = projectile.instance()
		p.direction = aim_direction.rotated(deg2rad(rng.randf_range(-spray, spray)))
		p.global_position = projectileSpawn.global_position
		p.rotation = p.direction.angle()
		if piercing:
			p.piercing = true
		get_tree().current_scene.add_child(p)
		p.hitbox.damage = p.hitbox.base_damage * level* damageMultiplier
		p.hitbox.set_collision_mask_bit(friendlyMask, false)
		emit_signal("knockback", pushBack, -aim_direction)

func get_save_data() -> Dictionary:
	var d := {}
	d["initalized"] = initalized
	d["stats"] = [level, projectileCount, piercing]
	d["friendlyMask"] = friendlyMask
	d["droppedItemPath"] = str("res://droppedItems/dropped",name.rstrip("0123456789"),".tscn")
	d["path"] = path
	return d

func load_save_data(d: Dictionary):
	initalized = true
	_ready()
	for property_name in d:
		if property_name != "droppedItemPath":
			set(property_name, d[property_name])
		else:
			droppedItem = load(d[property_name])
	self.stats = d["stats"].duplicate()
	if stats.size() == 0:
		self.level = 1
