extends "res://Stats.gd"

var coins = 0 setget set_coins
var ability = -1
var abilityLevel = 1
var ability_sprite = null setget change_ability_sprite
var ability_time_left = 0 setget emit_time_left
var ability_cooldown = 0 setget emit_cooldown_left

signal coins_changed(value)
signal ability_time_left(value)
signal ability_cooldown_left(value)
signal ability_sprite_changed(value)

func change_ability_sprite(value):
	ability_sprite = value
	emit_signal("ability_sprite_changed", value)

func set_coins(value):
	coins = value
	emit_signal("coins_changed", value)

func emit_time_left(value):
	ability_time_left = value
	emit_signal("ability_time_left", value)
	
func emit_cooldown_left(value):
	ability_cooldown = value
	emit_signal("ability_cooldown_left", value)
	
