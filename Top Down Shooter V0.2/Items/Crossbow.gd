extends "res://Items/rangedItem.gd"

var waitingForPress = true
var loaded = false

signal justReleased

func connectToPlayer():
	# warning-ignore:return_value_discarded
	get_parent().connect("attack", self, "use")
	
func use():
	ready = false
	if not loaded:
		animationPlayer.play("Load")
		loaded = true
		yield(self, "justReleased")
	else:
		animationPlayer.play("Attack")
		loaded = false
		yield(self, "justReleased")
	ready = true
	#waitingForPress = true

func _process(_delta):
	if Input.is_action_just_released("attack"):
		emit_signal("justReleased")
