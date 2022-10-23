extends Sprite

onready var animationPlayer = $AnimationPlayer
onready var ready = true

onready var path = get_filename()
onready var droppedItem = load(str("res://droppedItems/dropped",name.rstrip("0123456789"),".tscn"))

var level = 1 setget update_level
var _UNSAVABLE_PROPERTIES = ["droppedItem", "animationPlayer"]
var stats = [] setget initalizeStats
var ranged = false
var friendlyMask setget set_friendlyMask
var using = false setget setUsing
var initalized = false

signal level_changed(value)

func setUsing(value):
	using = value

func _physics_process(_delta):
	if using and ready:
		use()

func set_friendlyMask(value):
	friendlyMask = value

func update_level(value):
	level = value
	emit_signal("level_changed", value)


func use():
	ready = false
	animationPlayer.play("Attack")

func initalizeStats(arr):
	if arr.size() > 0:
		self.level = arr[0]
	else:
		self.level = 1
	stats = [level]

func reset_ready():
	ready = true

func drop():
	var d = droppedItem.instance()
	d.global_position = global_position
	d.stats = [level]
	get_node("/root/World/Items").add_child(d)
	queue_free()
	
func get_save_data() -> Dictionary:
	var d := {}
	d["initalized"] = initalized
	d["stats"] = [level]
	d["friendlyMask"] = friendlyMask
	d["droppedItemPath"] = str("res://droppedItems/dropped",name.rstrip("0123456789"),".tscn")
	d["path"] = path
	return d

func load_save_data(d: Dictionary): 
	initalized = true
	_ready()
	for property_name in d:
		if property_name != "droppedItemPath" and property_name != "stats":
			set(property_name, d[property_name])
	self.stats = d["stats"]
	if stats.size() == 0:
		self.level = 1
