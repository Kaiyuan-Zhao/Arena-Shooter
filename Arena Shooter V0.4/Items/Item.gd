extends Sprite

onready var droppedItem = load(str("res://droppedItems/dropped",name,".tscn"))
onready var animationPlayer = $AnimationPlayer
onready var ready = true
onready var level = 1 setget update_level

var friendlyMask
var using = false

signal level_changed(value)

func _physics_process(_delta):
	if using and ready:
		use()

func update_level(value):
	level = value
	emit_signal("level_changed", value)
		

func use():
	ready = false
	animationPlayer.play("Attack")

func reset_ready():
	ready = true

func drop():
	var d = droppedItem.instance()
	d.global_position = global_position
	d.level = level
	get_node("/root/World/Items").add_child(d)
	queue_free()
