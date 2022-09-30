extends CanvasLayer

onready var store = $store
onready var player = null

func _ready():
	yield(get_tree().current_scene, "ready")
	store.player = player
	
