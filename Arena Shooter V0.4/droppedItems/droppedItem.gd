extends Node2D

export(Resource) var pickedUpWeapon
export(int) var level = 1

onready var label = $Label
onready var texture = $Sprite.texture

func _ready():
	label.text = str("LVL: ", level)
