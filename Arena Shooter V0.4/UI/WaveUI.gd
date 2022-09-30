extends Control

var wave = 0 setget set_wave

onready var label = $Label
onready var label2 = $Label2

func set_wave(value):
	wave = value
	label.text = str("WAVE: ",wave)

func _physics_process(delta):
	label2.text = str("REMAINING: ", get_tree().get_nodes_in_group("Enemies").size())
