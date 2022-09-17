extends Sprite

onready var droppedItem = load(str("res://droppedItems/dropped",name,".tscn"))
onready var animationPlayer = $AnimationPlayer
onready var ready = true

signal animation_finished

func _ready():
		
	connectToParent()

func connectToParent():
	# warning-ignore:return_value_discarded
	get_parent().connect("attack", self, "use")
	
func use():
	animationPlayer.play("Attack")
	emit_signal("animation_finished")
	
func drop():
	var d = droppedItem.instance()
	d.global_position = global_position
	get_node("/root/World/Items").add_child(d)
	queue_free()
