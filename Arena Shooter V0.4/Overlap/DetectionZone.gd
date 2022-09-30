extends Area2D

var bodies = []
func can_see_bodies():
	return not bodies.empty()

func _on_DetectionZone_body_entered(body):
	bodies.append(body)

func _on_DetectionZone_body_exited(body):
	var index = bodies.find(body)
	if index != -1:
		bodies.remove(index)
