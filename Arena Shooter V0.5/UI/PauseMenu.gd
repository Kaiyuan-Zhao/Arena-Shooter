extends Control

var paused = false setget set_paused
var dict_to_save := {}

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.paused = !paused
		
func set_paused(value):
	paused = value
	get_tree().paused = paused
	visible = get_tree().paused


func _on_Button_pressed():
	self.paused = false


func _on_Button2_pressed():
	SaveSystem.save()


func _on_Button3_pressed():
	SaveSystem.loadDictionary()
