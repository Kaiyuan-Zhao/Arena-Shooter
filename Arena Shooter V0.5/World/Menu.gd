extends Control

var world := preload("res://World/World.tscn")

func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(world)


func _on_Button2_pressed():
	SaveSystem.immediatelyLoad = true
	get_tree().change_scene_to(world)
	
	
