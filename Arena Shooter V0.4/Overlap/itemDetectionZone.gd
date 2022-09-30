extends "res://Overlap/DetectionZone.gd"

func _ready():
	connect("area_entered", self, "on_area_entered")
	connect("area_exited", self, "on_area_exited")

func on_area_entered(area):
	bodies.append(area.get_parent())

func on_area_exited(area):
	var index = bodies.find(area.get_parent())
	if index != -1:
		bodies.remove(index)
