extends Node2D

var level = 999 setget set_level

onready var label = $Control/Level

func set_level(value):
	level = value
	label.text = str("LVL: ",level)
