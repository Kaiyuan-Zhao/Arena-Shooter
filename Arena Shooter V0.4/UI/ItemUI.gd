extends Control

onready var itemTexture = null setget set_item_texture
onready var itemTextureRect = $TextureRect/ItemTextureRect
onready var levelText = $Label

var level = 0 setget set_level

func _ready():
	set_level(0)
	
func set_level(value):
	level = value
	if level > 0:
		levelText.text = str("LVL: ", value)
	else:
		levelText.text = ""

func set_item_texture(value):
	itemTexture = value
	itemTextureRect = itemTexture
	
