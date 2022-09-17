extends Node2D

export(int) var WANDER_TARGET_RANGE = 4
export(int) var level = 1

onready var body = $Body
onready var label = $Position2D/Control/Level

func _ready():
	body.label = label
	body.WANDER_TARGET_RANGE = WANDER_TARGET_RANGE
	body.level = level
	
