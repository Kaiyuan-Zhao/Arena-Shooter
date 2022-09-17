extends Control

var coins setget set_coins

onready var label = $Label
	
func set_coins(value):
	coins = value
	label.text = str("Coins: ",coins)

func _ready():
	self.coins = PlayerStats.coins
	# warning-ignore:return_value_discarded
	PlayerStats.connect("coins_changed", self, "set_coins")
