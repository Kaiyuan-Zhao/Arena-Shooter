extends "res://Overlap/itemDetectionZone.gd"

func on_area_entered(area):
	var item = area.get_parent()
	item.picked_up(self)
