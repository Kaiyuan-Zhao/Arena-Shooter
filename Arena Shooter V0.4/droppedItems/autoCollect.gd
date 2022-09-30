extends "res://droppedItems/droppedItem.gd"

var pickingUp = false
var player
var threshold = 16
var speed = 100

func _ready():
	label.visible = false

func picked_up(Player):
	player = Player
	pickingUp = true

func _process(delta):
	if pickingUp:
		global_position = global_position.move_toward(player.global_position, delta * speed)
		speed+=global_position.distance_to(player.global_position)/2
		if global_position.distance_to(player.global_position) <= threshold:
			doAction()
			queue_free()

func doAction():
	pass
