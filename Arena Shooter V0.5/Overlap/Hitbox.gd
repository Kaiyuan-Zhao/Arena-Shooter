extends Area2D

export(int) var base_damage = 1
export(float) var knockback = 5.0
export(bool) var fromPlayer = true
export(bool) var percentageBased = false
export(int) var percentage = 0
onready var damage = base_damage
