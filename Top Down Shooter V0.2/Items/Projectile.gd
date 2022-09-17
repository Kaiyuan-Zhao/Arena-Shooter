extends Sprite

onready var hitbox = $Hitbox
onready var despawnTimer = $DespawnTimer

var direction = Vector2(1, 0)
export(int) var speed = 500

func _ready():
	hitbox.connect("area_entered", self, "kill")
	hitbox.connect("body_entered", self, "kill")

func kill(_body):
	queue_free()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_DespawnTimer_timeout():
	queue_free()
