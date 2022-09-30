extends "res://Overlap/itemDetectionZone.gd"

func on_area_entered(area):
	print("ENTERED")
	var item = area.get_parent()
	item.picked_up(self)
