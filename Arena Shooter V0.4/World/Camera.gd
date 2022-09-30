extends Camera2D

var shaking = false

onready var shakeTimer = $Timer
onready var tween = $Tween

var shake_amount = 0
var default_offset = offset

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	offset_h = (mouse_pos.x - global_position.x) / (1280.0)
	offset_v = (mouse_pos.y - global_position.y) / (720.0)
	if shaking:
		offset += Vector2(rand_range(-shake_amount, shake_amount), rand_range(-shake_amount, shake_amount)) * delta + default_offset
	

func shake(new_shake, shake_time=0.05, shake_limit=1000):
	shake_amount += new_shake
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	
	shakeTimer.wait_time = shake_time
	
	tween.stop_all()
	shaking = true
	shakeTimer.start()


func _on_Timer_timeout():
	shake_amount = 0
	shaking = false
	tween.interpolate_property(self, "offset", offset, default_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
