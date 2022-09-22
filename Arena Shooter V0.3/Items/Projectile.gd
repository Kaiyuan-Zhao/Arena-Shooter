extends Sprite

onready var hitbox = $Hitbox
onready var hitbox2 = $Hitbox2
onready var despawnTimer = $DespawnTimer

var direction = Vector2(1, 0)
export(int) var speed = 500
export(bool) var piercing = false

func _ready():
	if not piercing:
		hitbox.connect("area_entered", self, "kill")
		hitbox.connect("body_entered", self, "kill")
	hitbox2.connect("area_entered", self, "kill")
	hitbox2.connect("body_entered", self, "kill")

func kill(_body):
	queue_free()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_DespawnTimer_timeout():
	queue_free()
