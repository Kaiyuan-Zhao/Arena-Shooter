extends Polygon2D

onready var position2d = $Position2D
onready var position2d2 = $Position2D2
onready var hurtbox = $Hurtbox
onready var collisionShape = $Hitbox/CollisionShape2D
onready var stats = $Stats

var shot = false

func _physics_process(delta):
	print(stats.health)

func set_shot(multiple = 1):
	shot = true
	visible = false
	collisionShape.set_deferred("disabled", true)
	yield(get_tree().create_timer(multiple*1.5), "timeout")
	visible = true
	collisionShape.set_deferred("disabled", true)
	yield(get_tree().create_timer(multiple*0.75), "timeout")
	shot = false
	

func _on_Stats_no_health():
	print("died")
	stats.health = stats.max_health
	set_shot(5)


func _on_Hurtbox_area_entered(area):
	if not hurtbox.is_invincible_to(area):
		stats.health -= area.damage
		hurtbox.create_hit_effect()
		hurtbox.set_invincibility(area, 0.3)
