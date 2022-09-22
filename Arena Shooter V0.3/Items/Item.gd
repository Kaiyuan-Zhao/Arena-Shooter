extends Sprite

onready var droppedItem = load(str("res://droppedItems/dropped",name,".tscn"))
onready var animationPlayer = $AnimationPlayer
onready var ready = true
onready var hitbox = get_node_or_null("Hitbox")
var friendlyMask
var using = false

func _ready():
	set_friendlyMask()

func _physics_process(_delta):
	if using and ready:
		use()
		
func use():
	ready = false
	animationPlayer.play("Attack")

func reset_ready():
	ready = true

func set_friendlyMask():
	if hitbox != null:
		hitbox.set_collision_mask_bit(friendlyMask, false)

func drop():
	var d = droppedItem.instance()
	d.global_position = global_position
	get_node("/root/World/Items").add_child(d)
	queue_free()
