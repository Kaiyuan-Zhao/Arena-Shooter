extends Sprite

onready var hitbox = $Hitbox
onready var hitbox2 = $Hitbox2
onready var despawnTimer = $DespawnTimer

var piercing = false
var direction = Vector2(1, 0)

export(float) var pierceFactor = 1.0
export(int) var speed = 100

func _ready():
	if not piercing:
		hitbox.connect("area_entered", self, "kill")
		hitbox.connect("body_entered", self, "kill")
	else:
		hitbox.connect("area_entered", self, "weakenDamage")
		hitbox.connect("body_entered", self, "weakenDamage")
	hitbox2.connect("area_entered", self, "kill")
	hitbox2.connect("body_entered", self, "kill")
	
func kill(_body):
	queue_free()

func weakenDamage(_area):
	hitbox.damage *= pierceFactor
	
func _physics_process(delta):
	global_position += direction * speed * delta

func _on_DespawnTimer_timeout():
	queue_free()
