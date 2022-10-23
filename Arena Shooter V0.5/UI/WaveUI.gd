extends Control

var wave = 0 setget set_wave

onready var label = $Label
onready var label2 = $Label2
onready var button = $Button

signal skipToWave

func set_wave(value):
	wave = value
	label.text = str("WAVE: ",wave)

func _physics_process(_delta):
	var rem = get_tree().get_nodes_in_group("Enemies").size()
	label2.text = str("REMAINING: ", rem)
	if rem == 0:
		button.visible = true
	else:
		button.visible = false


func _on_Button_pressed():
	emit_signal("skipToWave")
