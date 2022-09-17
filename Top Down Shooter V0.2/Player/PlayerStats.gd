extends "res://Stats.gd"

var coins = 0 setget set_coins

signal coins_changed(value)

func set_coins(value):
	coins = value
	emit_signal("coins_changed", value)
	
