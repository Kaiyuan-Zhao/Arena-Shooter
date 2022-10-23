extends Control

var ability_time_left = 0.0 setget set_ability_time_left
var ability_cooldown = 0.0 setget set_ability_cooldown

onready var timeBar = $TimeBar
onready var ability_sprite
onready var icon = $AbilityIcon/Icon
onready var cooldownBar = $CooldownBar

func set_ability_time_left(value):
	ability_time_left = value
	timeBar.value = ability_time_left*timeBar.max_value

func set_ability_cooldown(value):
	ability_cooldown = value
	cooldownBar.value = (ability_cooldown)*cooldownBar.max_value
	
func set_icon(value):
	icon.texture = value
	
func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("ability_cooldown_left", self, "set_ability_cooldown")
# warning-ignore:return_value_discarded
	PlayerStats.connect("ability_time_left", self, "set_ability_time_left")
# warning-ignore:return_value_discarded
	PlayerStats.connect("ability_sprite_changed", self, "set_icon")
