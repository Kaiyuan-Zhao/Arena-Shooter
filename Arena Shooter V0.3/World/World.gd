extends Node2D

onready var store = $CanvasLayer/store

func _process(_delta):
	if Input.is_action_just_pressed("enter"):
		#get_tree().paused = true
		if store.visible:
			store.visible = false
		else:
			store.visible = true
